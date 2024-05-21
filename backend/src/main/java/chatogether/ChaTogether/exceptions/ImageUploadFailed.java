package chatogether.ChaTogether.exceptions;

public class ImageUploadFailed extends InternalError {
    public ImageUploadFailed() {
        super("Image upload failed");
    }

    public ImageUploadFailed(String message) {
        super(message);
    }
}
