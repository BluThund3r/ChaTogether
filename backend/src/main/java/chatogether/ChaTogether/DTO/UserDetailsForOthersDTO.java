package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.User;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.nio.file.Paths;

@Data
@NoArgsConstructor
public class UserDetailsForOthersDTO {
    protected Long id;
    protected String username;
    protected String firstName;
    protected String lastName;
    protected String email;
    protected Boolean online;
    protected Boolean isAdminInChat = false;

    public UserDetailsForOthersDTO(User user, Boolean isAdminInChat) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.email = user.getEmail();
        this.online = user.getOnline();
        this.isAdminInChat = isAdminInChat;
    }

    public UserDetailsForOthersDTO(User user) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.email = user.getEmail();
        this.online = user.getOnline();
        this.isAdminInChat = false;
    }
}
