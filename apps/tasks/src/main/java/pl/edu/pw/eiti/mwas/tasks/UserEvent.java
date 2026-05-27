package pl.edu.pw.eiti.mwas.tasks;

public record UserEvent(Long userId, Type type) {
    public enum Type { CREATED, DELETED }
}
