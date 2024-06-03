package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class UserAlreadyInChatRoom extends ConflictException {
    public UserAlreadyInChatRoom() {
        super("User is already in the chat room");
    }

    public UserAlreadyInChatRoom(String message) {
        super(message);
    }
}
