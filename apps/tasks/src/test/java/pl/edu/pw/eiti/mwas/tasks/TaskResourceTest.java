package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.test.junit.QuarkusTest;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
class TaskResourceTest {

    @BeforeEach
    @Transactional
    void setup() {
        KnownUser u = new KnownUser();
        u.id = 1L;
        KnownUser.persist(u);
    }

    @AfterEach
    @Transactional
    void teardown() {
        KnownUser.deleteAll();
    }

    @Test
    void testGetTasksForUser() {
        given()
            .when().get("/users/1/tasks/")
            .then()
            .statusCode(200);
    }
}
