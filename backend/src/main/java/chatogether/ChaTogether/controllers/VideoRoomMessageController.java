package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.*;
import chatogether.ChaTogether.enums.JoinOrLeave;
import chatogether.ChaTogether.enums.VideoRoomSignalType;
import chatogether.ChaTogether.exceptions.ConcreteExceptions.UserDoesNotExist;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.services.UserService;
import chatogether.ChaTogether.services.VideoRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class VideoRoomMessageController {
    private final VideoRoomService videoRoomService;
    private final UserService userService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    @MessageMapping("/videoRoom/syncVideo/{connectionCode}")
    public void syncVideoRoom(
            @DestinationVariable String connectionCode
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.SYNC_VIDEO)
                        .signalData("SYNC_VIDEO")
                        .build()
        );
    }

    @MessageMapping("/videoRoom/syncVideoResponse/{connectionCode}")
    public void syncVideoRoomResponse(
            @DestinationVariable String connectionCode,
            VideoChangeDTO videoChangeDTO
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.SYNC_VIDEO_RESPONSE)
                        .signalData(videoChangeDTO.getNewVideoId())
                        .build()
        );
    }

    @MessageMapping("/videoRoom/syncPositionResponse/{connectionCode}")
    public void syncPositionResponse(
            @DestinationVariable String connectionCode,
            VideoPositionChangeDTO videoPositionChangeDTO
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.SYNC_POSITION_RESPONSE)
                        .signalData(videoPositionChangeDTO.getPosition() + "|" + videoPositionChangeDTO.isPlaying())
                        .build()
        );
    }

    @MessageMapping("videoRoom/syncPosition/{connectionCode}")
    public void syncPosition(
            @DestinationVariable String connectionCode
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.SYNC_POSITION)
                        .signalData("SYNC_POSITION")
                        .build()
        );
    }

    @MessageMapping("/videoRoom/pause/{connectionCode}")
    public void pauseVideoRoom(
            @DestinationVariable String connectionCode
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.PAUSE)
                        .signalData("PAUSE")
                        .build()
        );
    }

    @MessageMapping("/videoRoom/resume/{connectionCode}")
    public void resumeVideoRoom(
            @DestinationVariable String connectionCode
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.RESUME)
                        .signalData("RESUME")
                        .build()
        );
    }

    @MessageMapping("/videoRoom/seekToPosition/{connectionCode}")
    public void seekToPosition(
            @DestinationVariable String connectionCode,
            VideoPositionChangeDTO videoPositionChangeDTO
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.SEEK)
                        .signalData(videoPositionChangeDTO.getPosition() + "|" + videoPositionChangeDTO.isPlaying())
                        .build()
        );
    }

    @MessageMapping("/videoRoom/changeVideo/{connectionCode}")
    public void changeVideo(
            @DestinationVariable String connectionCode,
            VideoChangeDTO videoChangeDTO
    ) {
        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/signal/" + connectionCode,
                VideoRoomSignalDTO.builder()
                        .connectionCode(connectionCode)
                        .signalType(VideoRoomSignalType.CHANGE_VIDEO)
                        .signalData(videoChangeDTO.getNewVideoId())
                        .build()
        );
    }


    @MessageMapping("/videoRoom/leave/{connectionCode}")
    public void leaveVideoRoom(
            @DestinationVariable String connectionCode,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var userId = (Long) attributes.get("userId");
        var user = userService.findById(userId).orElseThrow(UserDoesNotExist::new);
        videoRoomService.leaveVideoRoom(
                user,
                connectionCode
        );

        System.out.println(user.getUsername() + " is leaving room " + connectionCode);

        simpMessagingTemplate.convertAndSend(
                "/queue/videoRoom/joinOrLeave/" + connectionCode,
                VideoRoomJoinOrLeaveDTO.builder()
                        .connectionCode(connectionCode)
                        .action(JoinOrLeave.LEAVE)
                        .userDetails(new UserDetailsForOthersDTO(user, false))
                        .build()
        );

        System.out.println("Sent leave message to room " + connectionCode);
    }
}
