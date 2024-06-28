package chatogether.ChaTogether.services;

import chatogether.ChaTogether.exceptions.UserAlreadyInCall;
import chatogether.ChaTogether.exceptions.UserNotInCall;
import chatogether.ChaTogether.persistence.Call;
import chatogether.ChaTogether.repositories.CallRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class CallService {
    final private Map<String, Set<Long>> calls;
    final private Map<String, LocalDateTime> callsStartTime;
    final private Map<String, Set<Long>> allCallMembers;
    final private CallRepository callRepository;
    final private ChatRoomService chatRoomService;

    public CallService(CallRepository callRepository, ChatRoomService chatRoomService) {
        this.callRepository = callRepository;
        this.chatRoomService = chatRoomService;
        calls = new HashMap<>();
        callsStartTime = new HashMap<>();
        allCallMembers = new HashMap<>();
    }

    private void createCallEntryAndDeleteOngoingCall(String chatRoomId) {
        var call = Call.builder()
                .chatRoomId(chatRoomId)
                .startTime(callsStartTime.get(chatRoomId))
                .endTime(LocalDateTime.now())
                .participantsIds(allCallMembers.get(chatRoomId).stream().toList())
                .build();
        calls.remove(chatRoomId);
        callsStartTime.remove(chatRoomId);
        allCallMembers.remove(chatRoomId);
        callRepository.save(call);
    }

    private void addUserToCall(Long userId, String chatRoomId) {
        calls.get(chatRoomId).add(userId);
        allCallMembers.get(chatRoomId).add(userId);
    }

    private boolean isUserInCall(Long userId, String chatRoomId) {
        return calls.get(chatRoomId).contains(userId);
    }

    public void userJoinCall(Long userId, String chatRoomId) {
        if (calls.containsKey(chatRoomId) && isUserInCall(userId, chatRoomId))
            throw new UserAlreadyInCall();
        if (!calls.containsKey(chatRoomId)) {
            allCallMembers.put(chatRoomId, new HashSet<>());
            calls.put(chatRoomId, new HashSet<>());
            callsStartTime.put(chatRoomId, LocalDateTime.now());
        }
        addUserToCall(userId, chatRoomId);
    }

    public void userLeaveCall(Long userId, String chatRoomId) {
        if (!calls.containsKey(chatRoomId) || !isUserInCall(userId, chatRoomId))
            throw new UserNotInCall();
        var userSet = calls.get(chatRoomId);
        userSet.remove(userId);
        if (userSet.isEmpty()) {
            createCallEntryAndDeleteOngoingCall(chatRoomId);
        }
    }

    public List<Call> getCallsForUser(Long userId) {
        var chatRooms = chatRoomService.getChatRoomsOfUser(userId);
        var calls = new ArrayList<Call>();
        for (var chatRoom : chatRooms) {
            var callsForChatRoom = callRepository.findByChatRoomIdAfter(
                    chatRoom.getId(),
                    chatRoom.getTimeOfUserAdded(userId)
            );
            calls.addAll(callsForChatRoom);
        }
        return calls.stream().sorted(Comparator.comparing(Call::getStartTime).reversed()).toList();
    }
}
