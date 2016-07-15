import PlaygroundSupport
import UIKit

public class SendTouchViewController: UIViewController, PlaygroundLiveViewMessageHandler {
  public override func viewDidLoad() {
    self.view.backgroundColor = UIColor.gray()
    self.view.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.view.backgroundColor = UIColor.red()
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Began, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.view.backgroundColor = UIColor.gray()
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Ended, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.view.backgroundColor = UIColor.blue()
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Moved, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.view.backgroundColor = UIColor.green()
      let touchLocation = touch.location(in: self.view)
      sendMessage(t: TouchMessageType.Cancelled, x: touchLocation.x, y: touchLocation.y)
    }
  }
  
  func sendMessage(t:TouchMessageType, x:CGFloat, y:CGFloat) {
    send(PlaygroundValue.array([
      PlaygroundValue.integer(t.rawValue),
      PlaygroundValue.floatingPoint(Double(x)),
      PlaygroundValue.floatingPoint(Double(y))
      ]))
  }

  public func liveViewMessageConnectionOpened() {
    // We don't need to do anything in particular when the connection opens.
  }
  
  public func liveViewMessageConnectionClosed() {
    // We don't need to do anything in particular when the connection closes.
  }
}
