import { AuthHeader } from '../components/login/AuthHeader'
import { LoginForm } from '../components/login/LoginForm'
import { AISkinLayout, AISkinSpacing } from '../design/Foundation/AISkinTokens'

@Component
export struct LoginView {
  onLoginSuccess?: () => void
  onNavigateToRegister?: () => void
  build() {
    Column() {
      AuthHeader({ title: '欢迎回来', subtitle: '开始你的护肤之旅', showBackButton: false })
      Scroll() {
        LoginForm({ onLoginSuccess: () => this.onLoginSuccess?.(), onNavigateToRegister: this.onNavigateToRegister })
          .width('100%').constraintSize({ maxWidth: AISkinLayout.modalMaxWidth })
          .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.xxLarge })
      }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }.width('100%').height('100%')
  }
}
