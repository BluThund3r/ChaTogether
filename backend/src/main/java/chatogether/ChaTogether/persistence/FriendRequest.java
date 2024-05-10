package chatogether.ChaTogether.persistence;

import jakarta.persistence.*;
import lombok.Data;
import org.springframework.data.annotation.CreatedDate;

import java.time.LocalDateTime;

@Entity
@Data
@Table(
        name = "friend_requests",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"sender_id", "receiver_id"}),
                @UniqueConstraint(columnNames = {"receiver_id", "sender_id"})
        }
)
public class FriendRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    User sender;

    @ManyToOne
    User receiver;

    @CreatedDate
    private LocalDateTime sentAt = LocalDateTime.now();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        FriendRequest that = (FriendRequest) o;

        return id.equals(that.id);
    }

    @Override
    public int hashCode() {
        int result = id.hashCode();
        result = 31 * result + sentAt.hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "FriendRequest{" +
                "id=" + id +
                ", sentAt=" + sentAt +
                '}';
    }
}
