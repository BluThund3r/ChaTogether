package chatogether.ChaTogether.services;

import chatogether.ChaTogether.enums.ChatMessageType;
import chatogether.ChaTogether.exceptions.*;
import chatogether.ChaTogether.persistence.ChatMessage;
import chatogether.ChaTogether.repositories.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ChatMessageService {
    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomService chatRoomService;
    private final FileService fileService;
    private final FriendshipService friendshipService;

    public ChatMessage saveMessage(ChatMessage message) {
        return chatMessageRepository.save(message);
    }

    public List<ChatMessage> getMessagesByRoomId(String roomId) {
        return chatMessageRepository.findByChatRoomId(roomId);
    }

    public ChatMessage uploadMessage(
            Long chatRoomId,
            Long senderId,
            String encryptedContent,
            ChatMessageType type,
            byte[] encryptedImage
    ) {
        var chatRoom = chatRoomService.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (chatRoomService.isUserInChatRoom(senderId, chatRoomId)) {
            throw new UserNotInChatRoom();
        }
        if (chatRoom.isPrivateChat() && !friendshipService.areUsersBlockedByIds(senderId, chatRoom.getOtherUserId(senderId))) {
            throw new UserBlocked("Not able to reply to this conversation");
        }
        ChatMessage message = ChatMessage.builder()
                .chatRoomId(chatRoomId)
                .senderId(senderId)
                .type(type)
                .isEdited(false)
                .sentAt(LocalDateTime.now())
                .build();

        if (type == ChatMessageType.TEXT || type == ChatMessageType.ANNOUNCEMENT)
            message.setContentOrPath(encryptedContent);
        else
            message.setContentOrPath(fileService.uploadChatImage(encryptedImage, chatRoom, message));

        return saveMessage(message);
    }

    public ChatMessage editMessage(Long messageId, String newContent, Long userId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        if (chatMessage.getType() != ChatMessageType.TEXT)
            throw new MessageNotEditable("Only text messages can be edited");
        if (!Objects.equals(chatMessage.getSenderId(), userId))
            throw new MessageNotEditable("You can only edit your own messages");
        chatMessage.setContentOrPath(newContent);
        chatMessage.setIsEdited(true);
        return saveMessage(chatMessage);
    }

    public ChatMessage deleteMessage(Long messageId, Long userId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        if (!Objects.equals(chatMessage.getSenderId(), userId))
            throw new MessageNotDeletable("You can only delete your own messages");
        chatMessage.setIsDeleted(true);
        return saveMessage(chatMessage);
    }

    public List<ChatMessage> getMessagesByRoomIdBeforeAndLimited(
            Long chatRoomId,
            LocalDateTime beforeTimestamp,
            int limit,
            Long userId
    ) {
        if (!chatRoomService.isUserInChatRoom(userId, chatRoomId))
            throw new UserNotInChatRoom();

        var messages = chatMessageRepository.findByChatRoomIdBefore(chatRoomId, beforeTimestamp);
        messages.sort(Comparator.comparing(ChatMessage::getSentAt).reversed());
        return messages.subList(0, Math.min(limit, messages.size()));
    }

    public byte[] getImageBytesByMessageId(Long messageId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        return getImageBytesOfMessage(chatMessage);
    }

    public String getImageEncodedByMessageId(Long messageId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        return getImageEncodedOfMessage(chatMessage);
    }

    public byte[] getImageBytesOfMessage(ChatMessage chatMessage) {
        if (chatMessage.getType() != ChatMessageType.IMAGE)
            throw new MessageNotAnImage();
        return fileService.getChatImageBytes(chatMessage.getContentOrPath());
    }

    public String getImageEncodedOfMessage(ChatMessage chatMessage) {
        return Base64.getEncoder().encodeToString(getImageBytesOfMessage(chatMessage));
    }
}
