package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;
import org.springframework.http.HttpStatus;

public class PasswordsDoNotMatch extends BadRequestException {

    public PasswordsDoNotMatch(String message) {
        super(message);
    }

    public PasswordsDoNotMatch() {
        super("Passwords do not match");
    }
}
