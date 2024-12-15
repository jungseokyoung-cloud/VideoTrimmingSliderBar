//
//  AvAssetGenerator+Extension.swift
//  SliderDemo
//
//  Created by jung on 11/28/24.
//

import AVFoundation
import UIKit

@available(iOS 4.0, *)
extension AVAssetImageGenerator {
  func generateUIImage(at time: CMTime) async throws -> UIImage {
    if #available(iOS 16.0, *) {
      guard let cgImage = try? await image(at: time).image else { return UIImage() }
      
      
      return UIImage(cgImage: cgImage)
    } else {
      guard let cgImage = try? copyCGImage(at: time, actualTime: nil) else { return UIImage() }
      
      return UIImage(cgImage: cgImage)
    }
  }
}
