package pl.edu.pw.eiti.mwas.users;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static io.restassured.http.ContentType.JSON;

@QuarkusTest
class UserResourceTest {

    @Test
    void testListUsers() {
        given()
            .when().get("/users")
            .then()
            .statusCode(200);
    }

    @Test
    void testCreateUser() {
        given()
            .contentType(JSON)
            .body("{\"name\":\"Alice\",\"email\":\"alice@example.com\"}")
            .when().post("/users")
            .then()
            .statusCode(201);
    }
}
