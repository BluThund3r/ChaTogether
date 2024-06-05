package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.Stats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StatsRepository extends JpaRepository<Stats, Integer> {
    @Query("SELECT s FROM Stats s WHERE s.month = ?1 AND s.year = ?2")
    Optional<Stats> findByMonthAndYear(int month, int year);

    @Query("SELECT s FROM Stats s WHERE s.year > ?2 OR (s.year = ?2 AND s.month > ?1)")
    List<Stats> findStatsAfter(int month, int year);
}
