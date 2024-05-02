package chatogether.ChaTogether.exceptionHandlers;

import chatogether.ChaTogether.exceptions.AbstractExceptions.CustomException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<?> handleCustomException(RuntimeException e) {
        if (e instanceof CustomException customException) {
            return ResponseEntity.status(customException.getStatus()).body(customException.getMessage());
        }
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Internal server error");
    }
}
