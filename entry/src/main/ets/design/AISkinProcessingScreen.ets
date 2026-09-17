import { AISkinBackground } from './AISkinTheme'
import { AISkinButton, AISkinHeader } from './AISkinPrimitives'
import { AISkinButtonVariant, AISkinSpacing } from './Foundation/AISkinTokens'
import { ProcessingPanel } from '../components/common/ProcessingPanel'
@Component
export struct AISkinProcessingScreen {
  @Prop title: string = '正在分析'
  @Prop message: string = '稍等一下，细节也想照顾到'
  onCancel?: () => void
  build() {
    Stack() {
      AISkinBackground()
      Column() {
        AISkinHeader({ title: this.title })
        Column() { ProcessingPanel({ title: this.title, message: this.message }) }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        if (this.onCancel) { AISkinButton({ title: '取消', variant: AISkinButtonVariant.Secondary, onAction: this.onCancel }).margin({ bottom: AISkinSpacing.xLarge }) }
      }.width('100%').height('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge })
    }.width('100%').height('100%')
  }
}
