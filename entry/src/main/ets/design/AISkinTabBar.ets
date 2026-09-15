import { AISkinColor, TextStyle } from './AISkinTheme'
import { AISkinIcon } from './AISkinIcon'
import { AISkinLayout, AISkinRadius, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinMotion } from './Foundation/AISkinTokens'
export interface AISkinTabItem { title: string; icon: string; route: string }

// HarmonyOS navigation facade for the native iOS TabView role; one appearance owner.
@Component
export struct AISkinTabBar {
  @Prop items: AISkinTabItem[] = []
  @Prop selection: string = '/'
  @State pressedRoute: string = ''
  onSelect?: (route: string) => void
  build() {
    Row() {
      ForEach(this.items, (item: AISkinTabItem) => {
        Button() {
          Column({ space: AISkinSpacing.xxSmall }) {
            AISkinIcon({ name: item.icon, iconSize: AISkinLayout.iconSize, selected: this.selection === item.route })
            Text(item.title).attributeModifier(new TextStyle(AISkinTextRole.TabLabel, this.selection === item.route ? AISkinTone.Accent : AISkinTone.Secondary))
          }.width('100%').constraintSize({ minHeight: AISkinLayout.tap }).justifyContent(FlexAlign.Center)
        }.type(ButtonType.Normal).layoutWeight(1).borderRadius(AISkinRadius.control)
          .backgroundColor(this.selection === item.route ? AISkinColor.selected : Color.Transparent)
          .opacity(this.pressedRoute === item.route ? AISkinMotion.pressedOpacity : 1)
          .accessibilityText(`${item.title}${this.selection === item.route ? '，已选中' : ''}`)
          .onTouch((event: TouchEvent) => { this.pressedRoute = event.type === TouchType.Down ? item.route : '' })
          .onClick(() => this.onSelect?.(item.route))
      }, (item: AISkinTabItem) => item.route)
    }.width('100%').height(AISkinLayout.tabHeight).padding(AISkinSpacing.xSmall)
      .backgroundColor(AISkinColor.elevated).borderRadius(AISkinRadius.capsule)
      .border({ width: AISkinLayout.hairline, color: AISkinColor.border })
  }
}
