package pl.edu.pw.eiti.mwas.users;

public record UserEvent(Long userId, Type type) {
    public enum Type { CREATED, DELETED }
}
