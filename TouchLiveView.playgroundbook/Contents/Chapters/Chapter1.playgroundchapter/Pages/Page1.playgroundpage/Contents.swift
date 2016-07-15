import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

class MyClassThatListens: PlaygroundRemoteLiveViewProxyDelegate {
  func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
                           received message: PlaygroundValue) {
    print("received message")
    if case let .array(arr) = message {
      if case let .integer(t) = arr[0] {
        if case let .floatingPoint(x) = arr[1] {
          if case let .floatingPoint(y) = arr[2] {
            print("received \(t), \(x), \(y)")
          }
        }
      }
    }
  }
  func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    print("remoteLiveViewProxyConnectionClosed")
    // Kill user process if LiveView process closed.
    PlaygroundPage.current.finishExecution()
  }
}

let listener = MyClassThatListens()
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.delegate = listener

//page.needsIndefiniteExecution = true // putting this line here will crash

