package chatogether.ChaTogether.persistence;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VideoRoom {
    private String connectionCode;
    private Set<User> connectedUsers;

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
