//
// Swift MIDI Playground : Matt Grippaldi 1/1/2016
//
import CoreMIDI
import PlaygroundSupport

func getDisplayName(obj: MIDIObjectRef) -> String
{
  var param:Unmanaged<CFString>?
  var name:String = "Error"
  
  let err:OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
  if err == OSStatus(noErr)
  {
    name = param!.takeRetainedValue() as String
  }
  
  return name
}

func MyMIDIReadProc(pktList: UnsafePointer<MIDIPacketList>,
                    readProcRefCon: Optional<UnsafeMutablePointer<Void>>, srcConnRefCon: Optional<UnsafeMutablePointer<Void>>) -> Void
{
  let packetList:MIDIPacketList = pktList.pointee
  let srcRef:MIDIEndpointRef = UnsafeMutablePointer<MIDIEndpointRef>(OpaquePointer(srcConnRefCon!)).pointee
  print("MIDI Received From Source: \(getDisplayName(obj: srcRef))")
  
  var packet:MIDIPacket = packetList.packet
  for _ in 1...packetList.numPackets {
    let bytes = Mirror(reflecting: packet.data).children
    var dumpStr = ""
    
    // bytes mirror contains all the zero values in the ridiulous packet data tuple
    // so use the packet length to iterate.
    var i = packet.length
    for (_, attr) in bytes.enumerated() {
      dumpStr += String(format:"$%02X ", attr.value as! UInt8)
      i -= 1
      if i <= 0 {
        break
      }
    }
    
    print(dumpStr)
    packet = MIDIPacketNext(&packet).pointee
  }
}

var midiClient: MIDIClientRef = 0
var inPort:MIDIPortRef = 0
var src:MIDIEndpointRef = MIDIGetSource(0)

MIDIClientCreate("MidiTestClient", nil, nil, &midiClient)
MIDIInputPortCreate(midiClient, "MidiTest_InPort", MyMIDIReadProc, nil, &inPort)

MIDIPortConnectSource(inPort, src, &src)

// Keep playground running
PlaygroundPage.current.needsIndefiniteExecution = true

print("Listening to MIDI messages...")