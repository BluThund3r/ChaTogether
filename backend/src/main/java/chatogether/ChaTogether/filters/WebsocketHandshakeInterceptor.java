package chatogether.ChaTogether.filters;

import chatogether.ChaTogether.services.JWTService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;
import java.util.Objects;

@RequiredArgsConstructor
public class WebsocketHandshakeInterceptor implements HandshakeInterceptor {

    private final JWTService jwtService;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        if (request instanceof ServletServerHttpRequest) {
            ServletServerHttpRequest servletRequest = (ServletServerHttpRequest) request;
            String header;
            try {
                header = Objects.requireNonNull(servletRequest.getHeaders().get("Authorization")).getFirst();
            } catch (NullPointerException e) {
                return false;
            }

            if (!header.startsWith("Bearer "))
                return false;
            String token = header.split(" ")[1];

            try {
                var claims = jwtService.decodeToken(token);
                attributes.put("username", claims.get("username", String.class));
                attributes.put("email", claims.get("email", String.class));
                attributes.put("firstName", claims.get("firstName", String.class));
                attributes.put("lastName", claims.get("lastName", String.class));
                attributes.put("userId", claims.get("userId", Long.class));
            } catch (Exception e) {
                return false;
            }
        }

        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Exception exception) {

    }
}
