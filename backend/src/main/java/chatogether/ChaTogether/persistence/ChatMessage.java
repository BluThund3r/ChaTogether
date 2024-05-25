package chatogether.ChaTogether.persistence;

import chatogether.ChaTogether.enums.ChatMessageType;
import lombok.Builder;
import lombok.Data;
import org.hibernate.annotations.Index;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@Document
public class ChatMessage {
    @Id
    @Indexed
    private Long id;
    @Indexed
    private Long chatRoomId;
    private String contentOrPath;
    private ChatMessageType type;
    private Boolean isEdited;
    @Indexed
    private LocalDateTime sentAt;
    private Long senderId;
    private Boolean isDeleted;
    private List<Long> seenBy;
}
