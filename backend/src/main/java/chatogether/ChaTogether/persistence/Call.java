package chatogether.ChaTogether.persistence;

import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Document
@Builder
public class Call {
    @Id
    @Indexed
    private String id;
    private String chatRoomId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private List<Long> participantsIds;
}
