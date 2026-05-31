package pl.edu.pw.eiti.mwas.users;

import io.quarkus.runtime.annotations.RegisterForReflection;

@RegisterForReflection
public record UserEvent(Long userId, Type type) {
    public enum Type { CREATED, DELETED }
}
