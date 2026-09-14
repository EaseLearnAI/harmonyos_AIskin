import { AISkinColor } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'

@Component
export struct AppHeader {
  @Prop title: string = ''
  @Prop icon: string = ''
  @Prop rightIcon: string = ''
  @Prop showBackButton: boolean = false
  @Prop bgColor: ResourceColor = ''
  onBack?: () => void
  onProfile?: () => void
  build() {
    Row({ space: 12 }) {
      if (this.showBackButton) {
        Button() { AISkinIcon({ name: 'back' }) }
          .width(44).height(44).backgroundColor(AISkinColor.surface)
          .accessibilityText('返回').onClick(() => this.onBack?.())
      }
      if (!this.showBackButton) {
        Button() { AISkinIcon({ name: 'profile', iconSize: 20 }) }
          .width(44).height(44).backgroundColor(AISkinColor.surface)
          .accessibilityText('我的').onClick(() => this.onProfile?.())
      }
      Text(this.title).fontSize(20).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).layoutWeight(1).textAlign(TextAlign.Center)
      Blank().width(44)
    }.width('100%').padding({ left: 20, right: 20, top: 8, bottom: 8 })
  }
}
