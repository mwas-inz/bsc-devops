package pl.edu.pw.eiti.mwas.tasks;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.reactive.messaging.Incoming;

@ApplicationScoped
public class UserEventConsumer {

    @Incoming("user-events")
    @Transactional
    public void consume(UserEvent event) {
        switch (event.type()) {
            case CREATED -> {
                KnownUser user = new KnownUser();
                user.id = event.userId();
                KnownUser.persist(user);
            }
            case DELETED -> KnownUser.deleteById(event.userId());
        }
    }
}
