import { TextStyle } from '../../design/AISkinTheme'
import { AISkinSpacing, AISkinTextRole, AISkinTone } from '../../design/Foundation/AISkinTokens'
import { AppHeader } from '../common/AppHeader'
@Component
export struct AuthHeader {
  @Prop title: string = '欢迎回来'
  @Prop subtitle: string = '开始你的护肤之旅'
  @Prop showBackButton: boolean = true
  onBack?: () => void
  build() {
    Column({ space: AISkinSpacing.xSmall }) {
      AppHeader({ title: '析肤AI', showBackButton: this.showBackButton, onBack: this.onBack })
      Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.FeatureTitle))
      Text(this.subtitle).attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
    }.width('100%').padding({ bottom: AISkinSpacing.xLarge })
  }
}
