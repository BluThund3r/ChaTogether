package chatogether.ChaTogether.exceptions.AbstractExceptions;

import org.springframework.http.HttpStatus;

abstract public class ForbiddenException extends CustomException {
    @Override
    public HttpStatus getStatus() {
        return HttpStatus.FORBIDDEN;
    }

    public ForbiddenException(String message) {
        super(message);
    }
}
