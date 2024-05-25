package chatogether.ChaTogether.persistence;

import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;
import java.util.Map;

@Data
@Document
@Builder
public class ChatRoom {
    @Id
    @Indexed
    private Long id;
    private String roomName;
    private Map<Long, String> encryptedKeys;
    private int maxUsers;
    private List<Long> admins;
    private String directoryPath;

    public String getEncryptedKeyOfUser(Long userId) {
        return encryptedKeys.get(userId);
    }

    public void setEncryptedKeyOfUser(Long userId, String encryptedKey) {
        encryptedKeys.put(userId, encryptedKey);
    }

    public void removeUserEncryptionKey(Long userId) {
        encryptedKeys.remove(userId);
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
}
