package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class UsersBlocked extends ForbiddenException {
    public UsersBlocked(String message) {
        super(message);
    }

    public UsersBlocked() {
        super("Users have blocked each other");
    }
}
