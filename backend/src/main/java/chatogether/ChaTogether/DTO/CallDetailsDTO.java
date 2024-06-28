package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.Call;
import chatogether.ChaTogether.services.ChatRoomService;
import chatogether.ChaTogether.services.UserService;
import lombok.Data;

import java.util.List;

@Data
public class CallDetailsDTO {
    private String roomName;
    private String pictureString;
    private boolean isPrivateChat;
    private String startTime;
    private String endTime;
    private List<Long> userIds;

    public CallDetailsDTO(Call call, Long userId, ChatRoomService chatRoomService, UserService userService) {
        var chatRoom = chatRoomService.findById(call.getChatRoomId()).get();
        if (chatRoom.isPrivateChat()) {
            var otherUser = userService.findById(chatRoom.getOtherUserId(userId)).get();
            this.roomName = otherUser.getUsername();
            this.pictureString = otherUser.getUsername();
            this.isPrivateChat = true;
        } else {
            this.roomName = chatRoom.getRoomName();
            this.pictureString = chatRoom.getId();
            this.isPrivateChat = false;
        }
        this.startTime = call.getStartTime().toString();
        this.endTime = call.getEndTime().toString();
        this.userIds = call.getParticipantsIds();
    }
}
