package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.OutgoingChatMessageDTO;
import chatogether.ChaTogether.enums.ActionType;
import chatogether.ChaTogether.enums.ChatMessageType;
import chatogether.ChaTogether.exceptions.ChatRoomDoesNotExist;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.FriendRequest;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.ChatRoomService;
import chatogether.ChaTogether.services.FriendshipService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/friendship")
public class FriendshipController {
    private FriendshipService friendshipService;
    private ChatRoomService chatRoomService;
    private SimpMessagingTemplate simpMessagingTemplate;

    @GetMapping("/receivedRequests")
    public List<FriendRequest> getReceivedFriendRequests() {
        String username = AuthRequestFilter.getUsername();
        return friendshipService.getReceivedFriendRequests(username);
    }

    @GetMapping("/sentRequests")
    public List<FriendRequest> getSentFriendRequests() {
        String username = AuthRequestFilter.getUsername();
        return friendshipService.getSentFriendRequests(username);
    }

    @GetMapping("/friends")
    public List<User> getFriends() {
        String username = AuthRequestFilter.getUsername();
        return friendshipService.getFriends(username);
    }

    @PostMapping("/sendRequest/{receiver}")
    @ResponseStatus(HttpStatus.OK)
    public void sendFriendRequest(
            @PathVariable String receiver
    ) {
        String sender = AuthRequestFilter.getUsername();
        friendshipService.sendFriendRequest(sender, receiver);
    }

    @PostMapping("/acceptRequest/{sender}")
    @ResponseStatus(HttpStatus.OK)
    public void acceptFriendRequest(
            @PathVariable String sender
    ) {
        String receiver = AuthRequestFilter.getUsername();
        friendshipService.acceptFriendRequest(sender, receiver);
    }

    @DeleteMapping("/rejectRequest/{sender}")
    @ResponseStatus(HttpStatus.OK)
    public void rejectFriendRequest(
            @PathVariable String sender
    ) {
        String receiver = AuthRequestFilter.getUsername();
        friendshipService.deleteFriendRequest(sender, receiver);
    }

    @DeleteMapping("/cancelRequest/{receiver}")
    @ResponseStatus(HttpStatus.OK)
    public void cancelFriendRequest(
            @PathVariable String receiver
    ) {
        String sender = AuthRequestFilter.getUsername();
        friendshipService.deleteFriendRequest(sender, receiver);
    }

    @DeleteMapping("/removeFriend/{friendToRemove}")
    @ResponseStatus(HttpStatus.OK)
    public void removeFriend(
            @PathVariable String friendToRemove
    ) {
        String requestingUsername = AuthRequestFilter.getUsername();
        friendshipService.removeFriendship(requestingUsername, friendToRemove);
        try {
            chatRoomService.deletePrivateChat(requestingUsername, friendToRemove);
        } catch (ChatRoomDoesNotExist ignored) {
            System.out.println("Chat room does not exist");
        }
    }

    @GetMapping("/blockedUsers")
    @ResponseStatus(HttpStatus.OK)
    public List<User> getBlockedUsers() {
        String username = AuthRequestFilter.getUsername();
        return friendshipService.getBlockedUsers(username);
    }

    @PostMapping("/blockUser/{userToBlock}")
    @ResponseStatus(HttpStatus.OK)
    public void blockUser(
            @PathVariable String userToBlock
    ) {
        String requestingUsername = AuthRequestFilter.getUsername();
        friendshipService.blockUser(requestingUsername, userToBlock);
        var chatRoom = chatRoomService.getPrivateChatOfUsers(requestingUsername, userToBlock).orElse(null);
        if (chatRoom == null)
            return;

        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoom/" + chatRoom.getId(),
                OutgoingChatMessageDTO.builder()
                        .id("0")
                        .chatRoomId(chatRoom.getId())
                        .senderId(0L)
                        .encryptedContent("")
                        .sentAt(LocalDateTime.now().toString())
                        .isEdited(false)
                        .isDeleted(false)
                        .seenBy(List.of())
                        .type(ChatMessageType.ANNOUNCEMENT)
                        .action(ActionType.BLOCK)
                        .build()
        );
    }

    @DeleteMapping("/unblockUser/{userToUnblock}")
    @ResponseStatus(HttpStatus.OK)
    public void unblockUser(
            @PathVariable String userToUnblock
    ) {
        String requestingUsername = AuthRequestFilter.getUsername();
        friendshipService.unblockUser(requestingUsername, userToUnblock);

        var chatRoom = chatRoomService.getPrivateChatOfUsers(requestingUsername, userToUnblock).orElse(null);
        if (chatRoom == null)
            return;

        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoom/" + chatRoom.getId(),
                OutgoingChatMessageDTO.builder()
                        .id("0")
                        .chatRoomId(chatRoom.getId())
                        .senderId(0L)
                        .encryptedContent("")
                        .sentAt(LocalDateTime.now().toString())
                        .isEdited(false)
                        .isDeleted(false)
                        .seenBy(List.of())
                        .type(ChatMessageType.ANNOUNCEMENT)
                        .action(ActionType.UNBLOCK)
                        .build()

        );
    }

    @GetMapping("/areUsersBlocked/{userId1}/{userId2}")
    @ResponseStatus(HttpStatus.OK)
    public boolean areUsersBlocked(
            @PathVariable Long userId1,
            @PathVariable Long userId2
    ) {
        return friendshipService.areUsersBlockedByIds(userId1, userId2);
    }
}
