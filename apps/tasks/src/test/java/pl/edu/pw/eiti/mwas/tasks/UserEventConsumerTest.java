package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.test.TestTransaction;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

@QuarkusTest
class UserEventConsumerTest {

    @Inject
    UserEventConsumer consumer;

    @Test
    @TestTransaction
    void createdEventPersistsKnownUser() {
        consumer.consume(new UserEvent(99L, UserEvent.Type.CREATED));
        assertNotNull(KnownUser.findById(99L));
    }

    @Test
    @TestTransaction
    void deletedEventRemovesKnownUser() {
        KnownUser u = new KnownUser();
        u.id = 42L;
        KnownUser.persist(u);

        consumer.consume(new UserEvent(42L, UserEvent.Type.DELETED));

        assertNull(KnownUser.findById(42L));
    }
}
