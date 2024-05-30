package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.LoginRequestDTO;
import chatogether.ChaTogether.DTO.MailConfirmationRequestDTO;
import chatogether.ChaTogether.DTO.RegisterRequestDTO;
import chatogether.ChaTogether.DTO.ResendConfirmationEmailRequestDTO;
import chatogether.ChaTogether.services.AuthService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@AllArgsConstructor
public class AuthController {
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(
            @RequestBody RegisterRequestDTO registerRequestDTO
    ) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        authService.registerUser(
                                registerRequestDTO.getUsername(),
                                registerRequestDTO.getPassword(),
                                registerRequestDTO.getConfirmPassword(),
                                registerRequestDTO.getEmail(),
                                registerRequestDTO.getFirstName(),
                                registerRequestDTO.getLastName(),
                                registerRequestDTO.getPublicKey(),
                                registerRequestDTO.getEncryptedPrivateKey()
                        )
                );
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(
            @RequestBody LoginRequestDTO loginRequestDTO
    ) {
        return ResponseEntity.ok(
                authService.login(
                        loginRequestDTO.getUsernameOrEmail(),
                        loginRequestDTO.getPassword()
                ));
    }

    @PostMapping("/confirmEmail")
    public ResponseEntity<?> confirmEmail(
            @RequestBody MailConfirmationRequestDTO mailConfirmationDTO
    ) {
        authService.confirmEmail(mailConfirmationDTO.getToken());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/getRemainingEmailConfirmationTrials")
    public ResponseEntity<?> getRemainingEmailConfirmationTrials(
            @RequestParam String email
    ) {
        return ResponseEntity.ok(authService.getRemainingEmailConfirmationTrials(email));
    }

    @PostMapping("/resendConfirmationEmail")
    public ResponseEntity<?> resendConfirmationEmail(
            @RequestBody ResendConfirmationEmailRequestDTO confirmationDTO
    ) {
        authService.resendConfirmationEmail(confirmationDTO.getEmail());
        return ResponseEntity.ok().build();
    }
}
