//
//  SliderThumb.swift
//  VideoTrimmingSliderBar
//
//  Created by jung on 12/14/24.
//

import UIKit

final class SliderThumb: UIView {
  // MARK: - UI Components
  private let imageView = UIImageView()
  
  // MARK: - Properties
  var isHightlighted: Bool = false {
    didSet { setupUI(for: isHightlighted) }
  }
  
  var thumbTintColor: UIColor {
    didSet { setupUI(for: isHightlighted) }
  }
  
  var hightlightedColor: UIColor {
    didSet { setupUI(for: isHightlighted) }
  }
  
  // MARK: - Initializers
  init(tintColor: UIColor, hightlightedColor: UIColor) {
    self.thumbTintColor = tintColor
    self.hightlightedColor = hightlightedColor

    super.init(frame: .zero)
    isUserInteractionEnabled = false
    setupUI()
  }
  
  convenience init(tintColor: UIColor) {
    self.init(tintColor: tintColor, hightlightedColor: tintColor)
  }
  
  
  convenience init() {
    self.init(tintColor: .clear, hightlightedColor: .clear)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.layer.cornerRadius = self.bounds.width / 2
    imageView.frame = .init(
      x: 4,
      y: 10,
      width: bounds.width - 8,
      height: bounds.height - 20
    )
  }
}

// MARK: - UI Methods
private extension SliderThumb {
  func setupUI() {
    self.backgroundColor = thumbTintColor
    setViewHierarchy()
    setImageViewAttributes()
  }
  
  func setViewHierarchy() {
    addSubview(imageView)
  }
  
  func setImageViewAttributes() {
    imageView.contentMode = .scaleToFill
  }
  
  func setupUI(for isHighlighted: Bool) {
    self.backgroundColor = isHighlighted ? self.hightlightedColor : self.thumbTintColor
  }
}

// MARK: - Internal Methods
extension SliderThumb {
  func contain(point: CGPoint) -> Bool {
    return frame.contains(point)
  }
  
  func setImage(_ image: UIImage?) {
    self.imageView.image = image
  }
}
