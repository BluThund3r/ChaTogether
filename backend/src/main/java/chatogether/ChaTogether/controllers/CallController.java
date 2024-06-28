package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.CallDetailsDTO;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.services.CallService;
import chatogether.ChaTogether.services.ChatRoomService;
import chatogether.ChaTogether.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/calls")
public class CallController {

    private final CallService callService;
    private final ChatRoomService chatRoomService;
    private final UserService userService;

    @GetMapping("/getMyCalls")
    public List<CallDetailsDTO> getMyCalls() {
        var callerId = AuthRequestFilter.getUserId();
        var calls = callService.getCallsForUser(callerId);
        return calls.stream()
                .map(call -> new CallDetailsDTO(call, callerId, chatRoomService, userService))
                .toList();
    }

    @PostMapping("/joinCall/{chatRoomId}")
    public void joinCall(
            @PathVariable String chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        callService.userJoinCall(callerId, chatRoomId);
    }

    @DeleteMapping("leaveCall/{chatRoomId}")
    public void leaveCall(
            @PathVariable String chatRoomId
    ) {
        var callerId = AuthRequestFilter.getUserId();
        callService.userLeaveCall(callerId, chatRoomId);
    }

//    @PostMapping("/setDateForAll")
//    public void setDateForAll() {
//        chatRoomService.setDateForAll();
//    }
}
