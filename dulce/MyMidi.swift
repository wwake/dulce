import AudioKit
import AVFAudio

public class MyMidi {
  var processingGraph: AUGraph?
  var midisynthNode   = AUNode()
  var ioNode          = AUNode()
  var midisynthUnit: AudioUnit?

  var midiChannel = 0
  var midiVelocity = 64
  let octave = 4

  func checkError(osstatus: OSStatus) {
    if osstatus != 0 {
      print("Error: \(osstatus)")
    }
  }

  // Mark: - Audio Init Utility Methods
  private func createIONode() {
    var cd = AudioComponentDescription(
      componentType: OSType(kAudioUnitType_Output),
      componentSubType: OSType(kAudioUnitSubType_RemoteIO),
      componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
      componentFlags: 0,componentFlagsMask: 0)
    checkError(osstatus: AUGraphAddNode(processingGraph!, &cd, &ioNode))
  }
  private func createSynthNode() {
    var cd = AudioComponentDescription(
      componentType: OSType(kAudioUnitType_MusicDevice),
      componentSubType: OSType(kAudioUnitSubType_MIDISynth),
      componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
      componentFlags: 0,componentFlagsMask: 0)
    checkError(osstatus: AUGraphAddNode(processingGraph!, &cd, &midisynthNode))
  }

  func initAudio() {
    // the graph is like a patch bay, where everything gets connected
    checkError(osstatus: NewAUGraph(&processingGraph))
    createIONode()
    createSynthNode()
    checkError(osstatus: AUGraphOpen(processingGraph!))
    checkError(osstatus: AUGraphNodeInfo(processingGraph!, midisynthNode, nil, &midisynthUnit))
    let synthOutputElement:AudioUnitElement = 0
    let ioUnitInputElement:AudioUnitElement = 0
    checkError(osstatus:
                AUGraphConnectNodeInput(processingGraph!, midisynthNode, synthOutputElement, ioNode, ioUnitInputElement))
    checkError(osstatus: AUGraphInitialize(processingGraph!))
    checkError(osstatus: AUGraphStart(processingGraph!))
  }

  func noteOn(note: UInt8) {
    let noteCommand = UInt32(0x90 | midiChannel)
//    let base = note - 48
//    let octaveAdjust = (UInt8(octave) * 12) + base
    //let pitch = UInt32(octaveAdjust)
    let pitch = UInt32(note)
    checkError(osstatus: MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, pitch, UInt32(self.midiVelocity), 0))
  }

  func noteOff(note: UInt8) {
    let channel = UInt32(0)
    let noteCommand = UInt32(0x80 | channel)
//    let base = note - 48
//    let octaveAdjust = (UInt8(octave) * 12) + base
  //  let pitch = UInt32(octaveAdjust)
    let pitch = UInt32(note)
    checkError(osstatus: MusicDeviceMIDIEvent(self.midisynthUnit!,
                                              noteCommand, pitch, 0, 0))
  }

  func start() {
    initAudio()
  }

  func sound(channel: UInt8, note: UInt8, volume: UInt8 = 64) {
    noteOn(note: note)
  }

  // midi.createVirtualOutputPorts()
  //midi.openOutput(index: 0)
  //    midi.openOutput()
  //    midi.sendNoteOnMessage(noteNumber: 64, velocity: 127, channel: 3)

}
