package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class TaskRepository implements PanacheRepository<Task> {
    public List<Task> findTasksByUserId(Long userId) {
        return list("userId", userId);
    }
}
