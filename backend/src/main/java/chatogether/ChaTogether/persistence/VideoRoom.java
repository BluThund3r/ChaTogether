package chatogether.ChaTogether.persistence;

import chatogether.ChaTogether.DTO.VideoRoomSignalDTO;
import chatogether.ChaTogether.enums.VideoRoomSignalType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@Data
@AllArgsConstructor
public class VideoRoom {
    private String connectionCode;
    private Set<User> connectedUsers;
    private Map<VideoRoomSignalType, LocalDateTime> lastSignalTime;

    public VideoRoom() {
        lastSignalTime = new HashMap<>();
        lastSignalTime.put(VideoRoomSignalType.PAUSE, LocalDateTime.now());
        lastSignalTime.put(VideoRoomSignalType.RESUME, LocalDateTime.now());
        lastSignalTime.put(VideoRoomSignalType.CHANGE_VIDEO, LocalDateTime.now());
        lastSignalTime.put(VideoRoomSignalType.SEEK, LocalDateTime.now());
    }

    public LocalDateTime getLastSignalTime(VideoRoomSignalType signalType) {
        return lastSignalTime.get(signalType);
    }

    public void setLastSignalTime(VideoRoomSignalType signalType, LocalDateTime time) {
        lastSignalTime.put(signalType, time);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        VideoRoom videoRoom = (VideoRoom) o;

        return connectionCode.equals(videoRoom.connectionCode);
    }

    @Override
    public int hashCode() {
        return connectionCode.hashCode();
    }
}
