package chatogether.ChaTogether.config;

import com.mongodb.client.MongoClients;
import de.flapdoodle.embed.mongo.MongodExecutable;
import de.flapdoodle.embed.mongo.MongodStarter;
import de.flapdoodle.embed.mongo.config.MongodConfig;
import de.flapdoodle.embed.mongo.config.Net;
import de.flapdoodle.embed.mongo.distribution.Version;
import jakarta.annotation.PreDestroy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.data.mongodb.core.MongoTemplate;
import de.flapdoodle.embed.process.runtime.Network;


@Configuration
@Profile("test")
public class MongoTestConfig {

    private MongodExecutable mongodExecutable;

    @Bean
    public MongoTemplate mongoTemplate() throws Exception {
        String ip = "localhost";
        int port = 10000;

        MongodConfig mongodConfig = MongodConfig.builder()
                .version(Version.Main.PRODUCTION)
                .net(new Net(ip, port, Network.localhostIsIPv6()))
                .build();

        MongodStarter starter = MongodStarter.getDefaultInstance();
        mongodExecutable = starter.prepare(mongodConfig);
        mongodExecutable.start();

        return new MongoTemplate(MongoClients.create("mongodb://" + ip + ":" + port), "test");
    }

    @PreDestroy
    public void cleanUp() {
        mongodExecutable.stop();
    }
}