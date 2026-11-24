extension Acoustics.Voice {
    /// The state of a waveguide's mouth: its radiation filter, and the flow out of it.
    struct Radiation {
        var flow: Double = 0
        var numerator: (Double, Double) = (0, 0)
        var denominator: (Double, Double) = (1, 0)
        var lastForward: Double = 0
        var lastReflected: Double = 0
    }
}
