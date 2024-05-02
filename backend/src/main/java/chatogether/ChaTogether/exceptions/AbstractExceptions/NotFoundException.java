package chatogether.ChaTogether.exceptions.AbstractExceptions;

import org.springframework.http.HttpStatus;

abstract public class NotFoundException extends CustomException {
    @Override
    public HttpStatus getStatus() {
        return HttpStatus.NOT_FOUND;
    }

    public NotFoundException(String message) {
        super(message);
    }
}
