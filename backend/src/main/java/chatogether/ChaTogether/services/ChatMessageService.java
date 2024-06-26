package chatogether.ChaTogether.services;

import chatogether.ChaTogether.enums.ChatMessageType;
import chatogether.ChaTogether.exceptions.*;
import chatogether.ChaTogether.persistence.ChatMessage;
import chatogether.ChaTogether.repositories.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

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
            String chatRoomId,
            Long senderId,
            String encryptedContent,
            ChatMessageType type,
            byte[] encryptedImage
    ) {
        var chatRoom = chatRoomService.findById(chatRoomId).orElseThrow(ChatRoomDoesNotExist::new);
        if (!chatRoomService.isUserInChatRoom(senderId, chatRoomId)) {
            throw new UserNotInChatRoom();
        }
        if (chatRoom.isPrivateChat() && friendshipService.areUsersBlockedByIds(senderId, chatRoom.getOtherUserId(senderId))) {
            throw new UserBlocked("Not able to reply to this conversation");
        }
        ChatMessage message = ChatMessage.builder()
                .chatRoomId(chatRoomId)
                .senderId(senderId)
                .type(type)
                .isEdited(false)
                .isDeleted(false)
                .seenBy(List.of(senderId))
                .contentOrPath("")
                .sentAt(LocalDateTime.now())
                .build();

        if (type == ChatMessageType.TEXT || type == ChatMessageType.ANNOUNCEMENT)
            message.setContentOrPath(encryptedContent);
        else
            message.setContentOrPath(fileService.uploadChatImage(encryptedImage, chatRoom, message));

        return saveMessage(message);
    }

    public ChatMessage editMessage(String messageId, String newContent, Long userId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        if (chatMessage.getType() != ChatMessageType.TEXT)
            throw new MessageNotEditable("Only text messages can be edited");
        if (!Objects.equals(chatMessage.getSenderId(), userId))
            throw new MessageNotEditable("You can only edit your own messages");
        chatMessage.setContentOrPath(newContent);
        chatMessage.setIsEdited(true);
        return saveMessage(chatMessage);
    }

    public ChatMessage deleteMessage(String messageId, Long userId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        if (!Objects.equals(chatMessage.getSenderId(), userId))
            throw new MessageNotDeletable("You can only delete your own messages");
        if (chatMessage.getIsDeleted())
            throw new MessageNotDeletable("Message is already deleted");
        chatMessage.setIsDeleted(true);
        return saveMessage(chatMessage);
    }

    public ChatMessage restoreMessage(String messageId, Long userId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        if (!Objects.equals(chatMessage.getSenderId(), userId))
            throw new MessageNotDeletable("You can only restore your own messages");
        if (!chatMessage.getIsDeleted())
            throw new MessageNotDeletable("Message is not deleted");
        chatMessage.setIsDeleted(false);
        return saveMessage(chatMessage);
    }

    public List<ChatMessage> getMessagesByRoomIdBeforeAndLimited(
            String chatRoomId,
            LocalDateTime beforeTimestamp,
            int limit,
            Long userId
    ) {
        if (!chatRoomService.isUserInChatRoom(userId, chatRoomId))
            throw new UserNotInChatRoom();

        var pageable = PageRequest.of(0, limit);
        var chatMessages = chatMessageRepository.findByChatRoomIdBeforeAndLimited(chatRoomId, beforeTimestamp, pageable);
        chatMessages.sort(Comparator.comparing(ChatMessage::getSentAt));
        return chatMessages;
    }

    public byte[] getImageBytesByMessageId(String messageId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        return getImageBytesOfMessage(chatMessage);
    }

    public String getImageEncodedByMessageId(String messageId) {
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

    public Optional<ChatMessage> getLastMessageOfChatRoom(String chatRoomId) {
        var pageable = PageRequest.of(0, 1);
        var messages = chatMessageRepository.findLatestByChatRoomId(chatRoomId, pageable);
        if (messages.isEmpty())
            return Optional.empty();
        return Optional.of(messages.getFirst());
    }

    public ChatMessage seeMessage(String messageId, Long userId) {
        var chatMessage = chatMessageRepository.findById(messageId).orElseThrow(ChatMessageDoesNotExist::new);
        if (!chatMessage.getSeenBy().contains(userId)) {
            chatMessage.getSeenBy().add(userId);
            saveMessage(chatMessage);
        }

        return chatMessage;
    }

    public List<ChatMessage> seeMessages(List<String> messageIds, Long userId) {
        return messageIds.stream().map(messageId -> seeMessage(messageId, userId)).toList();
    }

    public List<ChatMessage> seeMessagesInChatRoom(String chatRoomId, Long userId) {
        if (!chatRoomService.isUserInChatRoom(userId, chatRoomId))
            throw new UserNotInChatRoom();
        var messages = chatMessageRepository.findUnseenMessagesByRoomId(chatRoomId, userId);
        return seeMessages(messages.stream().map(ChatMessage::getId).toList(), userId);
    }
}
