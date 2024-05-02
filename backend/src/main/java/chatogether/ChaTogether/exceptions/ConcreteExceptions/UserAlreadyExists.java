package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;
import org.springframework.http.HttpStatus;

public class UserAlreadyExists extends ConflictException {
    public UserAlreadyExists(String message) {
        super(message);
    }

    public UserAlreadyExists() {
        this("User already exists");
    }
}
