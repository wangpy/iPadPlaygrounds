// code modified from: http://mattg411.com/coremidi-swift-programming/

//
// Swift MIDI Playground : Matt Grippaldi 1/1/2016
//
import CoreMIDI

func getDisplayName(obj: MIDIObjectRef) -> String
{
  var param:Unmanaged<CFString>?
  var name:String = "Error"
  
  let err:OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
  if err == OSStatus(noErr) {
    name = param!.takeRetainedValue() as String
  }
  
  return name
}

func getDestinationNames() -> [String]
{
  var names:[String] = [String]()

  let count:Int = MIDIGetNumberOfDestinations()
  for i in 0..<count {
    let endpoint:MIDIEndpointRef = MIDIGetDestination(i)
    if endpoint != 0 {
      names.append(getDisplayName(obj: endpoint))
    }
  }
  return names
}

func getSourceNames() -> [String]
{
  var names:[String] = [String]()
  
  let count:Int = MIDIGetNumberOfSources()
  for i in 0..<count {
    let endpoint:MIDIEndpointRef = MIDIGetSource(i)
    if endpoint != 0 {
      names.append(getDisplayName(obj: endpoint))
    }
  }
  return names
}

let destNames = getDestinationNames()
print("Number of MIDI destinations: \(destNames.count)")
for destName in destNames {
  print("Destination: \(destName)")
}

let sourceNames = getSourceNames()
print("Number of MIDI sources: \(sourceNames.count)")
for sourceName in sourceNames {
  print("Source: \(sourceName)")
}
