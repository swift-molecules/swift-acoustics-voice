public import Acoustics

extension Acoustics {
    /// A voice: air from the lungs or air sacs driven through a source that opens and closes, into a vocal tract
    /// that shapes it, making one call.
    ///
    /// The source is vocal folds (`Folds`) for a mammal and the syringeal labia (`Syrinx`) for a bird. Both are
    /// opened by the air they let through and close by their own elasticity, and both feel the pressure the tract
    /// sends back. The tract is a tube of varying area (`Tract`), stepped as a Kelly–Lochbaum waveguide.
    public struct Voice: Hashable, Sendable {
        public var tract: Tract
        public var source: Source
        public var call: Call

        public init(tract: Tract, source: Source, call: Call) {
            self.tract = tract
            self.source = source
            self.call = call
        }
    }
}
