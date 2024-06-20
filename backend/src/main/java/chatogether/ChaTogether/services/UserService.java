package chatogether.ChaTogether.services;

import chatogether.ChaTogether.DTO.KeysDTO;
import chatogether.ChaTogether.DTO.UserDetailsUpdateDTO;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserAlreadyExists;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.exceptions.UsersAlreadyFriends;
import chatogether.ChaTogether.exceptions.UsersNotFriends;
import chatogether.ChaTogether.persistence.User;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import chatogether.ChaTogether.repositories.UserRepository;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
public class UserService {

    private UserRepository userRepository;

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByUsernameOrEmail(String usernameOrEmail) {
        return userRepository.findByUsernameOrEmail(usernameOrEmail);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public Optional<User> findByConfirmationToken(String confirmationToken) {
        return userRepository.findByConfirmationToken(confirmationToken);
    }

    public User saveUser(User user) {
        return userRepository.save(user);
    }

    public List<User> findAllUsers() {
        return userRepository.findAll();
    }

    public List<User> searchUser(String searchString) {
        var usersByUsername = userRepository.findByUsernameContaining(searchString);
        var usersByName = userRepository.findByNameContaining(searchString);
        usersByUsername.addAll(usersByName);
        return usersByUsername.stream().toList();
    }

    public List<User> searchNotRelated(String username, String searchString) {
        var requestingUser = userRepository.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        var usersByUsername = userRepository.findByUsernameContaining(searchString);
        var usersByName = userRepository.findByNameContaining(searchString);
        usersByUsername.addAll(usersByName);


        var removedFriends = usersByUsername.removeIf(user -> requestingUser.getFriends().contains(user)); // remove friends
        var removedHimself = usersByUsername.removeIf(user -> user.equals(requestingUser)); // remove self
        var removedSentFriendReqs = usersByUsername.removeIf(
                user -> requestingUser.getSentFriendRequests().stream()
                        .anyMatch(fr -> fr.getReceiver().getUsername().equals(user.getUsername()))
        ); // remove sent requests
        var removedReceivedFriendReqs = usersByUsername.removeIf(
                user -> requestingUser.getReceivedFriendRequests().stream()
                        .anyMatch(fr -> fr.getSender().getUsername().equals(user.getUsername()))
        ); // remove received requests

        return usersByUsername.stream().toList();
    }

    public Optional<User> findById(Long senderId) {
        return userRepository.findById(senderId);
    }

    public String getUserPublicKey(String username) {
        return userRepository.findByUsername(username).orElseThrow(UserDoesNotExist::new).getPublicKey();
    }

    public void uploadKeys(String username, String publicKey, String encryptedPrivateKey) {
        var user = userRepository.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        user.setPublicKey(publicKey);
        user.setEncryptedPrivateKey(encryptedPrivateKey);
        userRepository.save(user);
    }

    public KeysDTO getKeys(String username) {
        var user = userRepository.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        return new KeysDTO(user.getPublicKey(), user.getEncryptedPrivateKey());
    }

    public String getPublicKeyOfUser(String username) {
        return userRepository.findByUsername(username).orElseThrow(UserDoesNotExist::new).getPublicKey();
    }

    public boolean isUserAppAdmin(String username) {
        return userRepository.findByUsername(username).orElseThrow(UserDoesNotExist::new).getIsAdmin();
    }

    public void makeAppAdmin(Long userId) {
        var user = userRepository.findById(userId).orElseThrow(UserDoesNotExist::new);
        user.setIsAdmin(true);
        userRepository.save(user);
    }

    public void removeAppAdmin(Long userId) {
        var user = userRepository.findById(userId).orElseThrow(UserDoesNotExist::new);
        user.setIsAdmin(false);
        userRepository.save(user);
    }

    public void updateUserInfo(String currentUsername, UserDetailsUpdateDTO userDetailsUpdateDTO) {
        var username = userDetailsUpdateDTO.getUsername();
        var email = userDetailsUpdateDTO.getEmail();
        var firstName = userDetailsUpdateDTO.getFirstName();
        var lastName = userDetailsUpdateDTO.getLastName();

        var userToUpdate = findByUsername(currentUsername).orElseThrow(UserDoesNotExist::new);
        var userWithNewUsername = findByUsername(username);
        var userWithNewEmail = findByEmail(email);

        if (!username.equals(currentUsername) && userWithNewUsername.isPresent())
            throw new UserAlreadyExists("Username not available");

        if (!userToUpdate.getEmail().equals(email) && userWithNewEmail.isPresent())
            throw new UserAlreadyExists("Email already taken");

        userToUpdate.setUsername(username);
        userToUpdate.setEmail(email);
        userToUpdate.setFirstName(firstName);
        userToUpdate.setLastName(lastName);
        saveUser(userToUpdate);
    }
}
