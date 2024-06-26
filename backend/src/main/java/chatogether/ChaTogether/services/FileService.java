package chatogether.ChaTogether.services;

import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.exceptions.FileNotFoundException;
import chatogether.ChaTogether.exceptions.ImageUploadFailed;
import chatogether.ChaTogether.persistence.ChatMessage;
import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.persistence.User;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.util.FileSystemUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.swing.text.DateFormatter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

@Service
public class FileService {
    private final UserService userService;

    private final String userDataPath = "../userData/";

    public FileService(UserService userService) {
        this.userService = userService;
    }

    public void createUserDirectory(User user) throws IOException {
        if (user.getDirectoryName() == null) {
            var hashedUsername = BCrypt.hashpw(user.getUsername(), BCrypt.gensalt());
            user.setDirectoryName(hashedUsername);
            userService.saveUser(user);
        }
        Path userDirectory = Paths.get(userDataPath, user.getDirectoryName());
        if (!Files.exists(userDirectory)) {
            Files.createDirectories(userDirectory);
        }
    }

    public void uploadProfilePicture(String username, MultipartFile profilePicture)
            throws ImageUploadFailed, UserDoesNotExist {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        try {
            createUserDirectory(user);
            var pictureExtension = Objects.requireNonNull(profilePicture.getOriginalFilename()).split("\\.")[1];
            if (!(pictureExtension.equals("jpg") || pictureExtension.equals("png"))) {
                throw new ImageUploadFailed("Extension not supported (not jpg or png)");
            }
            Path profilePicturePath = Paths.get(userDataPath, user.getDirectoryName(), "profilePicture." + pictureExtension);
            Files.write(profilePicturePath, profilePicture.getBytes());
        } catch (IOException e) {
            throw new ImageUploadFailed();
        }
    }

    public boolean profilePictureUploaded(String username) {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        Path jpgProfilePicturePath = Paths.get(userDataPath, user.getDirectoryName(), "profilePicture.jpg");
        Path pngProfilePicturePath = Paths.get(userDataPath, user.getDirectoryName(), "profilePicture.png");
        return Files.exists(jpgProfilePicturePath) || Files.exists(pngProfilePicturePath);
    }

    public Resource getProfilePicture(String username) throws FileNotFoundException {
        var user = userService.findByUsername(username).orElseThrow(UserDoesNotExist::new);
        if (user.getDirectoryName() == null)
            throw new FileNotFoundException("User directory not found for user " + username);

        Path jpgProfilePicturePath = Paths.get(userDataPath, user.getDirectoryName(), "profilePicture.jpg");
        Path pngProfilePicturePath = Paths.get(userDataPath, user.getDirectoryName(), "profilePicture.png");

        if (Files.exists(jpgProfilePicturePath)) {
            return new FileSystemResource(jpgProfilePicturePath.toFile());
        } else if (Files.exists(pngProfilePicturePath)) {
            return new FileSystemResource(pngProfilePicturePath.toFile());
        }

        throw new FileNotFoundException("Profile picture not found for user " + username);
    }

    public String uploadChatImage(byte[] encryptedImage, ChatRoom chatRoom, ChatMessage message) {
        Long senderId = message.getSenderId();
        LocalDateTime sentAt = message.getSentAt();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        String timestamp = sentAt.format(formatter);

        String fileName = "image_" + senderId + "_" + timestamp;
        Path filePath = Paths.get(chatRoom.getDirectoryPath(), fileName);
        Path fullPath = Paths.get(userDataPath, filePath.toString());

        try {
            Files.write(fullPath, encryptedImage);
        } catch (IOException e) {
            throw new ImageUploadFailed();
        }

        return filePath.toString();
    }

    public byte[] getChatImageBytes(String filePath) {
        Path fullPath = Paths.get(userDataPath, filePath);
        try {
            return Files.readAllBytes(fullPath);
        } catch (IOException e) {
            throw new FileNotFoundException("Image not found");
        }
    }

    public void createChatDirectory(String directoryPathString) {
        Path directoryPath = Paths.get(userDataPath, directoryPathString);
        if (!Files.exists(directoryPath)) {
            try {
                Files.createDirectory(directoryPath);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public Resource getProfilePictureById(Long userId) {
        var user = userService.findById(userId).orElseThrow(UserDoesNotExist::new);
        return getProfilePicture(user.getUsername());
    }

    public void deleteDirectory(String fullPath) {
        FileSystemUtils.deleteRecursively(new File(fullPath));
    }

    public void deleteChatDirectory(ChatRoom chatRoom) {
        deleteDirectory(Paths.get(userDataPath, chatRoom.getDirectoryPath()).toString());
    }

    public void uploadGroupPicture(ChatRoom chatRoom, MultipartFile groupPicture) throws ImageUploadFailed {
        try {
            createChatDirectory(chatRoom.getDirectoryPath());
            var pictureExtension = Objects.requireNonNull(groupPicture.getOriginalFilename()).split("\\.")[1];
            if (!(pictureExtension.equals("jpg") || pictureExtension.equals("png"))) {
                throw new ImageUploadFailed("Extension not supported (not jpg or png)");
            }

            Path groupPicturePath = Paths.get(
                    userDataPath, chatRoom.getDirectoryPath(),
                    "groupPicture." + pictureExtension
            );
            Files.write(groupPicturePath, groupPicture.getBytes());
        } catch (IOException e) {
            throw new ImageUploadFailed();
        }
    }

    public Resource getGroupPicture(ChatRoom chatRoom) throws FileNotFoundException {
        Path jpgGroupPicturePath = Paths.get(userDataPath, chatRoom.getDirectoryPath(), "groupPicture.jpg");
        Path pngGroupPicturePath = Paths.get(userDataPath, chatRoom.getDirectoryPath(), "groupPicture.png");

        if (Files.exists(jpgGroupPicturePath)) {
            return new FileSystemResource(jpgGroupPicturePath.toFile());
        } else if (Files.exists(pngGroupPicturePath)) {
            return new FileSystemResource(pngGroupPicturePath.toFile());
        }

        throw new FileNotFoundException("Group picture not found for chat room " + chatRoom.getId());
    }
}