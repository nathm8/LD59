package gamelogic;

import gamelogic.Waveform.WaveformInverter;
import gamelogic.Waveform.Square;
import gamelogic.Waveform.Triangle;
import gamelogic.Waveform.WaveformCombination;
import gamelogic.Waveform.Sine;

var levels = new Array<Waveform>();

function initLevels() {

    var targetOne = new Sine(4/8, 6/8);
    
    // AM modulation
    var targetTwo = new WaveformCombination(false);
    targetTwo.weight = 3/6;
    targetTwo.sourceOne = new Sine(1.0, 7/8);
    targetTwo.sourceTwo = targetOne;

    // saw wave, TODO
    var targetThree = new WaveformCombination(true);
    targetThree.sourceOne = new Triangle(0.5, 0.5);
    targetThree.sourceTwo = new Square(0.5, 0.5);

    // ^U^
    var and = new WaveformCombination(true);
    and.sourceOne = new Triangle(0.5, 3/8);
    and.sourceTwo = and.sourceOne;
    var targetFour = new WaveformInverter();
    targetFour.source = and;

    // ideas
    // amplifier

    // replace
    var targetFive = new WaveformCombination(false);
    targetFive.weight = 4/8;
    targetFive.sourceOne = new Sine(0.5, 2/8);
    var or = new WaveformCombination(false);
    or.weight = 4/8;
    or.sourceOne = new Triangle(0.5, 1/8);
    or.sourceTwo = new Square(4/8, 0.5);
    targetFive.sourceTwo = or;

    // this is fine
    var targetSix = new WaveformCombination(true);
    targetSix.sourceOne = new Square(1/8, 0.5);
    var invert = new WaveformInverter();
    invert.source = targetSix.sourceOne;
    targetSix.sourceTwo = invert;

    levels = [targetOne, targetTwo, targetThree, targetFour, targetFive, targetSix];
}