//
//  VideoTrimmingSliderBar.swift
//  VideoTrimmingSliderBar
//
//  Created by jung on 12/14/24.
//

import UIKit
import SnapKit
import AVFoundation

@available(iOS 16.0.0, *)
@MainActor
public protocol VideoTrimmingSliderBarDelegate: AnyObject {
  func lowerValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double)
  func upperValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double)
  func seekValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double)
}

@available(iOS 16.0.0, *)
public final class VideoTrimmingSliderBar: UIControl {
  enum Constants {
    static let thumbWidth: CGFloat = 16
    static let imageFramsPadding: CGFloat = 5
    static let seekThumbWidth: CGFloat = 10
  }
  
  // MARK: - UI Components
  private let imageFrameView = UIImageView()
  private let imageFrameBlurView = ImageFrameBlurView()
  private let lowerThumb = SliderThumb(tintColor: .systemYellow)
  private let upperThumb = SliderThumb(tintColor: .systemYellow)
  private let seekThumb = SliderThumb(tintColor: .white, hightlightedColor: .systemGray)
  private let topLayer = CALayer()
  private let bottomLayer = CALayer()
  private weak var currentHighlightedThumb: SliderThumb?
  
  // MARK: - Properties
  public weak var delegate: VideoTrimmingSliderBarDelegate?
  
  private var previousLocation: CGPoint = .zero
  private var minimumValue: Double = 0
  private var maximumValue: Double = 100
  
  private var totalLength: Double {
    let total = bounds.width - Constants.thumbWidth
    return total < 0 ? 0 : total
  }
  
  /// 현재 lowerThumb의 값(초 단위)
  public private(set) var lowerValue: Double = 0.0 {
    didSet {
      updateThumbFrame(lowerThumb)
      updateTopAndBottomLayerFrame()
      updateImageBlurView()
      delegate?.lowerValueDidChanged(self, value: lowerValue)
    }
  }
  
  /// 현재 upperThumb의 값(초 단위)
  public private(set) var upperValue: Double = 100 {
    didSet {
      updateThumbFrame(upperThumb)
      updateTopAndBottomLayerFrame()
      updateImageBlurView()
      delegate?.upperValueDidChanged(self, value: upperValue)
    }
  }
  
  public private(set) var seekValue: Double = 0 {
    didSet {
      updateSeekThumbFrame()
      delegate?.seekValueDidChanged(self, value: seekValue)
    }
  }
  
  private var gapBetweenThumbs: Double {
    let sliderProportion =  (maximumValue - minimumValue) / Double(totalLength)
    
    return Constants.thumbWidth * sliderProportion * 3
  }
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UIControl
  public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)
    defer { previousLocation = location }
    
    if seekThumb.contain(point: location) {
      seekThumb.isHightlighted = true
      currentHighlightedThumb = seekThumb
    } else if lowerThumb.contain(point: location) {
      lowerThumb.isHightlighted = true
      currentHighlightedThumb = lowerThumb
    } else if upperThumb.contain(point: location) {
      upperThumb.isHightlighted = true
      currentHighlightedThumb = upperThumb
    }
    
    return lowerThumb.isHightlighted || upperThumb.isHightlighted || seekThumb.isHightlighted
  }
  
  public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)
    defer { previousLocation = location }
    
    guard let thumb = currentHighlightedThumb else { return false }
    
    // point -> 초로 환산
    let thumbDeltaValue = deltaValue(from: previousLocation, to: location)
    let seekThumbDeltaValue = deltaValue(from: previousLocation, to: location)
    
    if thumb === seekThumb {
      self.seekValue = updatedSeekValue(moved: seekThumbDeltaValue)
    } else if thumb === lowerThumb {
      self.lowerValue = updatedLowerValue(moved: thumbDeltaValue)
      self.seekValue = lowerValue
    } else if thumb === upperThumb {
      self.upperValue = updatedUpperValue(moved: thumbDeltaValue)
      self.seekValue = upperValue
    }
    
    sendActions(for: .valueChanged)
    return true
  }
  
  public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    lowerThumb.isHightlighted = false
    upperThumb.isHightlighted = false
    seekThumb.isHightlighted = false
    currentHighlightedThumb = nil
  }
  
  // MARK: - LayoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    updateThumbsFrame()
  }
}

// MARK: - UI Methods
@available(iOS 16.0.0, *)
private extension VideoTrimmingSliderBar {
  func setupUI() {
    self.backgroundColor = .clear
    topLayer.backgroundColor = UIColor.systemYellow.cgColor
    bottomLayer.backgroundColor = UIColor.systemYellow.cgColor
    
    setViewHierarchy()
    setConstraints()
    setLowerThumbAttributes()
    setUpperThumbAttributes()
    setSeekThumbAttributes()
    
    updateThumbsFrame()
  }
  
  func setViewHierarchy() {
    layer.addSublayer(topLayer)
    layer.addSublayer(bottomLayer)
    addSubview(imageFrameView)
    addSubview(lowerThumb)
    addSubview(upperThumb)
    addSubview(seekThumb)
    imageFrameView.addSubview(imageFrameBlurView)
  }
  
  func setConstraints() {
    imageFrameView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Constants.thumbWidth)
      $0.top.bottom.equalToSuperview().inset(Constants.imageFramsPadding)
    }
    
    imageFrameBlurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func setLowerThumbAttributes() {
    let boldConfig = UIImage.SymbolConfiguration(weight: .heavy)
    
    let image = UIImage(systemName: "chevron.left")?
      .color(.systemGray)
      .withConfiguration(boldConfig)
    
    lowerThumb.setImage(image)
    lowerThumb.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
  }
  
  func setUpperThumbAttributes() {
    let boldConfig = UIImage.SymbolConfiguration(weight: .heavy)
    let image = UIImage(systemName: "chevron.right")?
      .color(.systemGray)
      .withConfiguration(boldConfig)
    
    upperThumb.setImage(image)
    upperThumb.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
  }
  
  func setSeekThumbAttributes() {
    seekThumb.layer.borderColor = UIColor.systemGray.cgColor
    seekThumb.layer.borderWidth = 1.0
  }
}

