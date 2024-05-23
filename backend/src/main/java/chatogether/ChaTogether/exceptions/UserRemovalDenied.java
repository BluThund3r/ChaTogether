package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class UserRemovalDenied extends ForbiddenException {
    public UserRemovalDenied() {
        super("User removal denied");
    }

    public UserRemovalDenied(String message) {
        super(message);
    }
}
