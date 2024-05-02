package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.BadRequestException;
import org.springframework.http.HttpStatus;

public class InvalidItem extends BadRequestException {
    public InvalidItem(String invalidItem) {
        super(String.format("%s address is not valid", invalidItem));
    }
}