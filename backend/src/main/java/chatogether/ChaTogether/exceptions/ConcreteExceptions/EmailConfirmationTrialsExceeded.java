package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;
import org.springframework.http.HttpStatus;

public class EmailConfirmationTrialsExceeded extends ForbiddenException {
    public EmailConfirmationTrialsExceeded() {
        super("Email confirmation trials exceeded");
    }
}
