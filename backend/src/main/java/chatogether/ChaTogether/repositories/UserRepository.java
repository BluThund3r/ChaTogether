package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.Set;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    Optional<User> findByConfirmationToken(String confirmationToken);

    @Query("SELECT u FROM User u WHERE u.username = :usernameOrEmail OR u.email = :usernameOrEmail")
    Optional<User> findByUsernameOrEmail(String usernameOrEmail);

    @Query("SELECT u FROM User u WHERE u.username LIKE %:searchString%")
    Set<User> findByUsernameContaining(String searchString);

    @Query("SELECT u FROM User u WHERE u.firstName || ' ' || u.lastName LIKE %:searchString% or u.lastName || ' ' || u.firstName LIKE %:searchString%")
    Set<User> findByNameContaining(String searchString);
}
    