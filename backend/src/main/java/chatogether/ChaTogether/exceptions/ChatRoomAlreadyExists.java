package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class ChatRoomAlreadyExists extends ConflictException {
    public ChatRoomAlreadyExists(String message) {
        super(message);
    }

    public ChatRoomAlreadyExists() {
        super("Chat room already exists");
    }
}
