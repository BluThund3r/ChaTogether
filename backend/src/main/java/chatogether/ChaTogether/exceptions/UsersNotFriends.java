package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;

public class UsersNotFriends extends BadRequestException {
    public UsersNotFriends() {
        super("Users are not friends");
    }
}
