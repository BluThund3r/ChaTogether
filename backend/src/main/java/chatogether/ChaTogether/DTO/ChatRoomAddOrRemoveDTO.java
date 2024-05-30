package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.enums.ChatRoomAction;
import chatogether.ChaTogether.persistence.ChatRoom;
import chatogether.ChaTogether.services.UserService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode(callSuper = true)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomAddOrRemoveDTO extends ChatRoomDetailsWithLastMessageDTO {
    protected ChatRoomAction action;
    List<Long> affectedUserIds;

    public ChatRoomAddOrRemoveDTO(
            ChatRoom chatRoom,
            OutgoingChatMessageDTO lastMessage,
            ChatRoomAction action,
            List<Long> affectedUserIds,
            UserService userService
    ) {
        super(chatRoom, lastMessage, userService);
        this.action = action;
        this.affectedUserIds = affectedUserIds;
    }
}
