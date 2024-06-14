package chatogether.ChaTogether.serviceTests;

import chatogether.ChaTogether.exceptions.FriendRequestNotFound;
import chatogether.ChaTogether.exceptions.UserBlocked;
import chatogether.ChaTogether.exceptions.UsersAlreadyFriends;
import chatogether.ChaTogether.exceptions.UsersBlocked;
import chatogether.ChaTogether.services.FriendshipService;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
public class FriendshipServiceTests {
    @Autowired
    FriendshipService friendshipService;

    @Test
    @Transactional
    void shouldPassSendFriendRequest() {
        var senderUsername = "BusyBeaver";
        var receiverUsername = "TechMaster";
        Assertions.assertDoesNotThrow(() -> friendshipService.sendFriendRequest(senderUsername, receiverUsername));
    }

    @Test
    @Transactional
    void shouldFailSendFriendRequestUsersFriends() {
        var senderUsername = "BluThund3r";
        var receiverUsername = "GeorgeBlu2";
        Assertions.assertThrows(
                UsersAlreadyFriends.class,
                () -> friendshipService.sendFriendRequest(senderUsername, receiverUsername)
        );
    }

    @Test
    @Transactional
    void shouldFailSendFriendRequestAlreadyExists() {
        var senderUsername = "Timm.yeah";
        var receiverUsername = "GeorgeBlu2";
        Assertions.assertThrows(
                UsersAlreadyFriends.class,
                () -> friendshipService.sendFriendRequest(senderUsername, receiverUsername)
        );
    }

    @Test
    @Transactional
    void shouldFailSendFriendRequestUsersBlocked() {
        var senderUsername = "jonny_great10";
        var receiverUsername = "TechMaster";
        Assertions.assertThrows(
                UserBlocked.class,
                () -> friendshipService.sendFriendRequest(senderUsername, receiverUsername)
        );
    }

    @Test
    @Transactional
    void shouldPassAcceptFriendRequest() {
        // receiver id = 6, sender id = 14
        var receiverUsername = "GeorgeBlu2";
        var senderUsername = "Timm.yeah";
        Assertions.assertDoesNotThrow(() -> friendshipService.acceptFriendRequest(senderUsername, receiverUsername));
    }

    @Test
    @Transactional
    void shouldFailAcceptFriendRequestNotFound() {
        var receiverUsername = "GeorgeBlu2";
        var senderUsername = "Larry2024";
        Assertions.assertThrows(
                FriendRequestNotFound.class,
                () -> friendshipService.acceptFriendRequest(senderUsername, receiverUsername)
        );
    }

    @Test
    @Transactional
    void shouldFailAcceptFriendAlreadyFriends() {
        var receiverUsername = "GeorgeBlu2";
        var senderUsername = "BluThund3r";
        Assertions.assertThrows(
                UsersAlreadyFriends.class,
                () -> friendshipService.acceptFriendRequest(senderUsername, receiverUsername)
        );
    }
}
