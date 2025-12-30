@Component
export struct AuthHeader {
  @Prop title: string = '欢迎回来'
  @Prop subtitle: string = '开始你的护肤之旅'
  @Prop bgColor: string = 'bg-sakura'
  @Prop showBackButton: boolean = true
  onBack?: () => void

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // Main Content Column
      Column() {
        // Logo Container
        Column() {
          // Logo Circle
          Row() {
            Text('🐾')
              .fontSize(32)
              .fontColor('#F8BBD0')
          }
          .width(64)
          .height(64)
          .backgroundColor(Color.White)
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 12 })
          .shadow({
            radius: 10,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 4
          })

          // App Name
          Text('析服AI护肤助手')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ bottom: 16 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 16 })

        // Title and Subtitle
        Column() {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .margin({ bottom: 8 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.8)')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 40 })
      .alignItems(HorizontalAlign.Center)

      // Back Button - Positioned at top left
      if (this.showBackButton) {
        Button() {
          Text('←')
            .fontSize(18)
            .fontColor(Color.White)
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .backgroundColor('rgba(255, 255, 255, 0.2)')
        .margin({ left: 16, top: 24 })
        .onClick(() => {
          if (this.onBack) {
            this.onBack()
          }
        })
      }
    }
    .width('100%')
    .backgroundColor('#F8BBD0')
    .borderRadius({ bottomLeft: 30, bottomRight: 30 })
  }
}

