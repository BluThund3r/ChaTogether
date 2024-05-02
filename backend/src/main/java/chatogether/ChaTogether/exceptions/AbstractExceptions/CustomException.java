package chatogether.ChaTogether.exceptions.AbstractExceptions;

import org.springframework.http.HttpStatus;

abstract public class CustomException extends RuntimeException {
    abstract public HttpStatus getStatus();

    public CustomException(String message) {
        super(message);
    }
}
