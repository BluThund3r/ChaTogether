package chatogether.ChaTogether.persistence;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Data
@Entity
@Table(name = "users")
public class User {
    @JsonIgnore
    private static final Integer MAX_EMAIL_CONFIRMATION_TRIALS = 3;
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
    @Column(nullable = true, length = 3000)
    private String publicKey;

    @JsonIgnore
    @Column(nullable = true, length = 10000)
    private String encryptedPrivateKey;

    private Boolean isAdmin = false;

    private String directoryName;

    @JsonIgnore
    @OneToMany(mappedBy = "receiver")
    private Set<FriendRequest> receivedFriendRequests = new HashSet<>();

    @JsonIgnore
    @OneToMany(mappedBy = "sender")
    private Set<FriendRequest> sentFriendRequests = new HashSet<>();

    @ManyToMany
    @JoinTable(
            name = "friendship",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "friend_id")
    )
    @JsonIgnore
    private Set<User> friends = new HashSet<>();

    @ManyToMany
    @JoinTable(
            name = "blocked_users",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "blocked_user_id")
    )
    @JsonIgnore
    @Fetch(FetchMode.JOIN)
    private Set<User> blockedUsers = new HashSet<>();

    public Boolean exceededEmailConfirmationTrials() {
        return emailConfirmationTrials > MAX_EMAIL_CONFIRMATION_TRIALS;
    }

    public Integer getMaxEmailConfirmationTrials() {
        return MAX_EMAIL_CONFIRMATION_TRIALS;
    }

    public Integer getEmailConfirmationsRemaining() {
        return MAX_EMAIL_CONFIRMATION_TRIALS - emailConfirmationTrials;
    }

    public String getFullName() {
        return firstName + " " + lastName;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        User user = (User) o;

        return id.equals(user.id);
    }

    @Override
    public int hashCode() {
        int result = id.hashCode();
        result = 31 * result + username.hashCode();
        result = 31 * result + passwordHash.hashCode();
        result = 31 * result + email.hashCode();
        result = 31 * result + firstName.hashCode();
        result = 31 * result + lastName.hashCode();
        result = 31 * result + online.hashCode();
        result = 31 * result + confirmedMail.hashCode();
        result = 31 * result + confirmationToken.hashCode();
        result = 31 * result + tokenExpiration.hashCode();
        result = 31 * result + emailConfirmationTrials.hashCode();
        result = 31 * result + (publicKey != null ? publicKey.hashCode() : 0);
        result = 31 * result + (encryptedPrivateKey != null ? encryptedPrivateKey.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", online=" + online +
                ", confirmedMail=" + confirmedMail +
                '}';
    }
}