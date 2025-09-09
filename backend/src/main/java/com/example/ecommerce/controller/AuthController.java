package com.example.ecommerce.controller;

import com.example.ecommerce.model.User;
import com.example.ecommerce.model.UserRole;
import com.example.ecommerce.repository.UserRepository;
import com.example.ecommerce.util.JwtUtil;
import com.example.ecommerce.controller.AuthController.AuthResponse;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;
   


    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // REGISTER
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody AuthRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email already in use");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(UserRole.USER); // Default role
        User savedUser = userRepository.save(user);

        return ResponseEntity.status(201).body(savedUser);
    }
// LOGIN
@PostMapping("/login")
public ResponseEntity<?> login(@RequestBody AuthRequest request) {
    return userRepository.findByEmail(request.getEmail())
            .map(user -> {
                if (passwordEncoder.matches(request.getPassword(), user.getPassword())) {
                    try {
                        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());
                        return ResponseEntity.ok(new AuthResponse(token,user.getRole().name()));
                    } catch (Exception e) {
                        e.printStackTrace(); // log full error in console
                        return ResponseEntity.status(500).body("Token generation failed: " + e.getMessage());
                    }
                } else {
                    return ResponseEntity.status(401).body("Invalid password");
                }
            }).orElse(ResponseEntity.status(401).body("User not found"));
}


    @Data
    static class AuthRequest {
        private String email;
        private String password;
    }

    @Data
    static class AuthResponse {
        private final String token;
        private final String role;
    }
}
