package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.persistence.VideoRoom;
import lombok.Data;

import java.util.List;

@Data
public class VideoRoomDetailsDTO {
    private String connectionCode;
    private List<UserDetailsForOthersDTO> connectedUsersDetails;

    public VideoRoomDetailsDTO(VideoRoom videoRoom) {
        this.connectionCode = videoRoom.getConnectionCode();
        this.connectedUsersDetails = videoRoom.getConnectedUsers().stream()
                .map(user -> new UserDetailsForOthersDTO(user, false))
                .toList();
    }
}
