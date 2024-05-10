package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;

public class UserNotBlocked extends BadRequestException {
    public UserNotBlocked() {
        super("User is not blocked");
    }
}
