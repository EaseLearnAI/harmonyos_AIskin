import { AISkinTabBar, AISkinTabItem } from '../../design/AISkinTabBar'
import { AISkinSpacing } from '../../design/Foundation/AISkinTokens'
@Component
export struct BottomNavigation {
  @Prop currentRoute: string = '/'
  onNavigate?: (route: string) => void
  private items: AISkinTabItem[] = [
    { title: '首页', icon: 'homeFilled', route: '/' },
    { title: '护肤柜', icon: 'cabinetFilled', route: '/product' },
    { title: '肌肤检测', icon: 'planFilled', route: '/skinstatus' }
  ]
  build() {
    AISkinTabBar({ items: this.items, selection: this.currentRoute, onSelect: this.onNavigate })
      .width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge })
      .margin({ bottom: AISkinSpacing.xSmall })
  }
}
