import { AISkinColor } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'

@Component
export struct BottomNavigation {
  @Prop currentRoute: string = '/'
  onNavigate?: (route: string) => void
  build() {
    Row() {
      this.item('首页', 'home', '/')
      this.item('护肤柜', 'cabinet', '/product')
      this.item('肌肤检测', 'plan', '/skinstatus')
    }.width('92%').height(64).padding({ left: 8, right: 8 }).borderRadius(32).margin({ bottom: 8 })
      .backgroundColor(AISkinColor.elevated)
      .border({ width: { top: 1 }, color: AISkinColor.border })
  }
  @Builder
  item(label: string, icon: string, route: string) {
    Button() {
      Column({ space: 4 }) {
        AISkinIcon({ name: icon, selected: this.currentRoute === route })
        Text(label).fontSize(11).fontColor(this.currentRoute === route ? AISkinColor.accent : AISkinColor.secondary)
      }.width('100%').height(52).justifyContent(FlexAlign.Center)
    }.type(ButtonType.Normal).layoutWeight(1).height(56).borderRadius(20)
      .backgroundColor(this.currentRoute === route ? AISkinColor.selected : Color.Transparent)
      .accessibilityText(label).onClick(() => this.onNavigate?.(route))
  }
}
