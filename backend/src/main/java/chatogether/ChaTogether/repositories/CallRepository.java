package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.Call;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CallRepository extends MongoRepository<Call, String> {
    @Query("{ 'chatRoomId': ?0, 'startTime': { '$gt': ?1 } }")
    public List<Call> findByChatRoomIdAfter(String chatRoomId, LocalDateTime after);
}
