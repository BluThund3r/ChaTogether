package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class UserAlreadyBlocked extends ConflictException {
    public UserAlreadyBlocked() {
        super("User is already blocked");
    }
}
