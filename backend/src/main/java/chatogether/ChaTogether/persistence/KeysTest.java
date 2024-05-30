package chatogether.ChaTogether.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "keys_test")
@AllArgsConstructor
@NoArgsConstructor
@Data
public class KeysTest {
    @Id
    private String username;

    //    @Column(length = 5000)
    private String privateKey;

    //    @Column(length = 5000)
    private String publicKey;
}
