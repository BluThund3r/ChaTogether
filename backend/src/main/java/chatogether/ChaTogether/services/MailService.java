package chatogether.ChaTogether.services;

import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.stereotype.Service;
import org.springframework.ui.ModelMap;
import org.springframework.ui.freemarker.FreeMarkerTemplateUtils;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;

@Service
public class MailService {
    private final JavaMailSender mailSender;
    private final FreeMarkerConfigurer freemarkerConfigurer;

    @Value("${spring.mail.username}")
    private String EMAIL_USERNAME;

    @Value("${server.port}")
    private String SERVER_PORT;

    @Value("${server.address}")
    private String SERVER_ADDRESS;

    public MailService(JavaMailSender mailSender, FreeMarkerConfigurer freemarkerConfigurer) {
        this.freemarkerConfigurer = freemarkerConfigurer;
        this.mailSender = mailSender;
    }

    public void sendEmail(String to, String subject, String templateName, ModelMap modelMap) {
        MimeMessagePreparator messagePreparator = mimeMessage -> {
            var template = freemarkerConfigurer.getConfiguration().getTemplate(templateName);
            var html = FreeMarkerTemplateUtils.processTemplateIntoString(template, modelMap);

            var messageHelper = new MimeMessageHelper(mimeMessage);
            messageHelper.setFrom(EMAIL_USERNAME);
            messageHelper.setTo(to);
            messageHelper.setSubject(subject);
            messageHelper.setText(html, true);
        };

        mailSender.send(messagePreparator);

        System.out.println("Email sent to " + to);
    }

    public void sendConfirmationEmail(String to, String username, String firstName, String lastName, String confirmationToken) {
        String subject = "Welcome to ChaTogether! Please confirm your email address";
        String templateName = "mail_confirmation.ftl";
        ModelMap modelMap = new ModelMap();
        modelMap.addAttribute("confirmationToken", confirmationToken);
        modelMap.addAttribute("username", username);
        modelMap.addAttribute("email", to);
        modelMap.addAttribute("firstName", firstName);
        modelMap.addAttribute("lastName", lastName);

        sendEmail(to, subject, templateName, modelMap);
    }
}
