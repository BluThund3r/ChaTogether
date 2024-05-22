package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class UserNotInChatRoom extends ForbiddenException {
    public UserNotInChatRoom() {
        super("User is not part of this chat");
    }
}
