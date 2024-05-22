package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.ChatRoom;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChatRoomRepository extends MongoRepository<ChatRoom, Long> {
}
