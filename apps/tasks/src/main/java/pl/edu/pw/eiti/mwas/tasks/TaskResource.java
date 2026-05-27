package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.logging.Log;
import jakarta.inject.Inject;
import jakarta.ws.rs.NotFoundException;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import java.time.LocalDateTime;
import java.util.List;

@Path("/users/{userId}/tasks")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TaskResource {

    @Inject
    TaskRepository repository;

    @Channel("delete-tasks")
    Emitter<Long> deleteTasks;

    @GET
    public List<Task> getTasks(@PathParam("userId") Long userId) {
        checkIfUserIsPresent(userId);
        Log.info("Retrieving tasks for user " + userId);
        return repository.findTasksByUserId(userId);
    }

    @GET
    @Path("/{taskId}")
    public Task getTask(@PathParam("userId") Long userId, @PathParam("taskId") Long taskId) {
        checkIfUserIsPresent(userId);
        Log.info("Retrieving task with id " + taskId);
        return repository.findById(taskId);
    }

    @POST
    @Transactional
    public Response createTask(@PathParam("userId") Long userId, Task task) {
        checkIfUserIsPresent(userId);
        Task aTask = Task.builder()
                .userId(userId)
                .title(task.title)
                .content(task.content)
                .status(TaskStatus.created)
                .build();
        repository.persist(aTask);

        Log.info("Saving task: " + aTask);

        return Response.ok(aTask).build();
    }

    @PATCH
    @Path("/{taskId}")
    @Transactional
    public Response changeStatus(@PathParam("userId") Long userId, @PathParam("taskId") Long taskId, Task task) {
        checkIfUserIsPresent(userId);
        Task aTask = repository.findById(taskId);
        if (task.status == TaskStatus.done) {
            Log.info("Closing task: " + aTask);
            aTask.status = TaskStatus.done;
            aTask.completedAt = LocalDateTime.now();
        }

        return Response.ok(aTask).build();
    }

    @DELETE
    @Path("/{taskId}")
    public Response deleteTask(@PathParam("userId") Long userId, @PathParam("taskId") Long taskId) {
        checkIfUserIsPresent(userId);
        Task aTask = repository.findById(taskId);
        Log.info("Scheduled deletion of task: " + aTask);

        deleteTasks.send(taskId);

        return Response.ok().build();
    }

    private void checkIfUserIsPresent(Long userId) {
        if (KnownUser.findById(userId) == null) {
            throw new NotFoundException("User with id " + userId + " not found");
        }
    }
}
