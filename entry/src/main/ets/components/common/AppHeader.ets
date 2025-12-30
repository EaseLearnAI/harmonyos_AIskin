@Component
export struct AppHeader {
  @Prop title: string = '析肤护肤助手'
  @Prop icon: string = 'paw'
  @Prop rightIcon: string = ''
  @Prop showBackButton: boolean = false
  @Prop bgColor: string = 'bg-sakura'
  onBack?: () => void

  build() {
    Column() {
      // Header Content
      Row() {
        if (this.showBackButton) {
          Button() {
            Text('←')
              .fontSize(18)
              .fontColor(Color.White)
          }
          .type(ButtonType.Circle)
          .width(32)
          .height(32)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .onClick(() => {
            if (this.onBack) {
              this.onBack()
            }
          })
        } else {
          Blank()
            .width(32)
        }

        Blank()

        // Title Container - Centered
        Row() {
          if (this.icon) {
            Text('🐾')
              .fontSize(16)
              .margin({ right: 6 })
          }
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Blank()

        if (this.rightIcon) {
          Button() {
            Text(this.getRightIconText())
              .fontSize(16)
              .fontColor(Color.White)
          }
          .type(ButtonType.Circle)
          .width(32)
          .height(32)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
        } else {
          Blank()
            .width(32)
        }
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .backgroundColor('#F8BBD0')
    .padding({ top: 8, bottom: 8 })
  }

  getRightIconText(): string {
    switch (this.rightIcon) {
      case 'settings':
        return '⚙️'
      default:
        return ''
    }
  }
}

