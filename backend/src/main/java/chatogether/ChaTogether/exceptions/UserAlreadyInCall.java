package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class UserAlreadyInCall extends ConflictException {
    public UserAlreadyInCall() {
        super("User is already in a call");
    }
}
