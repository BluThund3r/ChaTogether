package chatogether.ChaTogether.persistence;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "stats")
public class Stats {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private Integer month;
    private Integer year;
    private Integer newUsersCount = 0;
    private Integer videoRoomsCount = 0;
    private Integer groupChatsCount = 0;
    private Integer privateChatsCount = 0;
}
