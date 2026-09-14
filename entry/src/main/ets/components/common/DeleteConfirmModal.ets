import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct DeleteConfirmModal {
  @Prop show: boolean = false
  @Prop productName: string = '产品'
  onCancel?: () => void
  onConfirm?: () => void

  build() {
    if (this.show) {
      Stack({ alignContent: Alignment.Center }) {
        // Backdrop
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(AISkinColor.scrim)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })

        // Modal Content
        Column() {
          // Header
          Row() {
            Column() {
              Text('⚠️')
                .fontSize(32)
                .fontColor(AISkinColor.warning)
            }
            .width(48)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 16 })

            Text('确认删除')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AISkinColor.text)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 16 })

          // Message
          Text(`确定要删除"${this.productName}"的分析结果吗？此操作无法撤销。`)
            .fontSize(15)
            .fontColor(AISkinColor.secondary)
            .textAlign(TextAlign.Center)
            .lineHeight(22)
            .margin({ bottom: 24 })
            .padding({ left: 16, right: 16 })

          // Action Buttons
          Row() {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(AISkinColor.surface)
              .fontColor(AISkinColor.text)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .border({
                width: 1,
                color: AISkinColor.divider,
                style: BorderStyle.Solid
              })
              .borderRadius(8)
              .margin({ right: 8 })
              .onClick(() => {
                console.log('===== ❌ 取消删除 =====')
                if (this.onCancel) {
                  this.onCancel()
                }
              })

            Button('确认删除')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(AISkinColor.danger)
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(8)
              .onClick(() => {
                console.log('===== ✅ 确认删除 =====')
                if (this.onConfirm) {
                  this.onConfirm()
                }
              })
          }
          .width('100%')
        }
        .width('90%')
        .constraintSize({ maxWidth: 400 })
        .padding(24)
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

