package chatogether.ChaTogether.repositories;

import chatogether.ChaTogether.persistence.KeysTest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KeyTestRepository extends JpaRepository<KeysTest, String> {
    
}
