package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;

public class MessageNotAnImage extends BadRequestException {
    public MessageNotAnImage() {
        super("Message is not an image");
    }
}
