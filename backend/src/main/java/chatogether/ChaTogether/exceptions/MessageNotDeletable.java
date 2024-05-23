package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class MessageNotDeletable extends ForbiddenException {
    public MessageNotDeletable(String message) {
        super(message);
    }

    public MessageNotDeletable() {
        super("Message is not deletable");
    }
}
