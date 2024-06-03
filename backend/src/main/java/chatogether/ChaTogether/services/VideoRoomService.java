package chatogether.ChaTogether.services;

import chatogether.ChaTogether.exceptions.UserAlreadyInChatRoom;
import chatogether.ChaTogether.exceptions.UserNotInVideoRoom;
import chatogether.ChaTogether.exceptions.VideoRoomDoesNotExist;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.persistence.VideoRoom;
import chatogether.ChaTogether.utils.RandomTokenGenerator;
import jdk.swing.interop.SwingInterOpUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class VideoRoomService {
    private Set<VideoRoom> videoRooms;
    private Map<String, LocalDateTime> lastUserLeft;
    private static int MAX_INACTIVE_TIME_MINUTES = 5;

    public VideoRoomService() {
        videoRooms = new HashSet<>();
        lastUserLeft = new HashMap<>();
    }

    public VideoRoom createVideoRoom() {
        VideoRoom videoRoom = new VideoRoom();
        var connectionCode = RandomTokenGenerator.generateVideoRoomConnectionCode();
        var videoRoomConnectionStrings = videoRooms.stream()
                .map(VideoRoom::getConnectionCode)
                .collect(Collectors.toSet());

        while (videoRoomConnectionStrings.contains(connectionCode)) {
            connectionCode = RandomTokenGenerator.generateVideoRoomConnectionCode();
        }

        videoRoom.setConnectionCode(RandomTokenGenerator.generateVideoRoomConnectionCode());
        videoRoom.setConnectedUsers(new HashSet<>());
        videoRooms.add(videoRoom);
        return videoRoom;
    }

    public VideoRoom getVideoRomByConnectionCode(String connectionCode) {
        return videoRooms.stream().filter(videoRoom -> videoRoom.getConnectionCode().equals(connectionCode))
                .findFirst().orElse(null);
    }

    public List<VideoRoom> getVideoRooms() {
        return videoRooms.stream().toList();
    }

    public VideoRoom joinVideoRoom(User user, String connectionCode) {
        var videoRoom = getVideoRomByConnectionCode(connectionCode);
        if (videoRoom == null)
            throw new VideoRoomDoesNotExist();
        if (videoRoom.getConnectedUsers().contains(user))
            throw new UserAlreadyInChatRoom();

        videoRoom.getConnectedUsers().add(user);
        lastUserLeft.remove(connectionCode);
        return videoRoom;
    }

    public VideoRoom leaveVideoRoom(User user, String connectionCode) {
        var videoRoom = getVideoRomByConnectionCode(connectionCode);
        if (videoRoom == null)
            throw new VideoRoomDoesNotExist();
        if (!videoRoom.getConnectedUsers().contains(user))
            throw new UserNotInVideoRoom();

        videoRoom.getConnectedUsers().remove(user);
        if (videoRoom.getConnectedUsers().isEmpty())
            lastUserLeft.put(connectionCode, LocalDateTime.now());

        return videoRoom;
    }

    @Scheduled(fixedRate = 60000) // Checks every minute
    public void checkRooms() {
        System.out.println("CHECKING ROOMS");
        System.out.println("Existent rooms: ");
        videoRooms.forEach(System.out::println);
        System.out.println("Last user left: ");
        lastUserLeft.forEach((key, value) -> System.out.println(key + " " + value));
        var fiveMinutesAgo = LocalDateTime.now().minusMinutes(MAX_INACTIVE_TIME_MINUTES);
        var iterator = lastUserLeft.entrySet().iterator();
        while (iterator.hasNext()) {
            var entry = iterator.next();
            if (entry.getValue().isBefore(fiveMinutesAgo)) {
                var videoRoom = getVideoRomByConnectionCode(entry.getKey());
                videoRooms.remove(videoRoom);
                iterator.remove();
            }
        }
//        for (var entry : lastUserLeft.entrySet()) {
//            if (entry.getValue().isBefore(fiveMinutesAgo)) {
//                var videoRoom = getVideoRomByConnectionCode(entry.getKey());
//                videoRooms.remove(videoRoom);
//            }
//        }
//        lastUserLeft.entrySet().removeIf(entry -> entry.getValue().isBefore(fiveMinutesAgo));
    }
}