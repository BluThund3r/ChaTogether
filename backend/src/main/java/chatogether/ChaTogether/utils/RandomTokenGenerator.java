package chatogether.ChaTogether.utils;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;

public class RandomTokenGenerator {
    private static final String ALPHANUMERIC_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    public static String generateToken(int length) {
        var random = new SecureRandom();
        StringBuilder tokenBuilder = new StringBuilder();
        for (int i = 0; i < length; i++) {
            int index = random.nextInt(ALPHANUMERIC_CHARACTERS.length());
            tokenBuilder.append(ALPHANUMERIC_CHARACTERS.charAt(index));
        }
        return tokenBuilder.toString();
    }

    public static String generateMailConfirmationToken() {
        return generateToken(10);
    }
}
