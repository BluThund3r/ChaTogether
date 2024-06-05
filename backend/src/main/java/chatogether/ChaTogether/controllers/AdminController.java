package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.UserDetailsForAdmins;
import chatogether.ChaTogether.DTO.UserDetailsForOthersDTO;
import chatogether.ChaTogether.exceptions.NotAppAdmin;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.Stats;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.StatsService;
import chatogether.ChaTogether.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {
    private final StatsService statsService;
    private final UserService userService;

    @GetMapping("/getAllUsers")
    public List<UserDetailsForAdmins> getAllUsers() {
        var callerUsername = AuthRequestFilter.getUsername();
        if (!userService.isUserAppAdmin(callerUsername))
            throw new NotAppAdmin();
        return userService.findAllUsers().stream()
                .map(UserDetailsForAdmins::new)
                .toList();
    }

    @PostMapping("/makeAdmin/{userId}")
    public void makeAdmin(@PathVariable Long userId) {
        var callerUsername = AuthRequestFilter.getUsername();
        if (!userService.isUserAppAdmin(callerUsername))
            throw new NotAppAdmin();
        userService.makeAppAdmin(userId);
    }

    @PostMapping("/removeAdmin/{userId}")
    public void removeAdmin(@PathVariable Long userId) {
        var callerUsername = AuthRequestFilter.getUsername();
        if (!userService.isUserAppAdmin(callerUsername))
            throw new NotAppAdmin();
        userService.removeAppAdmin(userId);
    }

    @GetMapping("/getStats")
    public List<Stats> getStats() {
        var callerUsername = AuthRequestFilter.getUsername();
        if (!userService.isUserAppAdmin(callerUsername))
            throw new NotAppAdmin();
        var stats = statsService.getStatsOfLastSixMonths();
        if (stats == null)
            return List.of();
        return stats;
    }
}
