package chatogether.ChaTogether.DTO;

import lombok.Data;

@Data
public class AddUserToChatDTO {
    private Long chatRoomId;
    private Long userId;
    private String encryptedKey;
}
