package pl.edu.pw.eiti.mwas.users;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

@Path("/users")
@RegisterRestClient(configKey = "users")
public interface UsersRestClient {

    @GET
    @Path("/{userId}")
    public User getUserById(@PathParam("userId") Long userId);
}
