package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
class TaskResourceTest {
    @Test
    void testGetTasksForUser() {
        given()
                .when().get("/users/1/tasks/")
                .then()
                .statusCode(200);
    }
}
