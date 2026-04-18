package gamelogic;

interface Connectable {
    public var isOutput: Bool;
    public function newInput(w: Waveform): Void;
    public function getWaveform(): Waveform;
}