package chatogether.ChaTogether.exceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class NotAppAdmin extends ForbiddenException {
    public NotAppAdmin() {
        super("You are not an app admin.");
    }
}
