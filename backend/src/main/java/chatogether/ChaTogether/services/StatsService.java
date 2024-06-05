package chatogether.ChaTogether.services;

import chatogether.ChaTogether.persistence.Stats;
import chatogether.ChaTogether.repositories.StatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class StatsService {
    final private StatsRepository statsRepository;

    public Optional<Stats> getStatsByMonthAndYear(int month, int year) {
        return statsRepository.findByMonthAndYear(month, year);
    }

    public void incrementNewUsersCount(LocalDateTime date) {
        var month = date.getMonthValue();
        var year = date.getYear();
        var statsOptional = getStatsByMonthAndYear(month, year);
        Stats stats;
        if (statsOptional.isPresent()) {
            stats = statsOptional.get();
            stats.setNewUsersCount(stats.getNewUsersCount() + 1);
        } else {
            stats = new Stats();
            stats.setMonth(month);
            stats.setYear(year);
            stats.setNewUsersCount(1);
        }
        statsRepository.save(stats);
    }

    public void incrementGroupChatsCount(LocalDateTime date) {
        var month = date.getMonthValue();
        var year = date.getYear();
        var statsOptional = getStatsByMonthAndYear(month, year);
        Stats stats;
        if (statsOptional.isPresent()) {
            stats = statsOptional.get();
            stats.setGroupChatsCount(stats.getGroupChatsCount() + 1);
        } else {
            stats = new Stats();
            stats.setMonth(month);
            stats.setYear(year);
            stats.setGroupChatsCount(1);
        }
        statsRepository.save(stats);
    }

    public void incrementPrivateChatsCount(LocalDateTime date) {
        var month = date.getMonthValue();
        var year = date.getYear();
        var statsOptional = getStatsByMonthAndYear(month, year);
        Stats stats;
        if (statsOptional.isPresent()) {
            stats = statsOptional.get();
            stats.setPrivateChatsCount(stats.getPrivateChatsCount() + 1);
        } else {
            stats = new Stats();
            stats.setMonth(month);
            stats.setYear(year);
            stats.setPrivateChatsCount(1);
        }
        statsRepository.save(stats);
    }

    public void incrementVideoRoomsCount(LocalDateTime date) {
        var month = date.getMonthValue();
        var year = date.getYear();
        var statsOptional = getStatsByMonthAndYear(month, year);
        Stats stats;
        if (statsOptional.isPresent()) {
            stats = statsOptional.get();
            stats.setVideoRoomsCount(stats.getVideoRoomsCount() + 1);
        } else {
            stats = new Stats();
            stats.setMonth(month);
            stats.setYear(year);
            stats.setVideoRoomsCount(1);
        }
        statsRepository.save(stats);
    }

    public List<Stats> getAllStatsAfter(LocalDateTime after) {
        var month = after.getMonthValue();
        var year = after.getYear();
        return statsRepository.findStatsAfter(month, year);
    }

    public List<Stats> getStatsOfLastSixMonths() {
        var sixMonthsBefore = LocalDateTime.now().minusMonths(6);
        return getAllStatsAfter(sixMonthsBefore);
    }
}
