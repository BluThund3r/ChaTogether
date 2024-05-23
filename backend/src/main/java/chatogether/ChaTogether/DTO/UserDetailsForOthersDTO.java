package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.User;
import lombok.Data;

import java.nio.file.Paths;

@Data
public class UserDetailsForOthersDTO {
    private Long id;
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private Boolean online;
    private Boolean isAdminInChat = false;

    public UserDetailsForOthersDTO(User user, Boolean isAdminInChat) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.email = user.getEmail();
        this.online = user.getOnline();
        this.isAdminInChat = isAdminInChat;
    }
}
