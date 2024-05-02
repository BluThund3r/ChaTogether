package chatogether.ChaTogether.exceptions.AbstractExceptions;

import org.springframework.http.HttpStatus;

abstract public class ConflictException extends CustomException {
    @Override
    public HttpStatus getStatus() {
        return HttpStatus.CONFLICT;
    }

    public ConflictException(String message) {
        super(message);
    }
}
