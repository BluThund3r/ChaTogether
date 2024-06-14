package chatogether.ChaTogether.serviceTests;

import chatogether.ChaTogether.exceptions.UserAlreadyInVideoRoom;
import chatogether.ChaTogether.exceptions.VideoRoomDoesNotExist;
import chatogether.ChaTogether.services.UserService;
import chatogether.ChaTogether.services.VideoRoomService;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
public class VideoRoomServiceTest {

    @Autowired
    private VideoRoomService videoRoomService;

    @Autowired
    private UserService userService;

    @AfterEach
    void clearVideoRooms() {
        videoRoomService.clearVideoRooms();
    }

    @Test
    @Transactional
    void shouldPassCreateVideoRoom() {
        var videoRoom = videoRoomService.createVideoRoom();
        Assertions.assertEquals(1, videoRoomService.getVideoRooms().size());
    }

    @Test
    @Transactional
    void shouldPassJoinVideoRoom() {
        var user = userService.findByUsername("BluThund3r");
        var videoRoom = videoRoomService.createVideoRoom();
        Assertions.assertDoesNotThrow(() -> videoRoomService.joinVideoRoom(user.get(), videoRoom.getConnectionCode()));
        var videoRoomGot = videoRoomService.getVideoRomByConnectionCode(videoRoom.getConnectionCode());
        Assertions.assertTrue(videoRoomGot.getConnectedUsers().contains(user.get()));
    }

    @Test
    @Transactional
    void shouldFailJoinVideoRoomAlreadyInside() {
        var user = userService.findByUsername("BluThund3r");
        var videoRoom = videoRoomService.createVideoRoom();
        Assertions.assertDoesNotThrow(() -> videoRoomService.joinVideoRoom(user.get(), videoRoom.getConnectionCode()));
        var videoRoomGot = videoRoomService.getVideoRomByConnectionCode(videoRoom.getConnectionCode());
        Assertions.assertTrue(videoRoomGot.getConnectedUsers().contains(user.get()));
        Assertions.assertThrows(UserAlreadyInVideoRoom.class, () -> {
            videoRoomService.joinVideoRoom(user.get(), videoRoom.getConnectionCode());
        });
    }

    @Test
    @Transactional
    void shouldFailJoinVideoRoomDoesNotExist() {
        var user = userService.findByUsername("BluThund3r");
        Assertions.assertThrows(VideoRoomDoesNotExist.class, () -> {
            videoRoomService.joinVideoRoom(user.get(), "123");
        });
    }
}
