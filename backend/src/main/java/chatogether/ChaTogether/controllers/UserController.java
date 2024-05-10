package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.UserService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/user")
@AllArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping("/all")
    public List<User> getAllUsers() {
        return userService.findAllUsers();
    }

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
}
