import { TextStyle } from './AISkinTheme'
import { AISkinButton, AISkinTag } from './AISkinPrimitives'
import { AISkinButtonLayout, AISkinButtonVariant, AISkinSpacing, AISkinTextRole, AISkinTone } from './Foundation/AISkinTokens'
/** The text matches iOS; the explicit badge and explanation retain Huawei's review label. */
@Component
export struct AISkinAIGeneratedNotice {
  onExplanation?: () => void
  build() {
    Row({ space: AISkinSpacing.xSmall }) {
      AISkinTag({ title: 'AI生成', tone: AISkinTone.Accent })
      Text('本内容由 AI 生成，仅供参考。').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary)).layoutWeight(1)
      if (this.onExplanation) { AISkinButton({ title: '说明', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: this.onExplanation }) }
    }.width('100%')
  }
}
