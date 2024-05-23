package chatogether.ChaTogether.DTO;

import lombok.Data;

import java.util.List;

@Data
public class CreateGroupChatDTO {
    private String chatRoomName;
    private List<String> memberUsernames;
}
