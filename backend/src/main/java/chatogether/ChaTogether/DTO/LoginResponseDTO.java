package chatogether.ChaTogether.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponseDTO {
    private String token;
    private String publicKey;
    private String encryptedPrivateKey;
}
