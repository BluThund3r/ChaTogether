package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class UserAddDenied extends ForbiddenException {
    public UserAddDenied(String message) {
        super(message);
    }

    public UserAddDenied() {
        super("User add denied");
    }
}
