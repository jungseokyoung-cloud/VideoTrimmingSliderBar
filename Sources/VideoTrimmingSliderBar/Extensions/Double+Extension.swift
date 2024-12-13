//
//  Double+Extension.swift
//  VideoTrimmingSliderBar
//
//  Created by jung on 12/14/24.
//

import Foundation

extension Double {
  func bound(lower: Double, upper: Double) -> Double {
    return min(max(self, lower), upper)
  }
}
