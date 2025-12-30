@Component
export struct SkinDetectionWelcome {
  onTakePhoto?: () => void
  onSelectPhoto?: () => void

  build() {
    Column() {
      // Welcome Message
      Column() {
        Text('让我来看看你的肌肤状态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E1BEE7')
          .margin({ bottom: 8 })

        Text('AI智能分析，专业护肤建议')
          .fontSize(12)
          .fontColor('#6B7280')
      }
      .width('100%')
      .margin({ bottom: 24 })
      .alignItems(HorizontalAlign.Center)

      // Detection Options
      Row() {
        // Camera Button
        Column() {
          Column() {
            Text('📷')
              .fontSize(32)
          }
          .width(60)
          .height(60)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 12 })
          .shadow({
            radius: 4,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 2
          })

          Text('拍照检测')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .margin({ bottom: 4 })

          Text('实时拍摄分析')
            .fontSize(12)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        .height(160)
        .backgroundColor('#FFF9FB')
        .borderRadius(16)
        .border({
          width: 1,
          color: 'rgba(255, 236, 242, 0.5)',
          style: BorderStyle.Solid
        })
        .padding(24)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          // 点击拍照按钮时，也唤起相册选择（与相册按钮逻辑一致）
          if (this.onSelectPhoto) {
            this.onSelectPhoto()
          }
        })
        .margin({ right: 12 })

        // Gallery Button
        Column() {
          Column() {
            Text('🖼️')
              .fontSize(32)
          }
          .width(60)
          .height(60)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 12 })
          .shadow({
            radius: 4,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 2
          })

          Text('从相册选择')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .margin({ bottom: 4 })

          Text('选择已有照片')
            .fontSize(12)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        .height(160)
        .backgroundColor('#E8F5E9')
        .borderRadius(16)
        .border({
          width: 1,
          color: 'rgba(209, 250, 229, 0.5)',
          style: BorderStyle.Solid
        })
        .padding(24)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          if (this.onSelectPhoto) {
            this.onSelectPhoto()
          }
        })
      }
      .width('100%')
      .margin({ bottom: 24 })

      // Feature Highlights
      Row() {
        this.FeatureItem('AI智能识别', '#4ADE80')
        this.FeatureItem('专业分析', '#38BDF8')
        this.FeatureItem('个性建议', '#A855F7')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 16 })
      .border({
        width: { top: 1 },
        color: '#F3F4F6',
        style: BorderStyle.Solid
      })
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .margin({ bottom: 16 })
  }

  @Builder
  FeatureItem(text: string, color: string) {
    Row() {
      Column()
        .width(8)
        .height(8)
        .backgroundColor(color)
        .borderRadius(4)
        .margin({ right: 8 })

      Text(text)
        .fontSize(12)
        .fontColor('#6B7280')
    }
    .alignItems(VerticalAlign.Center)
  }
}






