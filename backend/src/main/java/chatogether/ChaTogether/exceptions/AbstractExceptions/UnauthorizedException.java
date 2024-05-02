package chatogether.ChaTogether.exceptions.AbstractExceptions;

import org.springframework.http.HttpStatus;

abstract public class UnauthorizedException extends CustomException {
    @Override
    public HttpStatus getStatus() {
        return HttpStatus.UNAUTHORIZED;
    }

    public UnauthorizedException(String message) {
        super(message);
    }
}
