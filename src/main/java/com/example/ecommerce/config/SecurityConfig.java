package com.example.ecommerce.config;

import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()          // disable CSRF for testing
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/**").permitAll() // allow all /api requests
                .anyRequest().permitAll()               // allow all other requests too
            );
        return http.build();
    }
}
