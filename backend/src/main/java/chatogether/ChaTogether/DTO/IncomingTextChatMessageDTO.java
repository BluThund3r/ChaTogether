package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.enums.ChatMessageType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class IncomingTextChatMessageDTO {
    private String encryptedContent;
    private ChatMessageType type;
}
