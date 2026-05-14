package pl.edu.pw.eiti.mwas.tasks;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.RequiredArgsConstructor;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@ToString
@Builder
@RequiredArgsConstructor
@AllArgsConstructor
@Entity
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public Long userId;

    public String title;
    public String content;

    @Enumerated(EnumType.STRING)
    public TaskStatus status;

    @CreationTimestamp
    public LocalDateTime createdAt;

    public LocalDateTime completedAt;
}
