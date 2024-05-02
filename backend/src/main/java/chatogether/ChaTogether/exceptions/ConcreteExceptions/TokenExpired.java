package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.UnauthorizedException;
import org.springframework.http.HttpStatus;

public class TokenExpired extends UnauthorizedException {
    public TokenExpired() {
        super("Token expired");
    }
}
