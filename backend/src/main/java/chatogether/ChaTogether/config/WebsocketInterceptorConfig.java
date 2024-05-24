package chatogether.ChaTogether.config;

import chatogether.ChaTogether.filters.WebsocketHandshakeInterceptor;
import chatogether.ChaTogether.services.JWTService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class WebsocketInterceptorConfig {
    private JWTService jwtService;

    @Bean
    public WebsocketHandshakeInterceptor websocketHandshakeInterceptor() {
        return new WebsocketHandshakeInterceptor(jwtService);
    }
}
