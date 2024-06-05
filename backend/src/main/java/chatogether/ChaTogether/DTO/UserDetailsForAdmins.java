package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.User;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UserDetailsForAdmins extends UserDetailsForOthersDTO {
    private Boolean isAppAdmin;

    public UserDetailsForAdmins(User user) {
        super(user);
        this.isAppAdmin = user.getIsAdmin();
    }
}
