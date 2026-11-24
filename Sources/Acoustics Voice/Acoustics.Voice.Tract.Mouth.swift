extension Acoustics.Voice.Tract {
    /// How the tube ends at the mouth.
    public enum Mouth: Hashable, Sendable {
        /// An ideal open end: no pressure, every wave reflected inverted.
        case open
        /// The mouth radiates as a piston in an infinite baffle, its impedance a resistance R = 128ρc / 9π²A in
        /// parallel with an inertance L = 8ρa / 3πA, a the radius of the mouth's area A (Flanagan 1972, Speech
        /// Analysis, Synthesis and Perception, 2nd ed., §3.2).
        case radiating
    }
}
