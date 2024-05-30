package chatogether.ChaTogether.services;

import chatogether.ChaTogether.DTO.ChatRoomAddOrRemoveDTO;
import chatogether.ChaTogether.enums.ChatRoomAction;
import chatogether.ChaTogether.exceptions.*;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.repositories.ChatRoomRepository;
import chatogether.ChaTogether.utils.CryptoUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ChatRoomService {
    private final ChatRoomRepository chatRoomRepository;
    private final UserService userService;
    private final FileService fileService;
    private final FriendshipService friendshipService;
    private final SimpMessagingTemplate simpMessagingTemplate;
    public static final int MAX_USERS_IN_GROUP_CHAT = 50;

    public ChatRoom createPrivateChat(String senderUsername, String receiverUsername) {

        // TODO: modifica toate canalele de trimitere de mesaje!!!!!
        var sender = userService.findByUsername(senderUsername).orElseThrow(UserDoesNotExist::new);
        var receiver = userService.findByUsername(receiverUsername).orElseThrow(UserDoesNotExist::new);
        if (!friendshipService.areUsersFriends(sender, receiver))
            throw new UsersNotFriends();
        if (friendshipService.areUsersBlocked(sender, receiver))
            throw new UsersBlocked();
        if (areUsersInPrivateChat(sender, receiver))
            throw new ChatRoomAlreadyExists("Private chat already exists");

        var directoryPath = BCrypt.hashpw(sender.getUsername() + receiver.getUsername(), BCrypt.gensalt())
                .replaceAll("[^a-zA-Z0-9.-]", "_");

        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(sender.getUsername() + "-" + receiver.getUsername())
                .maxUsers(2)
                .directoryPath(directoryPath)
                .admins(new ArrayList<>())
                .encryptedKeys(new HashMap<>())
                .build();
        SecretKey roomSecretKey = CryptoUtils.generateAESKey();
        String ivString = Base64.getEncoder().encodeToString(CryptoUtils.generateIV());
        String roomSecretKeyString = Base64.getEncoder().encodeToString(roomSecretKey.getEncoded());
        String concatenated = ivString + "." + roomSecretKeyString;
        System.out.println("IV and Secret key of private chat: " + concatenated);
        var senderEncryptedKey = CryptoUtils.encryptWithRSA(concatenated.getBytes(), sender.getPublicKey());
        var receiverEncryptedKey = CryptoUtils.encryptWithRSA(concatenated.getBytes(), receiver.getPublicKey());
        chatRoom.setEncryptedKeyOfUser(sender.getId(), Base64.getEncoder().encodeToString(senderEncryptedKey));
        chatRoom.setEncryptedKeyOfUser(receiver.getId(), Base64.getEncoder().encodeToString(receiverEncryptedKey));
        chatRoom.getAdmins().addAll(List.of(sender.getId(), receiver.getId()));
        System.out.println("Creating chat directory" + chatRoom.getDirectoryPath());
        fileService.createChatDirectory(chatRoom.getDirectoryPath());
        var savedChatRoom = chatRoomRepository.save(chatRoom);
        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/addOrRemove",
                new ChatRoomAddOrRemoveDTO(
                        savedChatRoom,
                        null,
                        ChatRoomAction.ADD,
                        List.of(sender.getId(), receiver.getId()),
                        userService
                )
        );

        return savedChatRoom;
    }

    public ChatRoom createGroupChat(String roomName, List<String> receiverUsername, String adminUsername) {
        List<User> users = receiverUsername.stream()
                .map(username -> userService.findByUsername(username).orElseThrow(UserDoesNotExist::new))
                .toList();
        var admin = userService.findByUsername(adminUsername).orElseThrow(UserDoesNotExist::new);

        var directorySeed = users.stream().reduce("", (acc, user) -> acc + user.getUsername(), String::concat);
        var directoryPath = BCrypt.hashpw(directorySeed, BCrypt.gensalt())
                .replaceAll("[^a-zA-Z0-9.-]", "_");

        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(roomName)
                .maxUsers(MAX_USERS_IN_GROUP_CHAT)
                .directoryPath(directoryPath)
                .admins(new ArrayList<>())
                .encryptedKeys(new HashMap<>())
                .build();

        SecretKey roomSecretKey = CryptoUtils.generateAESKey();
        String ivString = Base64.getEncoder().encodeToString(CryptoUtils.generateIV());
        String roomSecretKeyString = Base64.getEncoder().encodeToString(roomSecretKey.getEncoded());
        String concatenated = ivString + "." + roomSecretKeyString;
        System.out.println("IV and Secret key of group chat: " + concatenated);
        users.forEach(user -> {
            var encryptedKey = CryptoUtils.encryptWithRSA(concatenated.getBytes(), user.getPublicKey());
            chatRoom.setEncryptedKeyOfUser(user.getId(), Base64.getEncoder().encodeToString(encryptedKey));
        });

        chatRoom.getAdmins().add(admin.getId());
        fileService.createChatDirectory(chatRoom.getDirectoryPath());
        var savedChatRoom = chatRoomRepository.save(chatRoom);

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/addOrRemove",
                new ChatRoomAddOrRemoveDTO(
                        savedChatRoom,
                        null,
                        ChatRoomAction.ADD,
                        users.stream().map(User::getId).toList(),
                        userService
                )
        );

        return savedChatRoom;
    }

    public ChatRoom getChatRoomById(String chatRoomId) {
        return chatRoomRepository.findById(chatRoomId).orElseThrow();
    }

    public boolean isUserInChatRoom(Long userId, String chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getEncryptedKeyOfUser(userId) != null;
    }

    public List<ChatRoom> getChatRoomsOfUser(String username) {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return chatRoomRepository.findAll().stream()
                .filter(chatRoom -> chatRoom.getEncryptedKeys().containsKey(user.getId()))
                .toList();
    }

    public List<User> getUsersInChatRoom(String chatRoomId, Long callerId) {
        if (!isUserInChatRoom(callerId, chatRoomId))
            throw new UserNotInChatRoom("You are not part of the chat");
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getEncryptedKeys().keySet().stream()
                .map(userId -> userService.findById(userId).orElseThrow(UserDoesNotExist::new))
                .toList();
    }

    public List<User> getAdminsInChatRoom(String chatRoomId, Long callerId) {
        if (!isUserInChatRoom(callerId, chatRoomId))
            throw new UserNotInChatRoom("You are not part of the chat");
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getAdmins().stream()
                .map(userId -> userService.findById(userId).orElseThrow(UserDoesNotExist::new))
                .toList();
    }

    public void addUserToChatRoom(Long userId, String chatRoomId, String encryptedKey, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoom.getAdmins().contains(adminId))
            throw new UserNotInChatRoom();
        chatRoom.setEncryptedKeyOfUser(userId, encryptedKey);
        var savedChatRoom = chatRoomRepository.save(chatRoom);
        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/addOrRemove",
                new ChatRoomAddOrRemoveDTO(
                        savedChatRoom,
                        null,
                        ChatRoomAction.ADD,
                        List.of(userId),
                        userService
                )
        );
    }

    public String getChatRoomEncryptionKey(Long userId, String chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (isUserInChatRoom(userId, chatRoomId))
            throw new UserNotInChatRoom();
        return chatRoom.getEncryptedKeyOfUser(userId);
    }

    public void removeUserFromChatRoom(Long userId, String chatRoomId, Long adminId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (chatRoom.isPrivateChat())
            throw new UserRemovalDenied();
        if (!chatRoom.getAdmins().contains(adminId))
            throw new UserNotInChatRoom();
        chatRoom.removeUserEncryptionKey(userId);

        var savedChatRoom = chatRoomRepository.save(chatRoom);

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/addOrRemove",
                new ChatRoomAddOrRemoveDTO(
                        savedChatRoom,
                        null,
                        ChatRoomAction.ADD,
                        List.of(userId),
                        userService
                )
        );
    }

    public void leaveChatRoom(Long userId, String chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (chatRoom.isPrivateChat())
            throw new UserRemovalDenied("Cannot leave private chat room");
        chatRoom.removeUserEncryptionKey(userId);
        var savedChatRoom = chatRoomRepository.save(chatRoom);

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/addOrRemove",
                new ChatRoomAddOrRemoveDTO(
                        savedChatRoom,
                        null,
                        ChatRoomAction.REMOVE,
                        List.of(userId),
                        userService
                )
        );
    }

    public void makeUserAdminInChatRoom(Long userId, String chatRoomId, Long adminId) {
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

    public void removeAdminOfChatRoom(Long userId, String chatRoomId, Long adminId) {
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

    public Optional<ChatRoom> findById(String chatRoomId) {
        return chatRoomRepository.findById(chatRoomId);
    }

    public boolean isAdminInChatRoom(Long userId, String chatRoomId) {
        var chatRoom = chatRoomRepository.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        return chatRoom.getAdmins().contains(userId);
    }

    public boolean areUsersInPrivateChat(User user, User friend) {
        var result = chatRoomRepository.findPrivateByUserIds(user.getId(), friend.getId()).isPresent();
        System.out.println("Are users in private chat: " + result);
        return result;
    }

    public List<User> getFriendsWithNoPrivateChat(String username) {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        var result = user.getFriends().stream()
                .filter(friend -> !this.areUsersInPrivateChat(user, friend))
                .toList();
        result.forEach(friend -> System.out.println(friend.getUsername()));
        return result;
    }
}

