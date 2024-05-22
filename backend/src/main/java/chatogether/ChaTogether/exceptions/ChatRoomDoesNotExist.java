package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.NotFoundException;

public class ChatRoomDoesNotExist extends NotFoundException {
    public ChatRoomDoesNotExist(String message) {
        super(message);
    }

    public ChatRoomDoesNotExist() {
        super("Chat room does not exist");
    }
}
