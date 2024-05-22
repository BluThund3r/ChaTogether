package chatogether.ChaTogether.persistence;

import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Builder
@Document
public class ChatMessage {
    @Id
    private Long id;
    private String chatRoomId;
    private String content;
}
