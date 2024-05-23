package chatogether.ChaTogether.persistence;

import chatogether.ChaTogether.ChatMessageType;
import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Builder
@Document
public class ChatMessage {
    @Id
    private Long id;
    private Long chatRoomId;
    private String contentOrPath;
    private ChatMessageType type;
    private Boolean isEdited;
    private LocalDateTime sentAt;
    private Long senderId;
    private Boolean isDeleted;
}
