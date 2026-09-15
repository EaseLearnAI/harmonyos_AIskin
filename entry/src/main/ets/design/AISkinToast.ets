import { AISkinColor, TextStyle } from './AISkinTheme'
import { AISkinIcon } from './AISkinIcon'
import { AISkinIconButton } from './AISkinPrimitives'
import { AISkinLayout, AISkinRadius, AISkinSpacing, AISkinTextRole } from './Foundation/AISkinTokens'
import { AISkinToastTokens } from './Foundation/AISkinToastTokens'

@Component
export struct AISkinToast {
  @Prop message: string = ''
  @Prop iconName: string = 'checkCircle'
  @Prop dismissAccessibilityLabel: string = '关闭提示'
  onDismiss?: () => void
  build() {
    Row({ space: AISkinSpacing.xSmall }) {
      AISkinIcon({ name: this.iconName, selected: true, iconSize: AISkinLayout.iconSize }).accessibilityLevel('no')
      Text(this.message).attributeModifier(new TextStyle(AISkinTextRole.Callout)).layoutWeight(1)
      if (this.onDismiss) { AISkinIconButton({ name: 'close', label: this.dismissAccessibilityLabel, onAction: this.onDismiss }) }
    }.width('100%').constraintSize({ minHeight: AISkinToastTokens.minimumHeight }).padding({ left: AISkinSpacing.medium, right: AISkinSpacing.medium })
      .backgroundColor(AISkinColor.elevated).borderRadius(AISkinRadius.control)
      .border({ width: AISkinLayout.hairline, color: AISkinColor.border })
      .shadow({ radius: AISkinToastTokens.shadowRadius, color: AISkinColor.floatingShadow, offsetY: AISkinToastTokens.shadowOffsetY })
  }
}
