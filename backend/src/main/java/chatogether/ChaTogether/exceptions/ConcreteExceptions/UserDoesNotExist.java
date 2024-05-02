package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.NotFoundException;
import org.springframework.http.HttpStatus;

public class UserDoesNotExist extends NotFoundException {
    public UserDoesNotExist() {
        super("User does not exist");
    }
}
