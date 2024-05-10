package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class UsersAlreadyFriends extends ConflictException {
    public UsersAlreadyFriends() {
        super("Users are already friends");
    }
}
