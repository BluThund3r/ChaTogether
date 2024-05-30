package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.KeyPostDTO;
import chatogether.ChaTogether.DTO.TestEncryptDTO;
import chatogether.ChaTogether.persistence.KeysTest;
import chatogether.ChaTogether.repositories.KeyTestRepository;
import chatogether.ChaTogether.utils.CryptoUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.util.Base64;

@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestController {
    private final KeyTestRepository keyTestRepository;

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public String test() {
        return "Test";
    }

    @GetMapping(path = "/hello")
    public ResponseEntity<?> hello() {
        return ResponseEntity.ok("Hello");
    }

    private byte[] getEncryptedPassword(String password, byte[] salt, int iterations, int derivedKeyLength) throws NoSuchAlgorithmException, InvalidKeySpecException {
        KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, derivedKeyLength * 8);
        SecretKeyFactory f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        return f.generateSecret(spec).getEncoded();
    }

    @GetMapping(path = "/getDerivedKey/{password}")
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

    @PostMapping(path = "postKeys")
    public void postKeys(
            @RequestBody KeysTest keyPostDTO
    ) {
        keyTestRepository.save(keyPostDTO);
    }

    @GetMapping(path = "/getKeys/{username}")
    public ResponseEntity<?> getKeys(
            @PathVariable String username
    ) {
        var keys = keyTestRepository.findById(username);
        if (keys.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(keys.get());
    }

    @PostMapping(path = "/encrypt")
    public ResponseEntity<?> encrypt(
            @RequestBody TestEncryptDTO testEncryptDTO
    ) {
        var keyTest = keyTestRepository.findById(testEncryptDTO.getUsername()).orElseThrow();
        var encrypted = CryptoUtils.encryptWithRSA(testEncryptDTO.getPlaintext().getBytes(), keyTest.getPublicKey());
        return ResponseEntity.ok(Base64.getEncoder().encodeToString(encrypted));
    }
}
