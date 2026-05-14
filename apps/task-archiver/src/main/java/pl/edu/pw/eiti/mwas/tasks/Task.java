package pl.edu.pw.eiti.mwas.tasks;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public Long userId;

    public String title;

    public String content;

    public String status;

    @CreationTimestamp
    public LocalDateTime createdAt;

    public LocalDateTime completedAt;
}
