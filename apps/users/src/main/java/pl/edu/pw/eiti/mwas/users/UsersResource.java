package pl.edu.pw.eiti.mwas.users;

import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import java.util.List;

@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UsersResource {

    @Channel("user-events")
    Emitter<UserEvent> userEvents;

    @GET
    public List<User> list() {
        return User.listAll();
    }

    @GET
    @Path("/{id}")
    public User get(@PathParam("id") Long id) {
        return User.findById(id);
    }

    @POST
    @Transactional
    public Response create(User user) {
        User.persist(user);
        userEvents.send(new UserEvent(user.id, UserEvent.Type.CREATED));
        return Response.status(Response.Status.CREATED).entity(user).build();
    }

    @DELETE
    @Path("/{id}")
    @Transactional
    public Response delete(@PathParam("id") Long id) {
        User.deleteById(id);
        userEvents.send(new UserEvent(id, UserEvent.Type.DELETED));
        return Response.noContent().build();
    }
}
