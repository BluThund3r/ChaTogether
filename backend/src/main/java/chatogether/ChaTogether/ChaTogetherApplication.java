package chatogether.ChaTogether;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.SpringVersion;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ChaTogetherApplication {

    public static void main(String[] args) {
        System.out.println("SPRING VERSION: " + SpringVersion.getVersion());
        SpringApplication.run(ChaTogetherApplication.class, args);
    }
}
