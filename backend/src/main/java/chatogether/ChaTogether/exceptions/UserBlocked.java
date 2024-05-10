package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class UserBlocked extends ConflictException {
    public UserBlocked(String message) {
        super(message);
    }
}
