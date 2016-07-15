//#-hidden-code
import PlaygroundSupport
import UIKit

import CoreMIDI

var midiClient:MIDIClientRef = 0
var outPort:MIDIPortRef = 0

MIDIClientCreate("MidiTestClient", nil, nil, &midiClient)
MIDIOutputPortCreate(midiClient, "MidiTest_OutPort", &outPort)

// Get the first destination
let numDestinations = MIDIGetNumberOfDestinations()

var packet1 = MIDIPacket()
var packetList = MIDIPacketList(numPackets: 1, packet: packet1)

func sendMidi(byte0: UInt8, byte1: UInt8, byte2: UInt8) {
  packet1.timeStamp = 0
  packet1.length = 3
  packet1.data.0 = byte0
  packet1.data.1 = byte1
  packet1.data.2 = byte2
  packetList = MIDIPacketList(numPackets: 1, packet: packet1)
  for i in 0..<numDestinations {
    MIDISend(outPort, MIDIGetDestination(i), &packetList)
  }
}
public enum TouchMessageType:Int {
  case Began
  case Moved
  case Ended
  case Cancelled
}
//#-end-hidden-code

func receiveTouch(t: TouchMessageType, x: CGFloat, y: CGFloat) {
//#-editable-code
  switch (t) {
  case .Began:
    sendMidi(byte0: 0x90 + 0, byte1: 60, byte2: 64)
    break
  case .Moved:
    sendMidi(byte0: 0x90 + 0, byte1: 60, byte2: 64)
    break
  case .Cancelled:
    sendMidi(byte0: 0x80 + 0, byte1: 60, byte2: 0)
    break
  case .Ended:
    sendMidi(byte0: 0x80 + 0, byte1: 60, byte2: 0)
    break
  default:
    break
  }
//#-end-editable-code
}

//#-hidden-code
func receiveMessage(_ message: PlaygroundValue) {
  print("received message: \(message)")
  if case let .array(arr) = message {
    if case let .integer(t) = arr[0] {
      if case let .floatingPoint(x) = arr[1] {
        if case let .floatingPoint(y) = arr[2] {
          print("received \(t), \(x), \(y)")
          receiveTouch(t: TouchMessageType.init(rawValue: t)!, x: CGFloat(x), y: CGFloat(y))
        }
      }
    }
  }
}

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

class SendTouchViewController: UIViewController {
  
  override func viewDidLoad() {
    self.view.backgroundColor = UIColor.gray()
    self.view.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("touchesBegan")
    self.view.backgroundColor = UIColor.red()
    if let touch = touches.first {
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Began, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("touchesEnded")
    self.view.backgroundColor = UIColor.gray()
    if let touch = touches.first {
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Ended, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.backgroundColor = UIColor.blue()
    if let touch = touches.first {
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Moved, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.backgroundColor = UIColor.green()
    if let touch = touches.first {
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Cancelled, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  func sendMessage(t:TouchMessageType, x:CGFloat, y:CGFloat) {
    receiveMessage(PlaygroundValue.array([
      PlaygroundValue.integer(t.rawValue),
      PlaygroundValue.floatingPoint(Double(x)),
      PlaygroundValue.floatingPoint(Double(y))
      ]))
  }
}

page.liveView = SendTouchViewController()
//#-end-hidden-code
