package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.FriendRequest;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.FriendshipService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/friendship")
public class FriendshipController {
    private FriendshipService friendshipService;

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
    }

    @PostMapping("/blockUser/{userToBlock}")
    @ResponseStatus(HttpStatus.OK)
    public void blockUser(
            @PathVariable String userToBlock
    ) {
        String requestingUsername = AuthRequestFilter.getUsername();
        friendshipService.blockUser(requestingUsername, userToBlock);
    }

    @GetMapping("/blockedUsers")
    @ResponseStatus(HttpStatus.OK)
    public List<User> getBlockedUsers() {
        String username = AuthRequestFilter.getUsername();
        return friendshipService.getBlockedUsers(username);
    }

    @DeleteMapping("/unblockUser/{userToUnblock}")
    @ResponseStatus(HttpStatus.OK)
    public void unblockUser(
            @PathVariable String userToUnblock
    ) {
        String requestingUsername = AuthRequestFilter.getUsername();
        friendshipService.unblockUser(requestingUsername, userToUnblock);
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
