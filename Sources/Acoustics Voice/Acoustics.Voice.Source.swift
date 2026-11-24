extension Acoustics.Voice {
    /// What opens and closes in the airway and so makes the sound: vocal folds or the syrinx's labia.
    public enum Source: Hashable, Sendable {
        case folds(Folds)
        case syrinx(Syrinx)
    }
}
