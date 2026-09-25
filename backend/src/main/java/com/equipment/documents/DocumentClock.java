package com.equipment.documents;
import java.time.Clock;
import java.time.ZoneId;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class DocumentClock {
    @Bean Clock workspaceClock() {return Clock.system(ZoneId.of("Asia/Riyadh"));}
}
