package chatogether.ChaTogether.config;

import chatogether.ChaTogether.filters.AuthRequestFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<AuthRequestFilter> authRequestFilter() {
        FilterRegistrationBean<AuthRequestFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new AuthRequestFilter());
        registrationBean.addUrlPatterns("/friendship/*");   // add more url patterns if needed
        registrationBean.addUrlPatterns("/user/*");
        registrationBean.addUrlPatterns("/chatRoom/*");
        registrationBean.addUrlPatterns("/chatMessages/*");

        return registrationBean;
    }
}
