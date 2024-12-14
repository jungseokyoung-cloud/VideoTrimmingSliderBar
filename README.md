# VideoTrimmingSliderBar
<img src = "https://github.com/user-attachments/assets/fe589748-a54d-4f08-a91d-559068817dc7" witdh = 200>

## Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Description](#description)

## Requirements 
- iOS 16.0+

## Installation 
- Swift Package Manager
```swift 
dependencies: [
    .package(url: "https://github.com/jungseokyoung-cloud/VideoTrimmingSliderBar.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage 
우선, 위와 같이 `VideoTrimmingSliderBar`를 선언해줍니다. 
```swift 
let sliderBar = VideoTrimmingSliderBar() 
```

이후, 원하는 영상의 Content를 다음 메서드를 통해 주입해줍니다. 
```swift 
func configure(
  with asset: AVAsset,
  lowerValue: Double,
  upperValue: Double,
  seekValue: Double,
  frameCount: Int
)
```

아래의 메서드를 통해 주입하는 경우, `lowerValue`는 비디오의 시작시간으로, `upperValue`는 비디오의 종료시간으로 주입됩니다. 
```swift
func configure(with asset: AVAsset, frameCount: Int = 20)
```

UIControl이기에, send-Action을 통해 이벤트를 받아보는 것을 제공합니다. 
```swift 
sliderBar.addAction(..., for: .valueChanged)
```

또한, delegate를 통해 어떤 값이 변했는지 더욱 구체적으로 받아볼 수 있습니다. 
```swift 
@MainActor
public protocol VideoTrimmingSliderBarDelegate: AnyObject {
  func lowerValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double)
  func upperValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double)
  func seekValueDidChanged(_ sliderBar: VideoTrimmingSliderBar, value: Double)
}
```

## Description
### GPU기반 Image Concat
성능상의 최적화를 위해 imageFrame을 생성할 때, 해당 시간대의 이미지들을 가져와 가로로 이어붙여 하나의 이미지로 만듭니다. 
이때, 하나의 이미지로 만들때, 성능상의 이점을 위해 CPU가 아닌 GPU에서 랜더링하도록 구현했습니다. 

**[영상길이 4분 4초, frameCount = 500]**
|구분|시간|
|------|---|
|CPU|0.36|
|GPU|0.09|

### GPU기반 View 렌더링 
![Group 3](https://github.com/user-attachments/assets/f7796664-e4c4-4bbe-baf1-95a8d7646b86)


좌우 SliderThumb에 따라, 늘어나도 줄어드는 View를 UIView가 아닌 Core Animation을 활용하여 구현했습니다. 
UIView보다 가벼운 Core Graphics와 Core Animation을 두고 고려를 했으나, 자주 랜더링이 일어나는 작업이기에 GPU기반의 Core Animation을 선택했습니다.
