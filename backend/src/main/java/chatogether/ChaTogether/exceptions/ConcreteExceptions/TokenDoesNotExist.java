package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.NotFoundException;
import org.springframework.http.HttpStatus;

public class TokenDoesNotExist extends NotFoundException {
    public TokenDoesNotExist() {
        super("Token does not exist");
    }
}
