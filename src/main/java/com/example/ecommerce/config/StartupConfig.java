package com.example.ecommerce.config;

import com.example.ecommerce.model.User;
import com.example.ecommerce.model.UserRole;
import com.example.ecommerce.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Configuration
public class StartupConfig {

    @Bean
    CommandLineRunner initAdmin(UserRepository userRepository) {
        return args -> {
            // Check if admin already exists
            if(userRepository.findByEmail("admin@example.com").isEmpty()) {
                User admin = new User();
                admin.setEmail("admin@example.com");
                admin.setPassword(new BCryptPasswordEncoder().encode("admin123"));
                admin.setRole(UserRole.ADMIN);
                userRepository.save(admin);
                System.out.println("Default admin created: admin@example.com / admin123");
            }
        };
    }
}
