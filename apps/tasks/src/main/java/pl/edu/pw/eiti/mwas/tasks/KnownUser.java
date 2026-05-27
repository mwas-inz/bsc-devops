package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "known_users")
public class KnownUser extends PanacheEntityBase {

    @Id
    public Long id;
}
