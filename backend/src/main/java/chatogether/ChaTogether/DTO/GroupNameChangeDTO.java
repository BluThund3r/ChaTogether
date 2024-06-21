package chatogether.ChaTogether.DTO;

import lombok.Data;

@Data
public class GroupNameChangeDTO {
    private String chatRoomId;
    private String newGroupName;
}
