//#-hidden-code
//
// Swift MIDI Playground : Matt Grippaldi 1/1/2016
//
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
