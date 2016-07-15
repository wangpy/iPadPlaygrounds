// code from WWDC 2016 session https://developer.apple.com/wwdc16/507

import Foundation
import AudioToolbox
import AVFoundation

class SquareWaveGenerator {
  let sampleRate: Double
  let frequency:Double
  let amplitude:Float
  
  var counter: Double = 0.0
  
  init(sampleRate:Double, frequency: Double, amplitude: Float) {
    self.sampleRate = sampleRate
    self.frequency = frequency
    self.amplitude = amplitude
  }
  
  func render(buffer: AudioBuffer) {
    let nframes = Int(buffer.mDataByteSize) / sizeof(Float)
    var ptr = UnsafeMutablePointer<Float>(buffer.mData)
    
    var j = self.counter
    let cycleLength = self.sampleRate / self.frequency
    let halfCycleLength = cycleLength / 2
    
    let plusAmp = self.amplitude
    let minusAmp = -self.amplitude
    
    for _ in 0 ..< nframes {
      let amp = (j < halfCycleLength) ? plusAmp : minusAmp
      ptr?.pointee = amp
      ptr = ptr?.successor()
      j += 1.0
      
      if j > cycleLength {
        j -= cycleLength
      }
      
    }
    
    self.counter = j;
  }
}

func main() {
  // Create an AudioComponentDescription for the input/output unit we want to use.
  #if os(iOS)
    let kOutputUnitSubType = kAudioUnitSubType_RemoteIO
  #else
    let kOutputUnitSubType = kAudioUnitSubType_HALOutput
  #endif
  
  let ioUnitDesc = AudioComponentDescription(
    componentType: kAudioUnitType_Output,
    componentSubType: kOutputUnitSubType,
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
  
  // Create square wave generators.
  let generatorLeft = SquareWaveGenerator(sampleRate: renderFormat.sampleRate, frequency: 440.0, amplitude: 0.1)
  let generatorRight = SquareWaveGenerator(sampleRate: renderFormat.sampleRate, frequency: 660.0, amplitude: 0.1)
  
  // Install a block which will be called to render
  ioUnit.outputProvider = { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, timestamp: UnsafePointer<AudioTimeStamp>, frameCount: AUAudioFrameCount, busIndex: Int, rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
    
    let bufferList = UnsafeMutableAudioBufferListPointer(rawBufferList)
    if bufferList.count > 0 {
      generatorLeft.render(buffer: bufferList[0])
      if bufferList.count > 1 {
        generatorRight.render(buffer: bufferList[1])
      }
    }
    
    return noErr
  }
  
  // Allocate render resources, then start the audio hardware
  try! ioUnit.allocateRenderResources()
  
  try! ioUnit.startHardware()
  print("audio started")
  
  sleep(3)
  ioUnit.stopHardware()
  print ("audio stopped")
}

main()
