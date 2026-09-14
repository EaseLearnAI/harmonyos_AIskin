import { AISkinColor, PrimaryButtonStyle } from '../../design/AISkinTheme'
@Component
export struct AddProduct {
  @Prop showUploadModal: boolean = false
  onOpenUploadModal?: () => void
  onEnableConflictMode?: () => void
  build() {
    Column({ space: 16 }) {
      Text('收好每一瓶，弄清怎么用。').fontSize(14).fontColor(AISkinColor.secondary).width('100%')
      Row({ space: 12 }) {
        Button('＋ 添加产品').layoutWeight(1).attributeModifier(new PrimaryButtonStyle()).onClick(() => this.onOpenUploadModal?.())
        Button('冲突检测').layoutWeight(1).height(48).fontColor(AISkinColor.accent)
          .backgroundColor(AISkinColor.surface).borderRadius(16).onClick(() => this.onEnableConflictMode?.())
      }.width('100%')
    }.width('100%')
  }
}
