package gamelogic;

interface Connectable {
    public var isOutput: Bool;
    public function newInput(c: Connectable): Void;
    public function getWaveform(): Waveform;
    public function disconnect(c: Connectable): Void;
}