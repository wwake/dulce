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

  func noteOn(channel: Int, note: UInt8) {
    print("+ \(note)@\(channel)")
    let noteCommand = UInt32(0x90 | channel)
    let pitch = UInt32(note)
    checkError(osstatus: MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, pitch, UInt32(self.midiVelocity), 0))
  }

  func noteOff(channel: Int, note: UInt8) {
    print("- \(note)@\(channel)")
    let noteCommand = UInt32(0x80 | channel)
    let pitch = UInt32(note)
    checkError(osstatus: MusicDeviceMIDIEvent(
      self.midisynthUnit!,
      noteCommand,
      pitch,
      0,
      0
    ))
  }

  func start() {
    initAudio()
  }
}
