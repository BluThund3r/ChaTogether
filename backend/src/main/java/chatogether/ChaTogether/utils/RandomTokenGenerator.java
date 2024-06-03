package chatogether.ChaTogether.utils;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;

public class RandomTokenGenerator {
    private static final String ALPHANUMERIC_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    private static final String NUMERIC_CHARACTERS = "0123456789";

    public static String generateToken(int length, String characters) {
        var random = new SecureRandom();
        StringBuilder tokenBuilder = new StringBuilder();
        for (int i = 0; i < length; i++) {
            int index = random.nextInt(characters.length());
            tokenBuilder.append(characters.charAt(index));
        }
        return tokenBuilder.toString();
    }

    public static String generateMailConfirmationToken() {
        return generateToken(10, ALPHANUMERIC_CHARACTERS);
    }

    public static String generateVideoRoomConnectionCode() {
        return generateToken(6, NUMERIC_CHARACTERS);
    }
}
