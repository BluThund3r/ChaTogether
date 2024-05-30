package chatogether.ChaTogether.utils;

import org.springframework.vault.support.PemObject;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;
import javax.crypto.spec.SecretKeySpec;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.MGF1ParameterSpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;


public class CryptoUtils {

    public static enum KeyType {
        PUBLIC,
        PRIVATE
    }

    public static final int AES_KEY_SIZE = 256;
    public static final int IV_SIZE = 16;

    private final static String RSA_VARIANT = "RSA/ECB/OAEPWithSHA-256AndMGF1Padding";

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
        return generateAESKey(AES_KEY_SIZE);
    }

    public static byte[] generateIV() {
        try {
            byte[] ivBytes = new byte[IV_SIZE];

            SecureRandom secureRandom = new SecureRandom();
            secureRandom.nextBytes(ivBytes);

            IvParameterSpec ivSpec = new IvParameterSpec(ivBytes);

            return ivSpec.getIV();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String rsaKeyToString(Key key) {
        String keyType;
        if (key instanceof PrivateKey) {
            keyType = "PRIVATE";
        } else if (key instanceof PublicKey) {
            keyType = "PUBLIC";
        } else {
            throw new IllegalArgumentException("Invalid key type: " + key.getClass().getName());
        }

        byte[] keyBytes = key.getEncoded();
        String keyString = Base64.getEncoder().encodeToString(keyBytes);

        return "-----BEGIN RSA " + keyType + " KEY-----\n" +
                keyString +
                "-----END RSA " + keyType + " KEY-----\n";
    }

    public static SecretKey stringToAESKey(String keyString) {
        byte[] decodedKey = Base64.getDecoder().decode(keyString);
        return new SecretKeySpec(decodedKey, 0, decodedKey.length, "AES");
    }

    public static String aesKeyToString(SecretKey secretKey) {
        byte[] rawData = secretKey.getEncoded();
        return Base64.getEncoder().encodeToString(rawData);
    }

    public static Key stringToRSAKey(String keyStringPEM, KeyType keyType) {
        String keyString;

        if (keyType == KeyType.PRIVATE) {
            keyString = keyStringPEM
                    .replace("-----BEGIN PRIVATE KEY-----", "")
                    .replace("-----END PRIVATE KEY-----", "")
                    .replaceAll("\\s", "");
        } else {
            keyString = keyStringPEM
                    .replace("-----BEGIN PUBLIC KEY-----", "")
                    .replace("-----END PUBLIC KEY-----", "")
                    .replaceAll("\\s", "");
        }

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

    public static byte[] encryptWithRSA(byte[] plaintext, String publicKeyString) {
        PublicKey publicKey = (PublicKey) stringToRSAKey(publicKeyString, KeyType.PUBLIC);
        return encryptWithRSA(plaintext, publicKey);
    }

    public static byte[] encryptWithRSA(byte[] plaintext, PublicKey publicKey) {
        try {
            OAEPParameterSpec oaepParams = new OAEPParameterSpec(
                    "SHA-256",
                    "MGF1",
                    MGF1ParameterSpec.SHA256,
                    new PSource.PSpecified("".getBytes())
            );
            Cipher encryptCipher = Cipher.getInstance(RSA_VARIANT);
            encryptCipher.init(Cipher.ENCRYPT_MODE, publicKey, oaepParams);
            return encryptCipher.doFinal(plaintext);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
