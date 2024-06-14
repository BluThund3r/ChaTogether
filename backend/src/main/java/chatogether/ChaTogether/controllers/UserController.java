package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.KeysDTO;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.FileService;
import chatogether.ChaTogether.services.UserService;
import lombok.AllArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/user")
@AllArgsConstructor
public class UserController {
    private final UserService userService;
    private final FileService fileService;

    @GetMapping("/search")
    public List<User> searchUser(
            @RequestParam String searchString
    ) {
        return userService.searchUser(searchString);
    }

    @GetMapping("/searchNotRelated")
    public List<User> searchNotFriends(
            @RequestParam String searchString
    ) {
        String username = AuthRequestFilter.getUsername();
        return userService.searchNotRelated(username, searchString);
    }

    @PostMapping("/uploadProfilePicture")
    public void uploadProfilePicture(
            @RequestParam("file") MultipartFile profilePicture
    ) {
        String username = AuthRequestFilter.getUsername();
        fileService.uploadProfilePicture(username, profilePicture);
    }

//    @GetMapping("/profilePictureUploaded")
//    public boolean profilePictureUploaded() {
//        String username = AuthRequestFilter.getUsername();
//        return fileService.profilePictureUploaded(username);
//    }

    @GetMapping("/profilePicture")
    public Resource getProfilePicture(
            @RequestParam String username
    ) {
        return fileService.getProfilePicture(username);
    }

    @GetMapping("/profilePictureById")
    public Resource getProfilePictureById(
            @RequestParam Long userId
    ) {
        return fileService.getProfilePictureById(userId);
    }

    @PostMapping("/uploadKeys")
    public void uploadKeys(
            @RequestBody KeysDTO uploadKeysDTO
    ) {
        String username = AuthRequestFilter.getUsername();
        userService.uploadKeys(username, uploadKeysDTO.getPublicKey(), uploadKeysDTO.getEncryptedPrivateKey());
    }

    @GetMapping("/getKeys")
    public KeysDTO getKeys() {
        String username = AuthRequestFilter.getUsername();
        return userService.getKeys(username);
    }

    @GetMapping("/getPublicKeyOfUser/{username}")
    public String getPublicKeyOfUser(
            @PathVariable String username
    ) {
        return userService.getPublicKeyOfUser(username);
    }
}
