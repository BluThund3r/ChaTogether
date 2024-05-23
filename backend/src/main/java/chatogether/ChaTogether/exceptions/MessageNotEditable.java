package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class MessageNotEditable extends ForbiddenException {
    public MessageNotEditable(String message) {
        super(message);
    }

    public MessageNotEditable() {
        super("Message is not editable");
    }
}
