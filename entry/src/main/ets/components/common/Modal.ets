@Component
export struct Modal {
  @Prop show: boolean = false
  @Prop title: string = ''
  @Prop showCloseButton: boolean = true
  onClose?: () => void

  build() {
    if (this.show) {
      Stack({ alignContent: Alignment.Center }) {
        // Backdrop
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            if (this.onClose) {
              this.onClose()
            }
          })

        // Modal Content
        Column() {
          // Header
          if (this.title || this.showCloseButton) {
            Row() {
              if (this.title) {
                Text(this.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
              } else {
                Blank()
                  .layoutWeight(1)
              }

              if (this.showCloseButton) {
                Button() {
                  Text('✕')
                    .fontSize(18)
                    .fontColor('#666666')
                }
                .type(ButtonType.Circle)
                .width(32)
                .height(32)
                .backgroundColor('#f1f1f1')
                .onClick(() => {
                  if (this.onClose) {
                    this.onClose()
                  }
                })
              } else {
                Blank()
                  .width(32)
                  .height(32)
              }
            }
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 24, right: 24 })
          }

        }
        .width('90%')
        .constraintSize({ maxWidth: 400, maxHeight: '90%' })
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.15)',
          offsetX: 0,
          offsetY: 10
        })
        .onClick(() => {
          // Prevent backdrop click from closing when clicking modal content
        })
      }
      .width('100%')
      .height('100%')
      .zIndex(10000)
    }
  }
}

