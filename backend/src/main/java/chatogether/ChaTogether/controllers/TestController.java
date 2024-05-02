package chatogether.ChaTogether.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;

@RestController
@RequestMapping("/test")
public class TestController {
    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public String test() {
        return "Test";
    }

    @GetMapping(path="/hello")
    public ResponseEntity<?> hello() {
        return ResponseEntity.ok("Hello");
    }

    private byte[] getEncryptedPassword(String password, byte[] salt, int iterations, int derivedKeyLength) throws NoSuchAlgorithmException, InvalidKeySpecException {
        KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, derivedKeyLength * 8);
        SecretKeyFactory f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        return f.generateSecret(spec).getEncoded();
    }

    @GetMapping(path="/getDerivedKey/{password}")
    public ResponseEntity<?> getDerivedKey(
            @PathVariable String password
    ) {
        byte[] salt = "salt".getBytes();
        int iterations = 1000;
        int derivedKeyLength = 256;
        try {
            byte[] derivedKey = getEncryptedPassword(password, salt, iterations, derivedKeyLength);
            return ResponseEntity.ok(new String(derivedKey));
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}
