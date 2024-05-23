package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.ChatMessage;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends MongoRepository<ChatMessage, Long> {
    List<ChatMessage> findByChatRoomId(String roomId);
}
