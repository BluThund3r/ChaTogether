package chatogether.ChaTogether.services;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.util.Date;
import java.util.Map;

@Service
public class JWTService {

    @Value("${jwt.secret}")
    private String JWT_SECRET;
    private Key key;

    @PostConstruct
    public void init() {
        key = new SecretKeySpec(JWT_SECRET.getBytes(), SignatureAlgorithm.HS256.getJcaName());
    }

    public String createToken(Map<String, Object> claims) {
        return Jwts.builder()
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 10))
                .setClaims(claims)
                .signWith(key)
                .compact();
    }

    public Claims decodeToken(String token) { // throws an error if the token is invalid or expired
        var jwtParser = Jwts.parserBuilder()
                .setSigningKey(key)
                .build();

        return jwtParser.parseClaimsJws(token).getBody();
    }

    public String getUsernameFromToken(String token) {
        return decodeToken(token).getSubject();
    }
}

//@Service
//public class JWTService {
//
//    public String generateJWT(Map<String, Object> claims) {
//        var header = new JWSHeader();
//        var claimsSet = buildClaimsSet(claims);
//
//        var jwt = new SignedJWT(header, claimsSet);
//
//        try {
//            var signer = new MACSigner(key);
//            jwt.sign(signer);
//        } catch (JOSEException e) {
//            throw new RuntimeException("Unable to generate JWT", e);
//        }
//
//        return jwt.serialize();
//    }
//
//    private JWTClaimsSet buildClaimsSet(Map<String, Object> claims) {
//        var issuer = appJwtProperties.getIssuer();
//        var issuedAt = Instant.now();
//        var expirationTime = issuedAt.plus(appJwtProperties.getExpiresIn());
//
//        var builder = new JWTClaimsSet.Builder()
//                .issuer(issuer)
//                .issueTime(Date.from(issuedAt))
//                .expirationTime(Date.from(expirationTime));
//
//        claims.forEach(builder::claim);
//
//        return builder.build();
//    }
//
//}
