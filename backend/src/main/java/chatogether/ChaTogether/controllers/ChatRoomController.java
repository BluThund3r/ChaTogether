package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.AddUserToChatDTO;
import chatogether.ChaTogether.DTO.CreateGroupChatDTO;
import chatogether.ChaTogether.DTO.UserDetailsForOthersDTO;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.services.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chatroom")
@RequiredArgsConstructor
public class ChatRoomController {
    private final ChatRoomService chatRoomService;

    @GetMapping("/myChats")
    public List<ChatRoom> getMyChats() {
        var callerUsername = AuthRequestFilter.getUsername();
        return chatRoomService.getChatRoomsOfUser(callerUsername);
    }

    @GetMapping("/chatUsers/{chatRoomId}")
    public List<UserDetailsForOthersDTO> getChatUsers(
            @PathVariable Long chatRoomId
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

    @GetMapping("/getChatRoomKey/{chatRoomId}")
    public String getChatRoomKey(
            @PathVariable Long chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        return chatRoomService.getChatRoomEncryptionKey(callerId, chatRoomId);
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
            @PathVariable Long chatRoomId,
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
            @PathVariable Long chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.leaveChatRoom(callerId, chatRoomId);
    }

    @PostMapping("/makeAdmin/{chatRoomId}/{userId}")
    public void makeUserAdminInChatRoom(
            @PathVariable Long chatRoomId,
            @PathVariable Long userId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.makeUserAdminInChatRoom(userId, chatRoomId, callerId);
    }

    @DeleteMapping("/removeAdmin/{chatRoomId}/{userId}")
    public void removeAdminOfChatRoom(
            @PathVariable Long chatRoomId,
            @PathVariable Long userId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        chatRoomService.removeAdminOfChatRoom(userId, chatRoomId, callerId);
    }
}
