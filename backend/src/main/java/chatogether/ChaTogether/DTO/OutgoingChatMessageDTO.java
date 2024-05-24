package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.enums.ActionType;
import chatogether.ChaTogether.enums.ChatMessageType;
import chatogether.ChaTogether.persistence.ChatMessage;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OutgoingChatMessageDTO {
    private Long id;
    private Long chatRoomId;
    private Long senderId;
    private String contentOrPath;
    private String sentAt;
    private ChatMessageType type;
    private boolean isEdited;
    private boolean isDeleted;
    private List<Long> seenBy;
    private ActionType action;

    public OutgoingChatMessageDTO(ChatMessage chatMessage, ActionType action) {
        this.id = chatMessage.getId();
        this.chatRoomId = chatMessage.getChatRoomId();
        this.senderId = chatMessage.getSenderId();
        this.contentOrPath = chatMessage.getContentOrPath();
        this.sentAt = chatMessage.getSentAt().toString();
        this.type = chatMessage.getType();
        this.isEdited = chatMessage.getIsEdited();
        this.isDeleted = chatMessage.getIsDeleted();
        this.seenBy = chatMessage.getSeenBy();
        this.action = action;
    }
}