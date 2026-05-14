package pl.edu.pw.eiti.mwas.taskarchiver;

import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.reactive.messaging.Incoming;
import pl.edu.pw.eiti.mwas.tasks.TaskRepository;

@ApplicationScoped
public class DeletionConsumer {

    @Inject
    TaskRepository repository;

    @Incoming("delete-tasks")
    @Transactional
    public void deleteTask(Long taskId) {
        Log.info("Deleting task with taskId=" + taskId);
        repository.deleteById(taskId);
    }
}
