package chatogether.ChaTogether.filters;

import chatogether.ChaTogether.services.JWTService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.io.PrintWriter;

public class AuthRequestFilter extends OncePerRequestFilter {
    private static final ThreadLocal<String> jwtToken = new ThreadLocal<>();
    private static final ThreadLocal<String> username = new ThreadLocal<>();
    private static final ThreadLocal<String> email = new ThreadLocal<>();
    private static final ThreadLocal<String> firstName = new ThreadLocal<>();
    private static final ThreadLocal<String> lastName = new ThreadLocal<>();
    private JWTService jwtService;

    @Override
    protected void initFilterBean() throws ServletException {
        super.initFilterBean();
        ServletContext servletContext = getServletContext();
        WebApplicationContext webApplicationContext = WebApplicationContextUtils.getWebApplicationContext(servletContext);
        assert webApplicationContext != null;
        jwtService = webApplicationContext.getBean(JWTService.class);
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer")) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            PrintWriter writer = response.getWriter();
            writer.write("Unauthorized: Authentication token was either missing or invalid.");
            writer.flush();
            return;
        }

        String token = authHeader.split(" ")[1];
        jwtToken.set(token);
        Claims claims;
        try {
            claims = jwtService.decodeToken(token);
        } catch (Exception e) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            PrintWriter writer = response.getWriter();
            writer.write("Unauthorized: Authentication token was either missing or invalid.");
            writer.flush();
            return;
        }

        username.set(claims.get("username", String.class));
        email.set(claims.get("email", String.class));
        firstName.set(claims.get("firstName", String.class));
        lastName.set(claims.get("lastName", String.class));

        filterChain.doFilter(request, response);
    }

    public static String getJwtToken() {
        return jwtToken.get();
    }

    public static String getUsername() {
        return username.get();
    }

    public static String getEmail() {
        return email.get();
    }

    public static String getFirstName() {
        return firstName.get();
    }

    public static String getLastName() {
        return lastName.get();
    }
}
