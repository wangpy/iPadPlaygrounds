/*: 
 Code referenced from https://github.com/genedelisa/MIDISynth/blob/master/MIDISynth/AVAudioUnitDistortionEffect.swift
 
 SoundFont from: http://sourceforge.net/p/mscore/code/HEAD/tree/trunk/mscore/share/sound/TimGM6mb.sf2?format=raw
 MuseScore 1 came with TimGM6mb (5.7 MB uncompressed)
 License: GNU GPL, version 2
 Courtesy of Tim Brechbill (http://ocmnet.com/saxguru/Timidity.htm#sf2)
 */
import PlaygroundSupport
import AVFoundation
import Foundation

let engine = AVAudioEngine()
do {
  try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
  let ioBufferDuration = 128.0 / 44100.0
  try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
} catch {
  assertionFailure("AVAudioSession setup error: \(error)")
}

// following assert causes error in iOS swift playgrounds
//assert(engine.inputNode != nil)
let output = engine.outputNode
let format = output.outputFormat(forBus: 0)

let instrumentDescription = AudioComponentDescription(
  componentType: kAudioUnitType_MusicDevice,
  componentSubType: kAudioUnitSubType_MIDISynth,
  componentManufacturer: kAudioUnitManufacturer_Apple,
  componentFlags: 0,
  componentFlagsMask: 0)
let instrument = AVAudioUnitMIDIInstrument(audioComponentDescription: instrumentDescription)

guard var bankURL = Bundle.main().urlForResource("TimGM6mb", withExtension: "sf2")
  else {
    fatalError("Get the default sound font URL correct!")
}

print("loading sound font....")
var status = AudioUnitSetProperty(instrument.audioUnit, AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL), AudioUnitScope(kAudioUnitScope_Global), 0, &bankURL, UInt32(sizeof(bankURL.dynamicType)))
if status != OSStatus(noErr) {
  fatalError("load sound font error \(status)")
} else {
  print("loaded sound font")
}
engine.attach(instrument)
print("instrument attached")

engine.connect(instrument, to: output, format: format)

print("starting AVAudioEngine...please wait for loading sound font")
do {
  try engine.start()
  print("AVAudioEngine started")
} catch {
  assertionFailure("AVAudioEngine start error: \(error)")
}

var enabled = UInt32(1)

status = AudioUnitSetProperty(
  instrument.audioUnit,
  AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
  AudioUnitScope(kAudioUnitScope_Global),
  0,
  &enabled,
  UInt32(sizeof(UInt32)))
if status != OSStatus(noErr) {
  print("enable preload error \(status)")
}

for patch:UInt8 in 0...127 {
  print("preloading patch \(patch)")
  instrument.sendProgramChange(patch, onChannel: 0)
}

enabled = UInt32(0)
status = AudioUnitSetProperty(
  instrument.audioUnit,
  AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
  AudioUnitScope(kAudioUnitScope_Global),
  0,
  &enabled,
  UInt32(sizeof(UInt32)))
if status != OSStatus(noErr) {
  print("error \(status)")
}

PlaygroundPage.current.needsIndefiniteExecution = true

//#-editable-code
var program:UInt8 = 0
while true {
  print("program: \(program)")
  instrument.sendProgramChange(program, onChannel: 0)
  let note:UInt8 = 40
  instrument.startNote(note, withVelocity: 64, onChannel: 0)
  sleep(1)
  instrument.stopNote(note, onChannel: 0)
  sleep(1)
  program = (program + 1) % 128
}
//#-end-editable-code

