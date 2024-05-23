package chatogether.ChaTogether.services;

import chatogether.ChaTogether.exceptions.*;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.repositories.ChatRoomRepository;
import chatogether.ChaTogether.utils.CryptoUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Base64;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChatRoomService {
    private final ChatRoomRepository chatRoomRepository;
    private final UserService userService;
    private final FileService fileService;
    private final FriendshipService friendshipService;
    public static final int MAX_USERS_IN_GROUP_CHAT = 50;

    public ChatRoom createPrivateChat(String senderUsername, String receiverUsername) {
        var sender = userService.findByUsername(senderUsername).orElseThrow(UserDoesNotExist::new);
        var receiver = userService.findByUsername(receiverUsername).orElseThrow(UserDoesNotExist::new);
        if (friendshipService.areUsersFriends(sender, receiver))
            throw new UsersNotFriends();
        if (friendshipService.areUsersBlocked(sender, receiver))
            throw new UsersBlocked();

        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(sender.getUsername() + "-" + receiver.getUsername())
                .maxUsers(2)
                .directoryPath(BCrypt.hashpw(sender.getUsername() + receiver.getUsername(), BCrypt.gensalt()))
                .build();
        SecretKey roomSecretKey = CryptoUtils.generateAESKey();
        var senderEncryptedKey = CryptoUtils.encryptWithRSA(roomSecretKey.getEncoded(), sender.getPublicKey());
        var receiverEncryptedKey = CryptoUtils.encryptWithRSA(roomSecretKey.getEncoded(), receiver.getPublicKey());
        chatRoom.setEncryptedKeyOfUser(sender.getId(), Base64.getEncoder().encodeToString(senderEncryptedKey));
        chatRoom.setEncryptedKeyOfUser(receiver.getId(), Base64.getEncoder().encodeToString(receiverEncryptedKey));
        chatRoom.getAdmins().addAll(List.of(sender.getId(), receiver.getId()));
        fileService.createChatDirectory(chatRoom.getDirectoryPath());

        return chatRoomRepository.save(chatRoom);
    }

    public ChatRoom createGroupChat(String roomName, List<String> receiverUsername, String adminUsername) {
        List<User> users = receiverUsername.stream()
                .map(username -> userService.findByUsername(username).orElseThrow(UserDoesNotExist::new))
                .toList();
        var admin = userService.findByUsername(adminUsername).orElseThrow(UserDoesNotExist::new);

        var directorySeed = users.stream().reduce("", (acc, user) -> acc + user.getUsername(), String::concat);

        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(roomName)
                .maxUsers(MAX_USERS_IN_GROUP_CHAT)
                .directoryPath(BCrypt.hashpw(directorySeed, BCrypt.gensalt()))
                .build();

        SecretKey roomSecretKey = CryptoUtils.generateAESKey();
        users.forEach(user -> {
            var encryptedKey = CryptoUtils.encryptWithRSA(roomSecretKey.getEncoded(), user.getPublicKey());
            chatRoom.setEncryptedKeyOfUser(user.getId(), Base64.getEncoder().encodeToString(encryptedKey));
        });

        chatRoom.getAdmins().add(admin.getId());
        fileService.createChatDirectory(chatRoom.getDirectoryPath());

        return chatRoomRepository.save(chatRoom);
    }

    public ChatRoom getChatRoomById(Long chatRoomId) {
        return chatRoomRepository.findById(chatRoomId).orElseThrow();
    }

    public boolean isUserInChatRoom(Long userId, Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getEncryptedKeyOfUser(userId) != null;
    }

    public List<ChatRoom> getChatRoomsOfUser(String username) {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return chatRoomRepository.findAll().stream()
                .filter(chatRoom -> chatRoom.getEncryptedKeys().containsKey(user.getId()))
                .toList();
    }

    public List<User> getUsersInChatRoom(Long chatRoomId, Long callerId) {
        if (!isUserInChatRoom(callerId, chatRoomId))
            throw new UserNotInChatRoom("You are not part of the chat");
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getEncryptedKeys().keySet().stream()
                .map(userId -> userService.findById(userId).orElseThrow(UserDoesNotExist::new))
                .toList();
    }

    public List<User> getAdminsInChatRoom(Long chatRoomId, Long callerId) {
        if (!isUserInChatRoom(callerId, chatRoomId))
            throw new UserNotInChatRoom("You are not part of the chat");
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
        if (isUserInChatRoom(userId, chatRoomId))
            throw new UserNotInChatRoom();
        return chatRoom.getEncryptedKeyOfUser(userId);
    }

    public void removeUserFromChatRoom(Long userId, Long chatRoomId, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (chatRoom.isPrivateChat())
            throw new UserRemovalDenied();
        if (!chatRoom.getAdmins().contains(adminId))
            throw new UserNotInChatRoom();
        chatRoom.removeUserEncryptionKey(userId);
        chatRoomRepository.save(chatRoom);
    }

    public void leaveChatRoom(Long userId, Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (chatRoom.isPrivateChat())
            throw new UserRemovalDenied("Cannot leave private chat room");
        chatRoom.removeUserEncryptionKey(userId);
        chatRoomRepository.save(chatRoom);
    }

    public void makeUserAdminInChatRoom(Long userId, Long chatRoomId, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoom.getAdmins().contains(adminId))
            throw new NotChatAdmin();
        if (chatRoom.getAdmins().contains(userId))
            return;
        if (chatRoom.getEncryptedKeyOfUser(userId) == null)
            throw new UserNotInChatRoom();

        chatRoom.getAdmins().add(userId);
        chatRoomRepository.save(chatRoom);
    }

    public void removeAdminOfChatRoom(Long userId, Long chatRoomId, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoom.getAdmins().contains(adminId))
            throw new NotChatAdmin();
        if (!chatRoom.getAdmins().contains(userId))
            return;
        if (chatRoom.getAdmins().size() == 1)
            throw new UserRemovalDenied("Cannot remove the last admin");
        chatRoom.getAdmins().remove(userId);
        chatRoomRepository.save(chatRoom);
    }

    public Optional<ChatRoom> findById(Long chatRoomId) {
        return chatRoomRepository.findById(chatRoomId);
    }

    public boolean isAdminInChatRoom(Long userId, Long chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getAdmins().contains(userId);
    }
}

