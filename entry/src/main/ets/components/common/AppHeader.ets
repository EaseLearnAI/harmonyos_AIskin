import { AISkinHeader, AISkinHeaderLayout } from '../../design/AISkinPrimitives'

// Business facade only: the shared AISkinHeader owns every visual decision.
@Component
export struct AppHeader {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop layout: AISkinHeaderLayout = AISkinHeaderLayout.Centered
  @Prop icon: string = ''
  @Prop rightIcon: string = ''
  @Prop rightLabel: string = ''
  @Prop rightAccessibilityLabel: string = ''
  @Prop showBackButton: boolean = false
  onBack?: () => void
  onProfile?: () => void
  onRight?: () => void
  rightAction?: () => void
  build() {
    AISkinHeader({ title: this.title, subtitle: this.subtitle, layout: this.layout,
      leftIcon: this.showBackButton ? 'back' : (this.onProfile ? 'profile' : ''),
      leftLabel: this.showBackButton ? '返回' : '我的',
      onLeft: () => { if (this.showBackButton) this.onBack?.(); else this.onProfile?.() },
      rightIcon: this.rightIcon, rightLabel: this.rightAccessibilityLabel || this.rightLabel,
      onRight: () => { if (this.rightAction) this.rightAction(); else this.onRight?.() } })
  }
}
