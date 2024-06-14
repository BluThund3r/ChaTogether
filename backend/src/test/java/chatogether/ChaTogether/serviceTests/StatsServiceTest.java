package chatogether.ChaTogether.serviceTests;

import chatogether.ChaTogether.services.StatsService;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.time.LocalDateTime;

@SpringBootTest
@ActiveProfiles("test")
public class StatsServiceTest {
    @Autowired
    private StatsService statsService;

    @Test
    @Transactional
    void shouldPassGetStats() {
        var stats = statsService.getStatsOfLastSixMonths();
        Assertions.assertEquals(6, stats.size());
    }

    @Test
    @Transactional
    void shouldIncrementNewUsers() {
        int month = LocalDateTime.now().getMonthValue();
        int year = LocalDateTime.now().getYear();
        var statsInitial = statsService.getStatsByMonthAndYear(month, year).get().getNewUsersCount();
        statsService.incrementNewUsersCount(LocalDateTime.now());
        var statsAfter = statsService.getStatsByMonthAndYear(month, year).get().getNewUsersCount();
        Assertions.assertEquals(statsInitial + 1, statsAfter);
    }

    @Test
    @Transactional
    void shouldIncrementGroupsCreated() {
        int month = LocalDateTime.now().getMonthValue();
        int year = LocalDateTime.now().getYear();
        var statsInitial = statsService.getStatsByMonthAndYear(month, year).get().getGroupChatsCount();
        statsService.incrementGroupChatsCount(LocalDateTime.now());
        var statsAfter = statsService.getStatsByMonthAndYear(month, year).get().getGroupChatsCount();
        Assertions.assertEquals(statsInitial + 1, statsAfter);
    }

    @Test
    @Transactional
    void shouldIncrementPrivatesCreated() {
        int month = LocalDateTime.now().getMonthValue();
        int year = LocalDateTime.now().getYear();
        var statsInitial = statsService.getStatsByMonthAndYear(month, year).get().getPrivateChatsCount();
        statsService.incrementPrivateChatsCount(LocalDateTime.now());
        var statsAfter = statsService.getStatsByMonthAndYear(month, year).get().getPrivateChatsCount();
        Assertions.assertEquals(statsInitial + 1, statsAfter);
    }

    @Test
    @Transactional
    void shouldIncrementVideoRoomsCreated() {
        int month = LocalDateTime.now().getMonthValue();
        int year = LocalDateTime.now().getYear();
        var statsInitial = statsService.getStatsByMonthAndYear(month, year).get().getVideoRoomsCount();
        statsService.incrementVideoRoomsCount(LocalDateTime.now());
        var statsAfter = statsService.getStatsByMonthAndYear(month, year).get().getVideoRoomsCount();
        Assertions.assertEquals(statsInitial + 1, statsAfter);
    }


}
