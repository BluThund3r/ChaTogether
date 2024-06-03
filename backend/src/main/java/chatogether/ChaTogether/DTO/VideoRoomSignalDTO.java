package chatogether.ChaTogether.DTO;

import chatogether.ChaTogether.enums.VideoRoomSignalType;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class VideoRoomSignalDTO {
    private String connectionCode;
    private VideoRoomSignalType signalType;
    private String signalData;
}
