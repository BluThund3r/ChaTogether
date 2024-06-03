package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.NotFoundException;

public class VideoRoomDoesNotExist extends NotFoundException {
    public VideoRoomDoesNotExist() {
        super("Video room does not exist");
    }

    public VideoRoomDoesNotExist(String message) {
        super(message);
    }
}
