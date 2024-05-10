package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.FriendRequest;
import chatogether.ChaTogether.persistence.User;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class FriendRequestDTO {
    private User sender;
    private User receiver;
    private LocalDateTime sentAt;

    public FriendRequestDTO(FriendRequest friendRequest) {
        this.sender = friendRequest.getSender();
        this.receiver = friendRequest.getReceiver();
        this.sentAt = friendRequest.getSentAt();
    }
}
