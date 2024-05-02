package chatogether.ChaTogether.utils;

import java.util.regex.Pattern;

public class RegexValidator {
    private final static String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    private final static String usernameRegex = "^[a-zA-Z_][a-zA-Z0-9._]{3,19}$";
    private final static String passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!?()*\\[\\]+\\-_.,:;<=>@'\"])[A-Za-z\\d!?()*\\[\\]+\\-_.,:;<=>@'\"]{8,}$";
    private final static String nameRegex = "^\\b([A-ZÀ-ÿ][-,a-z. ']+ *)+$";

    public static boolean validateEmail(String email) {
        return Pattern.compile(emailRegex).matcher(email).matches();
    }

    public static boolean validateUsername(String username) {
        return Pattern.compile(usernameRegex).matcher(username).matches();
    }

    public static boolean validatePassword(String password) {
        return Pattern.compile(passwordRegex).matcher(password).matches();
    }

    public static boolean validateName(String name) {
        return Pattern.compile(nameRegex).matcher(name).matches();
    }
}
