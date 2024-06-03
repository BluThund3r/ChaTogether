package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;

public class UserNotInVideoRoom extends BadRequestException {
    public UserNotInVideoRoom() {
        super("User is not in the video room");
    }

    public UserNotInVideoRoom(String message) {
        super(message);
    }
}
