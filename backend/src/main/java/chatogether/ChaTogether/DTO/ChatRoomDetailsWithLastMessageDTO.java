package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.persistence.User;
import chatogether.ChaTogether.services.UserService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatRoomDetailsWithLastMessageDTO {
    protected String id;
    protected String roomName;
    protected int maxUsers;
    protected OutgoingChatMessageDTO lastMessage;
    protected List<UserDetailsForOthersDTO> users;

    public ChatRoomDetailsWithLastMessageDTO(
            ChatRoom chatRoom,
            OutgoingChatMessageDTO lastMessage,
            UserService userService
    ) {
        this.id = chatRoom.getId();
        this.roomName = chatRoom.getRoomName();
        this.maxUsers = chatRoom.getMaxUsers();
        this.lastMessage = lastMessage;
        this.users = chatRoom.getEncryptedKeys().keySet()
                .stream().map(userId -> new UserDetailsForOthersDTO(
                                userService.findById(userId).get(),
                                chatRoom.isUserAdmin(userId)
                        )
                )
                .toList();
    }
}
