//
//  UIImage+Extension.swift
//  VideoTrimmingSliderBar
//
//  Created by jung on 12/14/24.
//

import UIKit

extension UIImage {
  /// 지정한 size로 image를 resize한 `UIImage`객체를 리턴합니다.
  /// - Parameters:
  ///   - size: resize할 size
  func resize(_ size: CGSize) -> UIImage {
    let image = UIGraphicsImageRenderer(size: size).image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
    
    return image.withRenderingMode(renderingMode)
  }
  
  func color(_ color: UIColor) -> UIImage {
    return self.withTintColor(color, renderingMode: .alwaysOriginal)
  }
}

extension Array where Element: UIImage {
  func concatImagesHorizontaly() -> UIImage {
    let maxWidth = self.compactMap { $0.size.width }.max()
    let maxHeight = self.compactMap { $0.size.height }.max()
    
    let maxSize = CGSize(width: maxWidth ?? 0, height: maxHeight ?? 0)
    let totalSize = CGSize(width: maxSize.width * (CGFloat)(self.count), height: maxSize.height)
    print(totalSize)
    return UIGraphicsImageRenderer(size: totalSize).image { context in
      for (index, image) in self.enumerated() {
        
        let rect = CGRect(
          x: maxSize.width * CGFloat(index),
          y: 0,
          width: maxSize.width,
          height: maxSize.height
        )

        image.draw(in: rect)
      }
    }
  }
  
  func concatImagesHorizontallyGPU() -> UIImage {
    let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])

    let ciImages = self.compactMap { CIImage(image: $0) }

    guard !ciImages.isEmpty else { return UIImage() }

    let maxWidth = ciImages.compactMap { $0.extent.width }.max() ?? 0
    let maxHeight = ciImages.compactMap { $0.extent.height }.max() ?? 0
    
    let maxSize = CGSize(width: maxWidth, height: maxHeight)
    let totalSize = CGSize(
      width: maxSize.width * (CGFloat)(self.count),
      height: maxSize.height
    )
    let finalRect = CGRect(origin: .zero, size: totalSize)
    
    let outputImage = ciImages.enumerated().reduce(CIImage()) { result,  element in
      let (index, image) = element
      let xOffset = maxWidth * CGFloat(index)
      
      let translatedImage = image.transformed(by: CGAffineTransform(
          translationX: xOffset,
          y: (maxHeight - image.extent.height) / 2
        )
      )
      return result.composited(over: translatedImage)
    }
    
    // 결과를 UIImage로 변환
    guard let cgImage = context.createCGImage(outputImage, from: finalRect) else { return UIImage() }
    return UIImage(cgImage: cgImage)
  }
}
