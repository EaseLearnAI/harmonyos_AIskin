import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
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
          .backgroundColor(AISkinColor.scrim)
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
                  .fontColor(AISkinColor.text)
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
                    .fontColor(AISkinColor.secondary)
                }
                .type(ButtonType.Circle)
                .width(32)
                .height(32)
                .backgroundColor(AISkinColor.muted)
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
        .attributeModifier(new CardStyle())
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

