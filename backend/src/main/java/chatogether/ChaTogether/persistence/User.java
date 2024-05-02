package chatogether.ChaTogether.persistence;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    @JsonIgnore
    private String passwordHash;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false)
    private Boolean online = false;

    @JsonIgnore
    @Column(nullable = false)
    private Boolean confirmedMail = false;

    @JsonIgnore
    @Column(unique = true)
    private String confirmationToken;

    @JsonIgnore
    private LocalDateTime tokenExpiration;

    @JsonIgnore
    private Integer emailConfirmationTrials = 1;

    @JsonIgnore
    @Column(nullable = true)
    private String publicKey;


    @JsonIgnore
    @Column(nullable = true)
    private String encryptedPrivateKey;

    public Boolean exceededEmailConfirmationTrials() {
        return emailConfirmationTrials > 3;
    }

    public String getFullName() {
        return firstName + " " + lastName;
    }
}