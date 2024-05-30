package chatogether.ChaTogether.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeysDTO {
    private String publicKey;
    private String encryptedPrivateKey;
}
