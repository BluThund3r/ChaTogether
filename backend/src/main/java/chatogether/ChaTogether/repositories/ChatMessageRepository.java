package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.ChatMessage;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ChatMessageRepository extends MongoRepository<ChatMessage, Long> {
    List<ChatMessage> findByChatRoomId(String roomId);

    @Query("{ 'chatRoomId' : ?0, 'timestamp' : { $lt: ?1 } }")
    List<ChatMessage> findByChatRoomIdBefore(Long chatRoomId, LocalDateTime beforeTimestamp);
}
