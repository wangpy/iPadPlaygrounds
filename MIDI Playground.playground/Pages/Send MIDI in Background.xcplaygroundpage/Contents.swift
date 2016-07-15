/*:
 Following code referenced from the sample code in https://developer.apple.com/videos/play/wwdc2016/507/
 */

import AVFoundation

func startAudio() {
  // Create an AudioComponentDescription for the IO unit we want to use.
  let ioUnitDesc = AudioComponentDescription(
    componentType: kAudioUnitType_Output,
    componentSubType: kAudioUnitSubType_RemoteIO,
    componentManufacturer: kAudioUnitManufacturer_Apple,
    componentFlags: 0,
    componentFlagsMask: 0)
  
  let ioUnit = try! AUAudioUnit(componentDescription: ioUnitDesc, options: AudioComponentInstantiationOptions())
  
  /*
   Set things up to render at the same sample rate as the hardware,
   up to 2 channels. Note that the hardware format may not be a standard
   format, so we make a separate render format with the same sample rate
   and the desired channel count.
   */
  let hardwareFormat = ioUnit.outputBusses[0].format
  let sampleRate = hardwareFormat.sampleRate > 0 ? hardwareFormat.sampleRate : 44100.0
  let renderFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: min(2, hardwareFormat.channelCount))
  
  try! ioUnit.inputBusses[0].setFormat(renderFormat)
  
  // Install a block which will be called to render
  ioUnit.outputProvider = { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, timestamp: UnsafePointer<AudioTimeStamp>, frameCount: AUAudioFrameCount, busIndex: Int, rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
    
    // do nothing - should produce noise in this way, but no sound actually (due to bug)
    
    return noErr
  }
  
  // Allocate render resources, then start the audio hardware
  try! ioUnit.allocateRenderResources()
  
  try! ioUnit.startHardware()
  print("audio started")
}

startAudio()

//#-hidden-code
import PlaygroundSupport
// Keep playground running
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code

/*:
 code modified from: http://mattg411.com/coremidi-swift-programming/
 */
import CoreMIDI

var midiClient:MIDIClientRef = 0
var outPort:MIDIPortRef = 0

MIDIClientCreate("MidiTestClient", nil, nil, &midiClient)
MIDIOutputPortCreate(midiClient, "MidiTest_OutPort", &outPort)

var packet = MIDIPacket()
var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet)

// Get the first destination

func sendMIDIPacket(_ packet1: MIDIPacket) {
  packetList = MIDIPacketList(numPackets: 1, packet: packet1)
  let numDestinations = MIDIGetNumberOfDestinations()
  for i in 0..<numDestinations {
    MIDISend(outPort, MIDIGetDestination(i), &packetList)
  }
}

/*:
 Edit the send MIDI code below
 */
//#-editable-code
while true {
  packet.timeStamp = 0
  packet.length = 3
  packet.data.0 = 0x90 + 0 // Note On event channel 1
  packet.data.1 = 0x3C     // Note C3
  packet.data.2 = 100      // Velocity
  sendMIDIPacket(packet)
  
  sleep(1)
  
  packet.data.0 = 0x80 + 0 // Note Off event channel 1
  packet.data.2 = 0        // Velocity
  sendMIDIPacket(packet)
  
  sleep(1)
}
//#-end-editable-code
