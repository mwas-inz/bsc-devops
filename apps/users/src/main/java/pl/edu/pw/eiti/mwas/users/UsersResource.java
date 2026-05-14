package pl.edu.pw.eiti.mwas.users;

import io.quarkus.hibernate.orm.rest.data.panache.PanacheEntityResource;

public interface UsersResource extends PanacheEntityResource<User, Long> {
}
