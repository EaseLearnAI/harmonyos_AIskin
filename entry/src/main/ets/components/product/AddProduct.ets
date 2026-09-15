import { TextStyle } from '../../design/AISkinTheme'
import { AISkinButton } from '../../design/AISkinPrimitives'
import { AISkinButtonVariant, AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone } from '../../design/Foundation/AISkinTokens'
@Component
export struct AddProduct {
  @Prop showUploadModal: boolean = false
  onOpenUploadModal?: (source?: string) => void
  onEnableConflictMode?: () => void
  build() {
    Column({ space: AISkinSpacing.small }) {
      Text('拍一张，就能分析').attributeModifier(new TextStyle(AISkinTextRole.EmptyTitle))
      Text('对准成分表，剩下交给 AI').attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary))
      Image($r('app.media.product_capture')).width(AISkinLayout.captureGuideDiameter).height(AISkinLayout.captureGuideDiameter).objectFit(ImageFit.Contain).margin({ top: AISkinSpacing.xLarge, bottom: AISkinSpacing.xLarge })
      AISkinButton({ title: '拍照分析', onAction: (): void => { this.onOpenUploadModal?.('camera') } })
      AISkinButton({ title: '从相册上传', variant: AISkinButtonVariant.Plain, onAction: (): void => { this.onOpenUploadModal?.('library') } })
      Row({ space: AISkinSpacing.xSmall }) {
        this.feature('AI 建议', '添加成分表照片，查看这件护肤品的使用建议。')
        this.feature('风险告知', '添加成分表照片，了解配方中需要留意的成分。')
        this.feature('冲突检测', '添加至少 2 件护肤品，再检查它们的成分搭配。')
      }.width('100%').margin({ top: AISkinSpacing.xLarge })
    }.width('100%').padding({ top: AISkinSpacing.large, bottom: AISkinSpacing.large })
  }
  @Builder
  feature(title: string, message: string) {
    AISkinButton({ title, variant: AISkinButtonVariant.Plain, onAction: () => { AlertDialog.show({ title, message, confirm: { value: '知道了', action: () => {} } }) } }).layoutWeight(1)
  }
}
