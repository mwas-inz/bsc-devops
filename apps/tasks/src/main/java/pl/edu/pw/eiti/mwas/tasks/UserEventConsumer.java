package pl.edu.pw.eiti.mwas.tasks;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.reactive.messaging.Incoming;

@ApplicationScoped
public class UserEventConsumer {

    @Inject
    ObjectMapper objectMapper;

    @Incoming("user-events")
    @Transactional
    public void onMessage(String message) {
        try {
            consume(objectMapper.readValue(message, UserEvent.class));
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Transactional
    void consume(UserEvent event) {
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
