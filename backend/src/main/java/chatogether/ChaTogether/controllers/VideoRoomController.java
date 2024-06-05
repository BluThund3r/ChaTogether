package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.UserDetailsForOthersDTO;
import chatogether.ChaTogether.DTO.VideoRoomDetailsDTO;
import chatogether.ChaTogether.DTO.VideoRoomJoinOrLeaveDTO;
import chatogether.ChaTogether.enums.JoinOrLeave;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.services.UserService;
import chatogether.ChaTogether.services.VideoRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/videoRoom")
@RequiredArgsConstructor
public class VideoRoomController {
    private final VideoRoomService videoRoomService;
    private final UserService userService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    @PostMapping(path = "/join/{connectionCode}")
    public VideoRoomDetailsDTO joinVideoRoom(
            @PathVariable String connectionCode
    ) {
        var userId = AuthRequestFilter.getUserId();
        System.out.println("userId: " + userId);
        var user = userService.findById(userId).orElseThrow(UserDoesNotExist::new);
        System.out.println("user: " + user);

        var videoRoomDetails = new VideoRoomDetailsDTO(videoRoomService.joinVideoRoom(user, connectionCode));

        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/joinOrLeave/" + connectionCode,
                VideoRoomJoinOrLeaveDTO.builder()
                        .connectionCode(connectionCode)
                        .action(JoinOrLeave.JOIN)
                        .userDetails(new UserDetailsForOthersDTO(user, false))
                        .build()
        );

        return videoRoomDetails;
    }

    @PostMapping(path = "/createNew")
    public VideoRoomDetailsDTO createVideoRoom() {
        return new VideoRoomDetailsDTO(videoRoomService.createVideoRoom());
    }
}
