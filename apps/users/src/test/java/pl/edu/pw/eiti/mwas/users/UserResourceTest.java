package pl.edu.pw.eiti.mwas.users;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
class UserResourceTest {
    @Test
    void testListUsers() {
        given()
          .when().get("/users")
          .then()
             .statusCode(200);
    }
}
