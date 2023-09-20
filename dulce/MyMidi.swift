import AudioKit

public class MyMidi {
  //let midi = AudioKit.MIDI.sharedInstance
  let midi = MIDI()

  func start() {
   // midi.createVirtualOutputPorts()
    //midi.openOutput(index: 0)
    midi.openOutput()
    midi.sendNoteOnMessage(noteNumber: 64, velocity: 127, channel: 3)
  }

}
