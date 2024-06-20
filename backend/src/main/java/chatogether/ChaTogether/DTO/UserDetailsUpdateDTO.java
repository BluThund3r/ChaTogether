package chatogether.ChaTogether.DTO;

import lombok.Data;

@Data
public class UserDetailsUpdateDTO {
    private String username;
    private String email;
    private String firstName;
    private String lastName;
}
