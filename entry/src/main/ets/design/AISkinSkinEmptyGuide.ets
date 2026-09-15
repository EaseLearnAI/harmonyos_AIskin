import { AISkinColor } from './AISkinTheme'
import { AISkinButton } from './AISkinPrimitives'
import { AISkinSpacing, AISkinButtonVariant } from './Foundation/AISkinTokens'
import { AISkinSkinTokens as T } from './Foundation/AISkinSkinTokens'
@Component
export struct AISkinSkinEmptyGuide {
  onCapture?: () => void
  onLibrary?: () => void
  build() {
    Column() {
      Blank().constraintSize({ minHeight: AISkinSpacing.large })
      Column({ space: T.emptyCopyGap }) {
        Column({ space: AISkinSpacing.small }) {
          Text('一张照片，').fontSize(T.emptyTitle).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
          Text('了解你的肌肤。').fontSize(T.emptyTitle).fontFamily('serif').fontColor(AISkinColor.accent)
        }.alignItems(HorizontalAlign.Start)
        Text('拍摄清晰的正面照片，\n查看肤况分析与护肤建议。').fontSize(T.body).fontColor(AISkinColor.secondary)
      }.width('100%').alignItems(HorizontalAlign.Start).padding({ bottom: T.emptyBottomSpace })
      Blank().constraintSize({ minHeight: AISkinSpacing.large })
      AISkinButton({ title: '开始肌肤检测', onAction: this.onCapture })
      AISkinButton({ title: '从相册选择', variant: AISkinButtonVariant.Plain, onAction: this.onLibrary })
      Text('自然光　·　无遮挡　·　无美颜').fontSize(T.small).fontColor(AISkinColor.secondary).padding({ top: AISkinSpacing.medium })
    }.width('100%').constraintSize({ minHeight: T.emptyMinimumHeight }).padding({ left: AISkinSpacing.xSmall,right: AISkinSpacing.xSmall,bottom: AISkinSpacing.xLarge })
  }
}
