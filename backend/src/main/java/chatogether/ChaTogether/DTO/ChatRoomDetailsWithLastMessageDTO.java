package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.ChatRoom;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatRoomDetailsWithLastMessageDTO {
    private Long id;
    private String roomName;
    private int maxUsers;
    private OutgoingChatMessageDTO lastMessage;

    public ChatRoomDetailsWithLastMessageDTO(ChatRoom chatRoom, OutgoingChatMessageDTO lastMessage) {
        this.id = chatRoom.getId();
        this.roomName = chatRoom.getRoomName();
        this.maxUsers = chatRoom.getMaxUsers();
        this.lastMessage = lastMessage;
    }
}
