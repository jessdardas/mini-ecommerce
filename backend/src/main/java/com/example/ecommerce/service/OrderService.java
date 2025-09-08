package com.example.ecommerce.service;

import com.example.ecommerce.dto.OrderRequest;
import com.example.ecommerce.model.Order;
import com.example.ecommerce.model.OrderItem;
import com.example.ecommerce.model.Product;
import com.example.ecommerce.repository.OrderRepository;
import com.example.ecommerce.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {

    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;

    public OrderService(ProductRepository productRepository, OrderRepository orderRepository) {
        this.productRepository = productRepository;
        this.orderRepository = orderRepository;
    }

    @Transactional
    public Order placeOrder(Long userId, List<OrderRequest.OrderItemRequest> itemsRequest) throws Exception {
        if (itemsRequest == null || itemsRequest.isEmpty()) {
            throw new Exception("Order must contain at least one item.");
        }

        List<OrderItem> orderItems = new ArrayList<>();

        for (OrderRequest.OrderItemRequest itemReq : itemsRequest) {
            // 1. Check if product exists
            Optional<Product> productOpt = productRepository.findById(itemReq.getProductId());
            if (productOpt.isEmpty()) {
                throw new Exception("Product with ID " + itemReq.getProductId() + " not found.");
            }

            Product product = productOpt.get();

            // 2. Check if enough stock
            if (product.getQuantity() < itemReq.getQuantity()) {
                throw new Exception("Insufficient stock for product: " + product.getName() +
                                    ". Requested: " + itemReq.getQuantity() +
                                    ", Available: " + product.getQuantity());
            }

            // 3. Decrement stock
            product.setQuantity(product.getQuantity() - itemReq.getQuantity());
            productRepository.save(product);

            // 4. Create OrderItem
            OrderItem orderItem = new OrderItem();
            orderItem.setQuantity(itemReq.getQuantity());
            orderItem.setPrice(product.getPrice()); // record price at time of order
            orderItems.add(orderItem);
        }

        // 5. Create Order
        Order order = new Order();
        order.setUserId(userId);
        order.setItems(orderItems);
        order.setCreatedAt(LocalDateTime.now());

        // 6. Save and return
        return orderRepository.save(order);
    }

    public List<Order> getUserOrders(Long userId) {
        return orderRepository.findByUserId(userId);
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
}
