package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.*;
import chatogether.ChaTogether.enums.ActionType;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.ChatMessageService;
import chatogether.ChaTogether.services.ChatRoomService;
import chatogether.ChaTogether.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatRoom")
@RequiredArgsConstructor
public class ChatRoomController {
    private final ChatRoomService chatRoomService;
    private final ChatMessageService chatMessageService;
    //    private final SimpMessagingTemplate simpMessagingTemplate;
    private final UserService userService;

    @GetMapping("/myChats")
    public List<ChatRoomDetailsWithLastMessageDTO> getMyChats() {
        var callerUsername = AuthRequestFilter.getUsername();
        return chatRoomService.getChatRoomsOfUser(callerUsername).stream()
                .map(chatRoom -> {
                    var lastMessageOptional = chatMessageService.getLastMessageOfChatRoom(chatRoom.getId());
                    if (lastMessageOptional.isEmpty())
                        return new ChatRoomDetailsWithLastMessageDTO(chatRoom, null, userService);
                    var lastMessage = new OutgoingChatMessageDTO(
                            lastMessageOptional.get(),
                            ActionType.GET,
                            null
                    );
                    return new ChatRoomDetailsWithLastMessageDTO(chatRoom, lastMessage, userService);
                })
                .toList();
    }

    @GetMapping("/chatUsers/{chatRoomId}")
    public List<UserDetailsForOthersDTO> getChatUsers(
            @PathVariable String chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        return chatRoomService.getUsersInChatRoom(chatRoomId, callerId)
                .stream()
                .map(user ->
                        new UserDetailsForOthersDTO(
                                user,
                                chatRoomService.isAdminInChatRoom(user.getId(), chatRoomId)
                        ))
                .toList();
    }

    @GetMapping("/getChatDetailsById/{chatRoomId}")
    public ChatRoomDetailsWithLastMessageDTO getChatDetailsById(
            @PathVariable String chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        return chatRoomService.getChatRoomDetailsById(callerId, chatRoomId);
    }

    @GetMapping("/getChatRoomKey/{chatRoomId}")
    public String getChatRoomKey(
            @PathVariable String chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        return chatRoomService.getChatRoomEncryptionKey(callerId, chatRoomId);
    }

    @GetMapping("/friendsWithNoPrivateChat")
    public List<User> getFriendsWithNoPrivateChat() {
        String username = AuthRequestFilter.getUsername();
        return chatRoomService.getFriendsWithNoPrivateChat(username);
    }

    @PostMapping("/createPrivate/{anotherUsername}")
    public void createPrivateChat(
            @PathVariable String anotherUsername
    ) {
        String callerUsername = AuthRequestFilter.getUsername();
        chatRoomService.createPrivateChat(callerUsername, anotherUsername);
    }

    @PostMapping("/createGroup")
    public void createGroupChat(
            @RequestBody CreateGroupChatDTO createGroupChatDTO
    ) {
        String callerUsername = AuthRequestFilter.getUsername();
        chatRoomService.createGroupChat(
                createGroupChatDTO.getChatRoomName(),
                createGroupChatDTO.getMemberUsernames(),
                callerUsername
        );
    }

    @PostMapping("/addUser")
    public void addUserToGroupChat(
            @RequestBody AddUserToChatDTO addUserToChatDTO
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.addUserToChatRoom(
                addUserToChatDTO.getUserId(),
                addUserToChatDTO.getChatRoomId(),
                addUserToChatDTO.getEncryptedKey(),
                callerId
        );
    }

    @DeleteMapping("/removeUser/{chatRoomId}/{userId}")
    public void removeUserFromGroupChat(
            @PathVariable String chatRoomId,
            @PathVariable Long userId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.removeUserFromChatRoom(
                userId,
                chatRoomId,
                callerId
        );
    }

    @DeleteMapping("/leaveChat/{chatRoomId}")
    public void leaveChatRoom(
            @PathVariable String chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.leaveChatRoom(callerId, chatRoomId);
    }

    @PostMapping("/makeAdmin/{chatRoomId}/{userId}")
    public void makeUserAdminInChatRoom(
            @PathVariable String chatRoomId,
            @PathVariable Long userId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.makeUserAdminInChatRoom(userId, chatRoomId, callerId);
    }

    @DeleteMapping("/removeAdmin/{chatRoomId}/{userId}")
    public void removeAdminOfChatRoom(
            @PathVariable String chatRoomId,
            @PathVariable Long userId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.removeAdminOfChatRoom(userId, chatRoomId, callerId);
    }

    @GetMapping("/friendsNotInChat/{chatRoomId}")
    public List<UserDetailsForOthersDTO> getFriendsNotInChat(
            @PathVariable String chatRoomId
    ) {
        var callerUsername = AuthRequestFilter.getUsername();
        return chatRoomService.getFriendsNotInChat(callerUsername, chatRoomId)
                .stream()
                .map(friend -> new UserDetailsForOthersDTO(friend, false))
                .toList();
    }
}
