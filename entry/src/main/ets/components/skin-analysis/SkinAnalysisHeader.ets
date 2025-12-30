@Component
export struct SkinAnalysisHeader {
  onShowHistory?: () => void
  onBack?: () => void

  build() {
    Row() {
      // Back Button
      Button() {
        Text('←')
          .fontSize(18)
          .fontColor(Color.White)
      }
      .type(ButtonType.Circle)
      .width(36)
      .height(36)
      .backgroundColor('rgba(255, 255, 255, 0.2)')
      .onClick(() => {
        if (this.onBack) {
          this.onBack()
        }
      })

      Blank()

      // Title
      Row() {
        Text('🐾')
          .fontSize(18)
          .margin({ right: 8 })
        Text('肌肤检测')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Blank()

      // History Button
      Button() {
        Text('🕐')
          .fontSize(16)
          .fontColor(Color.White)
      }
      .type(ButtonType.Circle)
      .width(36)
      .height(36)
      .backgroundColor('rgba(255, 255, 255, 0.2)')
      .onClick(() => {
        if (this.onShowHistory) {
          this.onShowHistory()
        }
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F8BBD0')
  }
}






