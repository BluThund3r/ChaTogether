package chatogether.ChaTogether.services;

import chatogether.ChaTogether.exceptions.ChatRoomDoesNotExist;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.exceptions.UserNotInChatRoom;
import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.repositories.ChatRoomRepository;
import chatogether.ChaTogether.utils.CryptoUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Base64;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatRoomService {
    private final ChatRoomRepository chatRoomRepository;
    private final UserService userService;
    public static final int MAX_USERS_IN_GROUP_CHAT = 50;

    public ChatRoom createPrivateChat(Long senderId, Long receiverId) {
        var sender = userService.findById(senderId).orElseThrow(UserDoesNotExist::new);
        var receiver = userService.findById(receiverId).orElseThrow(UserDoesNotExist::new);
        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(sender.getUsername() + " - " + receiver.getUsername())
                .maxUsers(2)
                .build();
        SecretKey roomSecretKey = CryptoUtils.generateAESKey();
        var senderEncryptedKey = CryptoUtils.encryptWithRSA(roomSecretKey.getEncoded(), sender.getPublicKey());
        var receiverEncryptedKey = CryptoUtils.encryptWithRSA(roomSecretKey.getEncoded(), receiver.getPublicKey());
        chatRoom.setEncryptedKeyOfUser(senderId, Base64.getEncoder().encodeToString(senderEncryptedKey));
        chatRoom.setEncryptedKeyOfUser(receiverId, Base64.getEncoder().encodeToString(receiverEncryptedKey));
        chatRoom.getAdmins().addAll(List.of(senderId, receiverId));
        return chatRoomRepository.save(chatRoom);
    }

    public ChatRoom createGroupChat(String roomName, List<Long> initialUserIds, Long adminId) {
        List<User> users = initialUserIds.stream()
                .map(userId -> userService.findById(userId).orElseThrow(UserDoesNotExist::new))
                .toList();

        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(roomName)
                .maxUsers(MAX_USERS_IN_GROUP_CHAT)
                .build();

        SecretKey roomSecretKey = CryptoUtils.generateAESKey();
        users.forEach(user -> {
            var encryptedKey = CryptoUtils.encryptWithRSA(roomSecretKey.getEncoded(), user.getPublicKey());
            chatRoom.setEncryptedKeyOfUser(user.getId(), Base64.getEncoder().encodeToString(encryptedKey));
        });

        chatRoom.getAdmins().add(adminId);
        return chatRoomRepository.save(chatRoom);
    }

    public ChatRoom getChatRoomById(Long chatRoomId) {
        return chatRoomRepository.findById(chatRoomId).orElseThrow();
    }

    public boolean isUserInChatRoom(Long userId, Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getEncryptedKeyOfUser(userId) != null;
    }

    public List<User> getUsersInChatRoom(Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getEncryptedKeys().keySet().stream()
                .map(userId -> userService.findById(userId).orElseThrow(UserDoesNotExist::new))
                .toList();
    }

    public List<User> getAdminsInChatRoom(Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getAdmins().stream()
                .map(userId -> userService.findById(userId).orElseThrow(UserDoesNotExist::new))
                .toList();
    }

    public void addUserToChatRoom(Long userId, Long chatRoomId, String encryptedKey, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoom.getAdmins().contains(adminId))
            throw new UserNotInChatRoom();
        chatRoom.setEncryptedKeyOfUser(userId, encryptedKey);
        chatRoomRepository.save(chatRoom);
    }

    public String getChatRoomEncryptionKey(Long userId, Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (chatRoom.getEncryptedKeyOfUser(userId) == null)
            throw new UserNotInChatRoom();
        return chatRoom.getEncryptedKeyOfUser(userId);
    }

    public void removeUserFromChatRoom(Long userId, Long chatRoomId, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoom.getAdmins().contains(adminId))
            throw new UserNotInChatRoom();
        chatRoom.removeUserEncryptionKey(userId);
        chatRoomRepository.save(chatRoom);
    }

    public void leaveChatRoom(Long userId, Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        chatRoom.removeUserEncryptionKey(userId);
        chatRoomRepository.save(chatRoom);
    }

    public void makeUserAdminInChatRoom(Long userId, Long chatRoomId, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoom.getAdmins().contains(adminId))
            throw new UserNotInChatRoom();
        if (chatRoom.getAdmins().contains(userId))
            return;
        if (chatRoom.getEncryptedKeyOfUser(userId) == null)
            throw new UserNotInChatRoom();

        chatRoom.getAdmins().add(userId);
        chatRoomRepository.save(chatRoom);
    }
}

