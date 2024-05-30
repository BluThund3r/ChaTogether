package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.ChatRoom;
import org.springframework.data.mongodb.repository.Aggregation;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChatRoomRepository extends MongoRepository<ChatRoom, String> {
    @Aggregation(pipeline = {
            "{ $match: { 'maxUsers': 2 } }",
            "{ $match: { 'encryptedKeys.?0': { $exists: true }, 'encryptedKeys.?1': { $exists: true } } }"
    })
    Optional<ChatRoom> findPrivateByUserIds(Long userId1, Long userId2);
}
