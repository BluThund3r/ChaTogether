package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;
import org.springframework.http.HttpStatus;

public class EmailAlreadyConfirmed extends ConflictException {
    public EmailAlreadyConfirmed() {
        super("Email already confirmed");
    }
}