// MARK: - Private Methotds
@available(iOS 13.0.0, *)
private extension VideoTrimmingSliderBar {
  func updateThumbsFrame() {
    updateThumbFrame(lowerThumb)
    updateThumbFrame(upperThumb)
    updateSeekThumbFrame()
    updateTopAndBottomLayerFrame()
    updateImageBlurView()
  }
  
  func updateThumbFrame(_ thumb: SliderThumb) {
    let width = Constants.thumbWidth
    
    let leading = thumb === lowerThumb ? leadingForThumb(of: lowerValue) : leadingForThumb(of: upperValue)
    
    thumb.frame = CGRect(
      x: leading,
      y: 0,
      width: width,
      height: bounds.height
    )
  }
  
  func updateTopAndBottomLayerFrame() {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    topLayer.frame = CGRect(
      x: lowerThumb.center.x,
      y: 0,
      width: upperThumb.center.x - lowerThumb.center.x,
      height: 5
    )
    
    bottomLayer.frame = CGRect(
      x: lowerThumb.center.x,
      y: bounds.height - 5,
      width: upperThumb.center.x - lowerThumb.center.x,
      height: 5
    )
    CATransaction.commit()
  }
  
  func updateSeekThumbFrame() {
    let width = Constants.seekThumbWidth
    let leading = leadingForSeekThumb(of: seekValue)
    let xPosition = leading + lowerThumb.frame.maxX
    
    seekThumb.frame = CGRect(
      x: xPosition,
      y: 0,
      width: width,
      height: bounds.height
    )
  }
  
  func updateImageBlurView() {
    self.imageFrameBlurView.selectedRect = selectedRangeAtImageFrame()
  }
  
  func updatedLowerValue(moved delta: Double) -> Double {
    return (lowerValue + delta).bound(lower: minimumValue, upper: upperValue - gapBetweenThumbs)
  }
  
  func updatedUpperValue(moved delta: Double) -> Double {
    return (upperValue + delta).bound(lower: lowerValue + gapBetweenThumbs, upper: maximumValue)
  }
  
  func updatedSeekValue(moved delta: Double) -> Double {
    return (seekValue + delta).bound(lower: lowerValue, upper: upperValue)
  }
  
  func selectedRangeAtSlidarBar() -> CGRect {
    let startPoint = lowerThumb.frame.maxX
    let width = upperThumb.frame.minX - lowerThumb.frame.maxX
    
    return CGRect(
      x: startPoint,
      y: 0,
      width: width,
      height: bounds.height
    )
  }
  
  func selectedRangeAtImageFrame() -> CGRect {
    let selectedStartPoint = lowerThumb.frame.maxX - Constants.thumbWidth
    let width = upperThumb.frame.minX - lowerThumb.frame.maxX
    
    return CGRect(
      x: selectedStartPoint,
      y: 0,
      width: width,
      height: bounds.height
    )
  }
  
  func deltaValue(from previous: CGPoint, to current: CGPoint) -> Double {
    let deltaLocation = Double(current.x - previous.x)
    
    return (maximumValue - minimumValue) * deltaLocation / Double(totalLength)
  }
  
  func leadingForThumb(of value: Double) -> Double {
    return totalLength * value / maximumValue
  }
  
  func leadingForSeekThumb(of value: Double) -> Double {
    let range = upperValue - lowerValue
    guard range > 0 else { return 0 }
    let proportion = (value - lowerValue) / range
    return Double(upperThumb.frame.minX - lowerThumb.frame.maxX) * proportion
  }
}

// MARK: - ImageFrames
@available(iOS 16.0.0, *)
private extension VideoTrimmingSliderBar {
  /// `frameCount` 만큼의  frame Image들을 단일 frameImage로 리턴해줍니다.
  func frameImage(from video: AVAsset, frameCount: Int) async -> UIImage? {
    guard let cmTimeDuration = try? await video.load(.duration) else { return nil }
    let secondsDuration = Int(CMTimeGetSeconds(cmTimeDuration))
    let singleFrameDuration = Double(secondsDuration) / Double(frameCount)
    
    let frameCMTimes = (0..<frameCount).map { index -> CMTime in
      let startTime = singleFrameDuration * Double(index)
      
      return CMTimeMakeWithSeconds(startTime, preferredTimescale: Int32(secondsDuration))
    }
    
    let generator = avAssetImageGenerator(from: video)
    
    return await frameImage(from: generator, times: frameCMTimes)
  }
  
  func avAssetImageGenerator(from video: AVAsset) -> AVAssetImageGenerator {
    let generator = AVAssetImageGenerator(asset: video)
    generator.appliesPreferredTrackTransform = true
    generator.requestedTimeToleranceAfter = CMTime.zero
    generator.requestedTimeToleranceBefore = CMTime.zero
    
    return generator
  }
  
  func frameImage(from generator: AVAssetImageGenerator, times: [CMTime]) async -> UIImage? {
    var resultImages = Array(repeating: UIImage(), count: times.count)
    
    await withTaskGroup(of: Void.self) { group in
      for (index, time) in times.enumerated() {
        group.addTask {
          guard let image = try? await generator.generateUIImage(at: time) else { return }
          resultImages[index] = image
        }
      }
    }
    
    return resultImages.concatImagesHorizontallyGPU()
  }
}
