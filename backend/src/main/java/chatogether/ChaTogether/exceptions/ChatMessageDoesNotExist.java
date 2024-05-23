package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.NotFoundException;

public class ChatMessageDoesNotExist extends NotFoundException {
    public ChatMessageDoesNotExist() {
        super("Chat message does not exist");
    }
}
