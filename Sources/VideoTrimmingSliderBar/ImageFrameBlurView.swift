//
//  ImageFrameBlurView.swift
//  VideoTrimmingSliderBar
//
//  Created by jung on 12/14/24.
//

import UIKit

final class ImageFrameBlurView: UIView {
  var selectedRect: CGRect = .zero {
    didSet { setNeedsDisplay() }
  }
  
  init() {
    super.init(frame: .zero)
    self.backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext()  else { return }
    
    context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
    context.fill(self.bounds)
    
    context.setBlendMode(.clear)
    context.fill(selectedRect)
    
    context.setBlendMode(.normal)
  }
}
