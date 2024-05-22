package chatogether.ChaTogether.utils;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;


public class CryptoUtils {

    public static enum KeyType {
        PUBLIC,
        PRIVATE
    }

    public static SecretKey generateAESKey(int keySizeBits) {
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
            keyGen.init(keySizeBits);
            return keyGen.generateKey();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static SecretKey generateAESKey() {
        return generateAESKey(256);
    }

    public static Key stringToRSAKey(String keyString, KeyType keyType) {
        try {
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            byte[] keyBytes = Base64.getDecoder().decode(keyString);

            Key key;
            if (keyType == KeyType.PUBLIC) {
                X509EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(keyBytes);
                key = keyFactory.generatePublic(publicKeySpec);
            } else if (keyType == KeyType.PRIVATE) {
                PKCS8EncodedKeySpec privateKeySpec = new PKCS8EncodedKeySpec(keyBytes);
                key = keyFactory.generatePrivate(privateKeySpec);
            } else {
                throw new IllegalArgumentException("Invalid key type: " + keyType);
            }
            return key;
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String rsaKeyToString(Key key) {
        byte[] keyBytes = key.getEncoded();
        return Base64.getEncoder().encodeToString(keyBytes);
    }

    public static SecretKey stringToAESKey(String keyString) {
        byte[] decodedKey = Base64.getDecoder().decode(keyString);
        return new SecretKeySpec(decodedKey, 0, decodedKey.length, "AES");
    }

    public static String aesKeyToString(SecretKey secretKey) {
        byte[] rawData = secretKey.getEncoded();
        return Base64.getEncoder().encodeToString(rawData);
    }

    public static byte[] encryptWithRSA(byte[] plaintext, String publicKeyString) {
        PublicKey publicKey = (PublicKey) stringToRSAKey(publicKeyString, KeyType.PUBLIC);
        return encryptWithRSA(plaintext, publicKey);
    }

    public static byte[] encryptWithRSA(byte[] plaintext, PublicKey publicKey) {
        try {
            Cipher encryptCipher = Cipher.getInstance("RSA");
            encryptCipher.init(Cipher.ENCRYPT_MODE, publicKey);
            return encryptCipher.doFinal(plaintext);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
