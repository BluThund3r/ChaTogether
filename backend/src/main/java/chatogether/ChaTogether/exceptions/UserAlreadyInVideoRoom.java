package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ConflictException;

public class UserAlreadyInVideoRoom extends ConflictException {
    public UserAlreadyInVideoRoom() {
        super("User is already in the video room");
    }

    public UserAlreadyInVideoRoom(String message) {
        super(message);
    }
}
