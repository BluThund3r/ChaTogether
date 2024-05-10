package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.FriendRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendRequestRepository extends JpaRepository<FriendRequest, Long> {
    @Query("select fr from FriendRequest fr where fr.receiver.username = :username")
    List<FriendRequest> getReceivedFriendRequestsOfUser(String username);

    @Query("select fr from FriendRequest fr where fr.sender.username = :username")
    List<FriendRequest> getSentFriendRequestsOfUser(String username);

    @Query("select fr from FriendRequest fr where fr.sender.username = :sender and fr.receiver.username = :receiver")
    Optional<FriendRequest> getFriendRequest(String sender, String receiver);
}
