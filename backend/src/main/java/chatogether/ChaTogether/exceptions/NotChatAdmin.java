package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class NotChatAdmin extends ForbiddenException {
    public NotChatAdmin() {
        super("You are not an admin of this chat");
    }
}
