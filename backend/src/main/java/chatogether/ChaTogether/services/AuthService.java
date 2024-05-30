package chatogether.ChaTogether.services;

import chatogether.ChaTogether.DTO.LoginResponseDTO;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.*;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.utils.RandomTokenGenerator;
import chatogether.ChaTogether.utils.RegexValidator;
import lombok.AllArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;

@Service
@AllArgsConstructor
public class AuthService {
    private JWTService jwtService;
    private UserService userService;
    private MailService mailService;
    private FileService fileService;

    public User registerUser(
            String username,
            String password,
            String confirmPassword,
            String email,
            String firstName,
            String lastName,
            String publicKey,
            String encryptedPrivateKey
    ) {
        if (!password.equals(confirmPassword))
            throw new PasswordsDoNotMatch();

        if (!RegexValidator.validateEmail(email))
            throw new InvalidItem("Email");

        if (!RegexValidator.validatePassword(password))
            throw new InvalidItem("Password");

        if (!RegexValidator.validateUsername(username))
            throw new InvalidItem("Username");

        if (!RegexValidator.validateName(firstName) || !RegexValidator.validateName(lastName))
            throw new InvalidItem("First name or last name");

        var userByUsername = userService.findByUsername(username);
        var userByEmail = userService.findByEmail(email);
        if (userByUsername.isPresent() || userByEmail.isPresent()) {
            throw new UserAlreadyExists();
        }

        var user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setPublicKey(publicKey);
        user.setEncryptedPrivateKey(encryptedPrivateKey);

        var hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
        user.setPasswordHash(hashedPassword);

        var hashedUsername = BCrypt.hashpw(username, BCrypt.gensalt()).replaceAll("[^a-zA-Z0-9]", "_");
        user.setDirectoryName(hashedUsername);
        try {
            fileService.createUserDirectory(user);
        } catch (IOException e) {
            throw new UserAlreadyExists();
        }

        var confirmationToken = generateEmailConfirmationToken();
        user.setConfirmationToken(confirmationToken);
        user.setTokenExpiration(LocalDateTime.now().plusHours(24));

        var savedUser = userService.saveUser(user);

        mailService.sendConfirmationEmail(email, username, firstName, lastName, confirmationToken);

        return savedUser;
    }

    public LoginResponseDTO login(String usernameOrEmail, String password) {
        var user = userService.findByUsernameOrEmail(usernameOrEmail).orElseThrow(UserDoesNotExist::new);
        if (!user.getConfirmedMail()) {
            if (user.getTokenExpiration().isBefore(LocalDateTime.now()))
                throw new TokenExpired();
            throw new EmailNotConfirmed();
        }

        if (!BCrypt.checkpw(password, user.getPasswordHash()))
            throw new PasswordsDoNotMatch("Password is incorrect");

        var claims = new HashMap<String, Object>();
        claims.put("username", user.getUsername());
        claims.put("email", user.getEmail());
        claims.put("firstName", user.getFirstName());
        claims.put("lastName", user.getLastName());
        claims.put("userId", user.getId());

        var token = jwtService.createToken(claims);
        return new LoginResponseDTO(
                token,
                user.getPublicKey(),
                user.getEncryptedPrivateKey()
        );
    }

    public void confirmEmail(String token) {
        var user = userService.findByConfirmationToken(token).orElseThrow(TokenDoesNotExist::new);
        if (user.getTokenExpiration().isBefore(LocalDateTime.now()))
            throw new TokenExpired();
        if (user.getConfirmedMail())
            throw new EmailAlreadyConfirmed();
        user.setConfirmedMail(true);
        userService.saveUser(user);
    }

    public void resendConfirmationEmail(String email) {
        var user = userService.findByEmail(email).orElseThrow(UserDoesNotExist::new);
        if (user.getConfirmedMail())
            throw new EmailAlreadyConfirmed();
        if (user.exceededEmailConfirmationTrials())
            throw new EmailConfirmationTrialsExceeded();
        var confirmationToken = generateEmailConfirmationToken();
        user.setConfirmationToken(confirmationToken);
        user.setTokenExpiration(LocalDateTime.now().plusHours(24));
        user.setEmailConfirmationTrials(user.getEmailConfirmationTrials() + 1);
        userService.saveUser(user);
        mailService.sendConfirmationEmail(
                email,
                user.getUsername(),
                user.getFirstName(),
                user.getLastName(),
                confirmationToken
        );
    }

    private String generateEmailConfirmationToken() {
        while (true) {
            var token = RandomTokenGenerator.generateMailConfirmationToken();
            if (userService.findByConfirmationToken(token).isEmpty())
                return token;
        }
    }

    public Integer getRemainingEmailConfirmationTrials(String email) {
        var user = userService.findByEmail(email).orElseThrow(UserDoesNotExist::new);
        if (user.getConfirmedMail())
            throw new EmailAlreadyConfirmed();
        return user.getEmailConfirmationsRemaining();
    }
}
