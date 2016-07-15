let serviceUUIDString = "03B80E5A-EDE8-4B33-A751-6CE34EC4C700"
let characteristicUUIDString = "7772E5DB-3868-4112-A1A9-F2669D106BF3"
let notifyReadValueCallback = { (valueString: String) -> () in
  print("received: \(valueString)")
}

//#-hidden-code
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

public class BLECentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  var connectedPeripheral:CBPeripheral!
  var centralManager:CBCentralManager!
  
  let serviceUUID = CBUUID(string: serviceUUIDString)
  let characteristicUUID = CBUUID(string: characteristicUUIDString)
  
  override init() {
    super.init()
    centralManager = CBCentralManager(delegate:self, queue:nil, options: nil)
  }
  
  func startScan() {
    centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    print("Started scanning")
  }
  
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state{
    case .poweredOn:
      startScan()
      break
    default:
      break
    }
  }
  
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
    print("Discovered: \(peripheral.name!)")
    self.connectedPeripheral = peripheral
    peripheral.delegate = self
    centralManager.connect(peripheral, options: nil)
  }
  
  public func centralManager(_ central: CBCentralManager, didConnect
    peripheral: CBPeripheral) {
    print("Connected to: \(peripheral.name!)")
    peripheral.discoverServices([serviceUUID])
  }
  
  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: NSError?) {
    print("Disconnected from: \(peripheral.name!)")
    startScan()
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error:
    NSError?) {
    guard let services = peripheral.services else {
      return
    }
    for service in services {
      if service.uuid.uuidString == serviceUUID.uuidString {
        peripheral.discoverCharacteristics([characteristicUUID], for: (service as CBService))
      }
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral,
                         didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
    guard let characteristics = service.characteristics else {
      return
    }
    for characteristic in characteristics {
      if characteristic.uuid.uuidString == characteristicUUID.uuidString {
        peripheral.setNotifyValue(true, for: characteristic)
      }
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor
    characteristic: CBCharacteristic, error: NSError?) {
    guard let data = characteristic.value else {
      return
    }
    if let valueString = String(data: data, encoding: String.Encoding.utf8) {
      notifyReadValueCallback(valueString)
    }
  }
}

var bleCentral = BLECentral()
//#-end-hidden-code

