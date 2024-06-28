package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;

public class UserNotInCall extends BadRequestException {
    public UserNotInCall() {
        super("User is not in a call");
    }
}
