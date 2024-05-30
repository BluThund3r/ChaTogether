package chatogether.ChaTogether.DTO;

import lombok.Data;

@Data
public class AddUserToChatDTO {
    private String chatRoomId;
    private Long userId;
    private String encryptedKey;
}
