package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.ChatMessage;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ChatMessageRepository extends MongoRepository<ChatMessage, String> {
    List<ChatMessage> findByChatRoomId(String roomId);

    @Query(value = "{ 'chatRoomId' : ?0, 'sentAt' : { $lt: ?1 } }", sort = "{ 'sentAt' : 1 }")
    List<ChatMessage> findByChatRoomIdBeforeAndLimited(String chatRoomId, LocalDateTime beforeTimestamp, Pageable pageable);

    @Query(value = "{ 'chatRoomId' : ?0 }", sort = "{ 'sentAt' : -1 }")
    List<ChatMessage> findLatestByChatRoomId(String chatRoomId, Pageable pageable);

    @Query("{ 'chatRoomId': ?0, 'seenBy': { '$nin': [?1] } }")
    List<ChatMessage> findUnseenMessagesByRoomId(String chatRoomId, Long userId);
}
