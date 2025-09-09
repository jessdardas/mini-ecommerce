package com.example.ecommerce.controller;

import com.example.ecommerce.model.Product;
import com.example.ecommerce.repository.ProductRepository;
import com.example.ecommerce.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // GET all products (anyone)
    @GetMapping
    public ResponseEntity<?> getAllProducts() {
        return ResponseEntity.ok(productRepository.findAll());
    }

    // POST new product (Admins only)
    @PostMapping
    public ResponseEntity<?> addProduct(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Product product) {

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Missing or invalid token");
        }

        String token = authHeader.substring(7);
        String role = jwtUtil.extractRole(token);

        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Admins only");
        }

        Product savedProduct = productRepository.save(product);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedProduct);
    }
}
