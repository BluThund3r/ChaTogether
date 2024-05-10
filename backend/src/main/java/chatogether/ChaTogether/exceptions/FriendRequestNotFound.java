package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.NotFoundException;

public class FriendRequestNotFound extends NotFoundException {
    public FriendRequestNotFound() {
        super("Friend request not found");
    }
}
