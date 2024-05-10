package chatogether.ChaTogether.services;

import chatogether.ChaTogether.exceptions.*;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.persistence.FriendRequest;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.repositories.FriendRequestRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class FriendshipService {
    private FriendRequestRepository friendRequestRepository;
    private UserService userService;

    public void sendFriendRequest(String sender, String receiver) {
        if (friendRequestRepository.getFriendRequest(sender, receiver).isPresent()) {
            throw new UsersAlreadyFriends();
        }
        FriendRequest friendRequest = new FriendRequest();
        var senderUser = userService.findByUsername(sender).orElseThrow(UserDoesNotExist::new);
        var receiverUser = userService.findByUsername(receiver).orElseThrow(UserDoesNotExist::new);
        if (senderUser.getBlockedUsers().contains(receiverUser))
            throw new UserBlocked("You have blocked this user");

        if (receiverUser.getBlockedUsers().contains(senderUser))
            throw new UserBlocked("This user has blocked you");

        friendRequest.setSender(senderUser);
        friendRequest.setReceiver(receiverUser);
        friendRequestRepository.save(friendRequest);
        senderUser.getSentFriendRequests().add(friendRequest);
        receiverUser.getReceivedFriendRequests().add(friendRequest);
        userService.saveUser(senderUser);
        userService.saveUser(receiverUser);
    }

    private void createFriendship(String sender, String receiver) {
        var user1 = userService.findByUsername(sender).orElseThrow(UserDoesNotExist::new);
        var user2 = userService.findByUsername(receiver).orElseThrow(UserDoesNotExist::new);
        if (user1.getFriends().contains(user2) || user2.getFriends().contains(user1)) {
            throw new UsersAlreadyFriends();
        }
        user1.getFriends().add(user2);
        user2.getFriends().add(user1);
        userService.saveUser(user1);
        userService.saveUser(user2);
    }

    public void removeFriendship(String username1, String username2) {
        var user1 = userService.findByUsername(username1).orElseThrow(UserDoesNotExist::new);
        var user2 = userService.findByUsername(username2).orElseThrow(UserDoesNotExist::new);
        if (!user1.getFriends().contains(user2) || !user2.getFriends().contains(user1)) {
            throw new UsersNotFriends();
        }
        user1.getFriends().remove(user2);
        user2.getFriends().remove(user1);
        userService.saveUser(user1);
        userService.saveUser(user2);
    }

    public void acceptFriendRequest(String sender, String receiver) {
        var friendRequest = friendRequestRepository.getFriendRequest(sender, receiver).orElseThrow(FriendRequestNotFound::new);
        this.createFriendship(sender, receiver);
        friendRequestRepository.delete(friendRequest);
    }

    public void deleteFriendRequest(String sender, String receiver) {
        var friendRequest = friendRequestRepository.getFriendRequest(sender, receiver).orElseThrow(FriendRequestNotFound::new);
        var senderUser = userService.findByUsername(sender).orElseThrow(UserDoesNotExist::new);
        var receiverUser = userService.findByUsername(receiver).orElseThrow(UserDoesNotExist::new);
        senderUser.getSentFriendRequests().remove(friendRequest);
        receiverUser.getReceivedFriendRequests().remove(friendRequest);
        userService.saveUser(senderUser);
        userService.saveUser(receiverUser);
        friendRequestRepository.delete(friendRequest);
    }

    public List<FriendRequest> getReceivedFriendRequests(String username) {
        userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return friendRequestRepository.getReceivedFriendRequestsOfUser(username);
    }

    public List<FriendRequest> getSentFriendRequests(String username) {
        userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return friendRequestRepository.getSentFriendRequestsOfUser(username);
    }

    public List<User> getFriends(String username) {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return user.getFriends().stream().toList();
    }

    public void blockUser(String requestingUsername, String usernameToBlock) {
        var userRequesting = userService.findByUsername(requestingUsername).orElseThrow(UserDoesNotExist::new);
        var userToBlock = userService.findByUsername(usernameToBlock).orElseThrow(UserDoesNotExist::new);
        if (userRequesting.getBlockedUsers().contains(userToBlock))
            throw new UserAlreadyBlocked();

        userRequesting.getBlockedUsers().add(userToBlock);
        try {
            this.deleteFriendRequest(requestingUsername, usernameToBlock);
        } catch (FriendRequestNotFound ignored) {
        }

        try {
            this.deleteFriendRequest(usernameToBlock, requestingUsername);
        } catch (FriendRequestNotFound ignored) {
        }

        userService.saveUser(userRequesting);
    }

    public void unblockUser(String requestingUsername, String usernameToUnblock) {
        var userRequesting = userService.findByUsername(requestingUsername).orElseThrow(UserDoesNotExist::new);
        var userToUnblock = userService.findByUsername(usernameToUnblock).orElseThrow(UserDoesNotExist::new);
        if (!userRequesting.getBlockedUsers().contains(userToUnblock))
            throw new UserNotBlocked();

        userRequesting.getBlockedUsers().remove(userToUnblock);
        userService.saveUser(userRequesting);
    }

    public List<User> getBlockedUsers(String username) {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return user.getBlockedUsers().stream().toList();
    }
}
