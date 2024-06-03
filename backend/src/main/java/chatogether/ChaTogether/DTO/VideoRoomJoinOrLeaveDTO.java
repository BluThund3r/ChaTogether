package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.enums.JoinOrLeave;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class VideoRoomJoinOrLeaveDTO {
    private String connectionCode;
    private JoinOrLeave action;
    private UserDetailsForOthersDTO userDetails;
}
