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
import chatogether.ChaTogether.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.Comparator;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ChatMessageController {
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final ChatMessageService chatMessageService;
    private final ChatRoomService chatRoomService;
    private final UserService userService;

    @MessageMapping("/sendMessage/{chatRoomId}")
    public void sendMessage(
            @DestinationVariable String chatRoomId,
            IncomingTextChatMessageDTO incomingMessage,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var senderId = (Long) attributes.get("userId");
        System.out.println("senderId: " + senderId);
        System.out.println("chatRoomId: " + chatRoomId);
        System.out.println("incomingMessageContent: " + incomingMessage.getEncryptedContent());
        System.out.println("incomingMessageType: " + incomingMessage.getType());
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
                "/queue/chatRoom/" + chatRoomId,
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
                "/queue/chatRoomUpdates",
                new ChatRoomDetailsWithLastMessageDTO(
                        chatRoom,
                        new OutgoingChatMessageDTO(chatMessage, ActionType.SEND, null),
                        userService
                )
        );
    }

    @MessageMapping("/seeMessage/{messageId}")
    public void seeMessage(
            @DestinationVariable String messageId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var userId = (Long) attributes.get("userId");

        var chatMessage = chatMessageService.seeMessage(messageId, userId);

        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.SEEN, null)
        );

        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoomUpdates",
                new ChatRoomDetailsWithLastMessageDTO(
                        chatRoomService.getChatRoomById(chatMessage.getChatRoomId()),
                        new OutgoingChatMessageDTO(chatMessage, ActionType.SEEN, null),
                        userService
                )
        );
    }

    @MessageMapping("/seeAllMessages/{chatRoomId}")
    public void seeMessages(
            @DestinationVariable String chatRoomId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var userId = (Long) attributes.get("userId");

        var chatMessages = chatMessageService.seeMessagesInChatRoom(chatRoomId, userId);
        var lastChatMessage = chatMessages.stream()
                .max(Comparator.comparing(ChatMessage::getSentAt))
                .orElse(null);
        chatMessages.forEach(chatMessage -> {
            simpMessagingTemplate.convertAndSend(
                    "/queue/chatRoom/" + chatRoomId,
                    new OutgoingChatMessageDTO(chatMessage, ActionType.SEEN, null)
            );
        });

        if (lastChatMessage == null) return;
        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoomUpdates",
                new ChatRoomDetailsWithLastMessageDTO(
                        chatRoomService.getChatRoomById(chatRoomId),
                        new OutgoingChatMessageDTO(lastChatMessage, ActionType.SEEN, null),
                        userService
                )
        );
    }

    @MessageMapping("/editMessage/{messageId}")
    public void editMessage(
            @DestinationVariable String messageId,
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
                "/queue/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.EDIT, null)
        );
    }

    @MessageMapping("/deleteMessage/{messageId}")
    public void deleteMessage(
            @DestinationVariable String messageId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var senderId = (Long) attributes.get("userId");

        var chatMessage = chatMessageService.deleteMessage(
                messageId,
                senderId
        );

        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.DELETE,
                        chatMessage.getType() == ChatMessageType.IMAGE ?
                                chatMessageService.getImageEncodedOfMessage(chatMessage) :
                                null
                )
        );
    }

    @MessageMapping("/restoreMessage/{messageId}")
    public void restoreMessage(
            @DestinationVariable String messageId,
            SimpMessageHeaderAccessor headerAccessor
    ) {
        var attributes = headerAccessor.getSessionAttributes();
        var senderId = (Long) attributes.get("userId");

        var chatMessage = chatMessageService.restoreMessage(
                messageId,
                senderId
        );

        simpMessagingTemplate.convertAndSend(
                "/queue/chatRoom/" + chatMessage.getChatRoomId(),
                new OutgoingChatMessageDTO(chatMessage, ActionType.RESTORE,
                        chatMessage.getType() == ChatMessageType.IMAGE ?
                                chatMessageService.getImageEncodedOfMessage(chatMessage) :
                                null
                )
        );
    }

    @GetMapping("/chatMessages")
    @ResponseBody
    public List<OutgoingChatMessageDTO> getChatMessages(
            @RequestParam String chatRoomId,
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
