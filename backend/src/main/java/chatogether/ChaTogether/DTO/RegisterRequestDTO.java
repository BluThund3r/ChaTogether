package chatogether.ChaTogether.DTO;

import lombok.Data;

@Data
public class RegisterRequestDTO {
    private String username;
    private String password;
    private String confirmPassword;
    private String email;
    private String firstName;
    private String lastName;
    private String publicKey;
    private String encryptedPrivateKey;
}
