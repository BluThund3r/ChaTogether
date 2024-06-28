package chatogether.ChaTogether.persistence;

import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
@Document
@Builder
public class ChatRoom {
    @Id
    @Indexed
    private String id;
    private String roomName;
    private Map<Long, String> encryptedKeys;
    private int maxUsers;
    private List<Long> admins;
    private String directoryPath;
    private Map<Long, LocalDateTime> userAddedAt;

    public String getEncryptedKeyOfUser(Long userId) {
        return encryptedKeys.get(userId);
    }

    public LocalDateTime getTimeOfUserAdded(Long userId) {
        return userAddedAt.get(userId);
    }

    public void setEncryptedKeyOfUser(Long userId, String encryptedKey) {
        if (encryptedKeys == null)
            encryptedKeys = new HashMap<>();
        if (userAddedAt == null)
            userAddedAt = new HashMap<>();
        encryptedKeys.put(userId, encryptedKey);
        userAddedAt.put(userId, LocalDateTime.now());
    }

    public void removeUserEncryptionKey(Long userId) {
        encryptedKeys.remove(userId);
        userAddedAt.remove(userId);
    }

    public boolean isPrivateChat() {
        return maxUsers == 2;
    }

    public Long getOtherUserId(Long userId) {
        return admins.stream()
                .filter(id -> !id.equals(userId))
                .findFirst()
                .orElseThrow();
    }

    public boolean isUserAdmin(Long userId) {
        return admins.contains(userId);
    }
}
