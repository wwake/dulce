import AudioToolbox

typealias MidiNoteNumber = UInt8

struct MidiNoteInfo: Equatable {
  var note: MidiNoteNumber
  var duration: Float32
  var time: MusicTimeStamp
}

public enum SoundState: Equatable {
  case uninitialized
  case ready
  case playing
  case error
}


enum NoteInfo: Equatable {
  case note(MidiNoteInfo)
  case stop(MusicTimeStamp)
}

typealias Symbol = NoteInfo

public class SoundPlayer {
  private static let instance = SoundPlayer()
  var musicPlayer: MusicPlayer!
  var status: OSStatus = 0
  let defaultBpm = 120.0

  var sequence: MusicSequence! = nil
  var track: MusicTrack! = nil

//  static func make(_ symbols: [Symbol]) -> SoundPlayer {
//    instance.deleteExistingPlayer()
//    instance.configureNewPlayer(Self.toNoteInfo(symbols))
//    return instance
//  }

  fileprivate func deleteExistingPlayer() {
    if musicPlayer != nil {
      _ = MusicPlayerStop(musicPlayer)
      _ = DisposeMusicPlayer(musicPlayer)
      musicPlayer = nil
    }
  }

//  static func toNoteInfo(_ symbols: [Symbol]) -> [NoteInfo] {
//    var result: [NoteInfo] = []
//    var beat: MusicTimeStamp = 1.0
//
//    symbols
//      .forEach { symbol in
//        let duration = 3.0 //Float32(symbol.rhythm.ratio * 4)
//
//        if case .note(let note) = symbol {
//          result.append(.note(MidiNoteInfo(note: note.pitch.noteNumber, duration: duration, time: beat)))
//        }
//        beat += MusicTimeStamp(duration)
//      }
//
//    result.append(.stop(Double(beat + 2.0)))
//    return result
//  }
//

  let callback: MusicSequenceUserCallback? = { inPlayer, _, _, _, _, _, _ in
    let musicPlayer = unsafeBitCast(inPlayer, to: MusicPlayer.self)

    DispatchQueue.main.async {
      _ = MusicPlayerStop(musicPlayer)
    }
  }

  func startPlayer() {
    status = 0
    status |= NewMusicPlayer(&musicPlayer)
    status |= NewMusicSequence(&sequence)
    status |= MusicPlayerSetSequence(musicPlayer, sequence)
    status |= MusicSequenceNewTrack(sequence, &track)

    status |= MusicSequenceSetUserCallback(
      sequence,
      callback,
      unsafeBitCast(musicPlayer, to: UnsafeMutableRawPointer.self)
    )
  }

  // call startPlayer
  // sound(note)
  // call play

  func sound(_ note: UInt8) {
    var noteMessage = MIDINoteMessage(
      channel: 0,
      note: note,
      velocity: 64,
      releaseVelocity: 0,
      duration: 0.3
    )
    status |= MusicTrackNewMIDINoteEvent(track, 0, &noteMessage)
  }

  func configureNewPlayer(_ notes: [NoteInfo]) {
    startPlayer()

    for noteInfo in notes {
      switch noteInfo {
      case .note(let midiNoteInfo):
        var note = MIDINoteMessage(
          channel: 0,
          note: midiNoteInfo.note,
          velocity: 64,
          releaseVelocity: 0,
          duration: midiNoteInfo.duration
        )
        status |= MusicTrackNewMIDINoteEvent(track, midiNoteInfo.time, &note)

      case .stop(let stopTime):
        var eventData = MusicEventUserData(length: 1, data: 0)
        status = MusicTrackNewUserEvent(track, stopTime, &eventData)
      }
    }
  }

  func setSpeed(bpm: Double) -> SoundState {
    let speed = bpm / defaultBpm
    let status = MusicPlayerSetPlayRateScalar(musicPlayer, speed)
    if status != 0 { return .error }
    return .playing
  }

  public func play(_ bpm: Double) -> SoundState {
    let speedState = setSpeed(bpm: bpm)
    if speedState != .playing { return speedState }

    status |= MusicPlayerStart(musicPlayer)
    if status != 0 { return .error }

    return .playing
  }

  public func stop() -> SoundState {
    status |= MusicPlayerStop(musicPlayer)
    return status == 0 ? .ready : .error
  }
}
