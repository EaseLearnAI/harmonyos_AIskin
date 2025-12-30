@Component
export struct AddProduct {
  @Prop showUploadModal: boolean = false
  onOpenUploadModal?: () => void
  onEnableConflictMode?: () => void

  build() {
    Column() {
      Column() {
        Row() {
          Text('➕')
            .fontSize(20)
            .margin({ right: 8 })
          Text('添加新产品到猫窝')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 16 })

        Grid() {
          GridItem() {
            this.OptionButton('📷', '添加产品', '猫眼扫描成分', () => {
              // 直接打开上传模态框，不触发相册选择
              if (this.onOpenUploadModal) {
                this.onOpenUploadModal()
              }
            })
          }

          GridItem() {
            this.OptionButton('⚠️', '产品混用检测', '确保混用安全', () => {
              if (this.onEnableConflictMode) {
                this.onEnableConflictMode()
              }
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        .height(120)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .margin({ bottom: 16 })
      .shadow({
        radius: 8,
        color: 'rgba(255, 182, 193, 0.15)',
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
  }

  @Builder
  OptionButton(icon: string, title: string, description: string, onClick: () => void) {
    Column() {
      Column() {
        Text(icon)
          .fontSize(24)
          .fontColor(Color.White)
      }
      .width(56)
      .height(56)
      .backgroundColor('#FF9A9E')
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 4 })

      Text(description)
        .fontSize(12)
        .fontColor('#757575')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#f9f9f9')
    .borderRadius(12)
    .onClick(onClick)
  }

}

