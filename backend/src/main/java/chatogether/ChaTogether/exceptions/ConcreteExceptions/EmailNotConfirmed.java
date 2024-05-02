package chatogether.ChaTogether.exceptions.ConcreteExceptions;

import chatogether.ChaTogether.exceptions.AbstractExceptions.ForbiddenException;

public class EmailNotConfirmed extends ForbiddenException {

    public EmailNotConfirmed() {
        super("Email not confirmed");
    }
}
