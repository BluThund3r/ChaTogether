package chatogether.ChaTogether.serviceTests;

import chatogether.ChaTogether.exceptions.ChatRoomAlreadyExists;
import chatogether.ChaTogether.exceptions.UsersBlocked;
import chatogether.ChaTogether.exceptions.UsersNotFriends;
import chatogether.ChaTogether.services.ChatRoomService;
import jakarta.transaction.Transactional;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

@SpringBootTest
@ActiveProfiles("test")
public class ChatRoomServiceTests {

    @Autowired
    ChatRoomService chatRoomService;

    @Autowired
    MongoTemplate mongoTemplate;

    @BeforeEach
    void clearDatabase() {
        mongoTemplate.getDb().drop();
    }

    @Test
    @Transactional
    void shouldPassCreatePrivateChat() {
        var username1 = "BluThund3r";
        var username2 = "NewUser";
        var id1 = 5L;
        var id2 = 9L;
        var chatRoom = chatRoomService.createPrivateChat(username1, username2);
        var chatRoomGot = chatRoomService.findById(chatRoom.getId());
        Assertions.assertTrue(chatRoomGot.isPresent());
        Assertions.assertEquals(chatRoom.getId(), chatRoomGot.get().getId());
        Assertions.assertEquals(chatRoom.getMaxUsers(), chatRoomGot.get().getMaxUsers());
        Assertions.assertTrue(chatRoomGot.get().getEncryptedKeys().containsKey(id1));
        Assertions.assertTrue(chatRoomGot.get().getEncryptedKeys().containsKey(id2));
    }

    @Test
    @Transactional
    void shouldFailCreatePrivateChatNotFriends() {
        Assertions.assertThrows(UsersNotFriends.class, () -> {
            chatRoomService.createPrivateChat("NewUser", "BusyBeaver");
        });
    }

    @Test
    @Transactional
    void shouldFailCreatePrivateChatBlocked() {
        Assertions.assertThrows(UsersBlocked.class, () -> {
            chatRoomService.createPrivateChat("BusyBeaver", "GeorgeBlu2");
        });
    }

    @Test
    @Transactional
    void shouldFailCreatePrivateChatAlreadyExists() {
        chatRoomService.createPrivateChat("BluThund3r", "NewUser");
        Assertions.assertThrows(ChatRoomAlreadyExists.class, () -> {
            chatRoomService.createPrivateChat("BluThund3r", "NewUser");
        });
    }


    @Test
    @Transactional
    void shouldPassCreateGroupChat() {
        var adminUsername = "BluThund3r";
        var otherUsernames = List.of("BluThund3r", "NewUser", "BusyBeaver", "GeorgeBlu2");
        var roomName = "Test Room";
        var chatRoom = chatRoomService.createGroupChat(roomName, otherUsernames, adminUsername);
        var chatRoomGot = chatRoomService.findById(chatRoom.getId());
        Assertions.assertTrue(chatRoomGot.isPresent());
        Assertions.assertEquals(chatRoom.getId(), chatRoomGot.get().getId());
        Assertions.assertEquals(chatRoom.getMaxUsers(), chatRoomGot.get().getMaxUsers());
        Assertions.assertEquals(chatRoom.getRoomName(), chatRoomGot.get().getRoomName());
        Assertions.assertTrue(chatRoom.getEncryptedKeys().containsKey(5L));
        Assertions.assertTrue(chatRoom.getEncryptedKeys().containsKey(6L));
        Assertions.assertTrue(chatRoom.getEncryptedKeys().containsKey(9L));
        Assertions.assertTrue(chatRoom.getEncryptedKeys().containsKey(10L));
        Assertions.assertTrue(chatRoomGot.get().getAdmins().contains(5L) && chatRoomGot.get().getAdmins().size() == 1);
    }

    @Test
    @Transactional
    void shouldFailCreateGroupChatNotAllUsersFriends() {
        var adminUsername = "NewUser";
        var otherUsernames = List.of("BluThund3r", "BusyBeaver", "GeorgeBlu2");
        var roomName = "Test Room";
        Assertions.assertThrows(UsersNotFriends.class, () -> {
            chatRoomService.createGroupChat(roomName, otherUsernames, adminUsername);
        });
    }

    @Test
    @Transactional
    void shouldFailCreateGroupChatAnyUserBlocked() {
        var adminUsername = "BusyBeaver";
        var otherUsernames = List.of("BluThund3r", "GeorgeBlu2");
        var roomName = "Test Room";
        Assertions.assertThrows(UsersBlocked.class, () -> {
            chatRoomService.createGroupChat(roomName, otherUsernames, adminUsername);
        });
    }
}
