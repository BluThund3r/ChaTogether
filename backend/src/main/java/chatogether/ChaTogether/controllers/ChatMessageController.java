package chatogether.ChaTogether.controllers;

import chatogether.ChaTogether.DTO.ChatRoomDetailsWithLastMessageDTO;
import chatogether.ChaTogether.DTO.OutgoingChatMessageDTO;
import chatogether.ChaTogether.enums.ActionType;
import chatogether.ChaTogether.enums.ChatMessageType;
import chatogether.ChaTogether.DTO.IncomingTextChatMessageDTO;
import chatogether.ChaTogether.filters.AuthRequestFilter;
import chatogether.ChaTogether.persistence.ChatMessage;
import chatogether.ChaTogether.services.ChatMessageService;
import chatogether.ChaTogether.services.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ChatMessageController {
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final ChatMessageService chatMessageService;
    private final ChatRoomService chatRoomService;

    @MessageMapping("/sendMessage/{chatRoomId}")
    public void sendMessage(
            @DestinationVariable Long chatRoomId,
            IncomingTextChatMessageDTO incomingMessage,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var senderId = (Long) attributes.get("userId");
        ChatMessage chatMessage;
        if (incomingMessage.getType() == ChatMessageType.IMAGE)
            chatMessage = chatMessageService.uploadMessage(
                    chatRoomId,
                    senderId,
                    "",
                    incomingMessage.getType(),
                    Base64.getDecoder().decode(incomingMessage.getEncryptedContent())
            );
        else
            chatMessage = chatMessageService.uploadMessage(
                    chatRoomId,
                    senderId,
                    incomingMessage.getEncryptedContent(),
                    incomingMessage.getType(),
                    null
            );

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/" + chatRoomId,
                new OutgoingChatMessageDTO(
                        chatMessage,
                        ActionType.SEND,
                        chatMessage.getType() == ChatMessageType.IMAGE ?
                                chatMessageService.getImageEncodedOfMessage(chatMessage) :
                                null
                )
        );

        var chatRoom = chatRoomService.getChatRoomById(chatRoomId);
        simpMessagingTemplate.convertAndSend(
                "/user/chatRoomUpdates",
                new ChatRoomDetailsWithLastMessageDTO(
                        chatRoom,
                        new OutgoingChatMessageDTO(chatMessage, ActionType.GET, null)
                )
        );
    }

    @MessageMapping("/seeMessage/{messageId}")
    public void seeMessage(
            @DestinationVariable Long messageId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var userId = (Long) attributes.get("userId");

        var chatMessage = chatMessageService.seeMessage(messageId, userId);

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.SEEN, null)
        );
    }

    @MessageMapping("/seeAllMessages/{chatRoomId}")
    public void seeMessages(
            @DestinationVariable Long chatRoomId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var userId = (Long) attributes.get("userId");

        var chatMessages = chatMessageService.seeMessagesInChatRoom(chatRoomId, userId);
        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/" + chatRoomId,
                chatMessages.stream()
                        .map(chatMessage ->
                                new OutgoingChatMessageDTO(chatMessage, ActionType.SEEN, null)
                        )
                        .toList()
        );
    }

    @MessageMapping("/editMessage/{messageId}")
    public void editMessage(
            @DestinationVariable Long messageId,
            String newContent,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var senderId = (Long) attributes.get("userId");

        var chatMessage = chatMessageService.editMessage(
                messageId,
                newContent,
                senderId
        );

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.EDIT, null)
        );
    }

    @MessageMapping("/deleteMessage/{messageId}")
    public void deleteMessage(
            @DestinationVariable Long messageId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var senderId = (Long) attributes.get("userId");

        var chatMessage = chatMessageService.deleteMessage(
                messageId,
                senderId
        );

        simpMessagingTemplate.convertAndSend(
                "/user/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.DELETE,
                        chatMessage.getType() == ChatMessageType.IMAGE ?
                                chatMessageService.getImageEncodedOfMessage(chatMessage) :
                                null)
        );
    }

    @GetMapping("/chatMessages/{chatRoomId}")
    public List<OutgoingChatMessageDTO> getChatMessages(
            @PathVariable Long chatRoomId,
            @RequestParam("before") String beforeTimestampStr
    ) {
        var userId = AuthRequestFilter.getUserId();
        var formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        var beforeTimestamp = LocalDateTime.parse(beforeTimestampStr, formatter);
        return chatMessageService.getMessagesByRoomIdBeforeAndLimited(chatRoomId, beforeTimestamp, 50, userId)
                .stream()
                .map(chatMessage ->
                        new OutgoingChatMessageDTO(
                                chatMessage,
                                ActionType.GET,
                                chatMessage.getType() == ChatMessageType.IMAGE ?
                                        chatMessageService.getImageEncodedOfMessage(chatMessage) :
                                        null
                        )
                )
                .toList();
    }
}
