import { AuthHeader } from '../components/login/AuthHeader'
import { LoginForm } from '../components/login/LoginForm'
import { UserData } from '../services/AuthService'

@Component
export struct LoginView {
  onLoginSuccess?: () => void
  onNavigateToRegister?: () => void

  build() {
    Column() {
      // Header
      AuthHeader({
        title: '欢迎回来',
        subtitle: '开始你的护肤之旅',
        bgColor: 'bg-sakura',
        showBackButton: false,
        onBack: () => {
          // No back button on login page
        }
      })
      .width('100%')

      // Main Content
      Scroll() {
        Column() {
          LoginForm({
            onLoginSuccess: (user: UserData) => {
              this.handleLoginSuccess(user)
            },
            onNavigateToRegister: () => {
              if (this.onNavigateToRegister) {
                this.onNavigateToRegister()
              }
            }
          })
          .width('100%')
          .margin({ top: -24 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 32, bottom: 32 })
        .alignItems(HorizontalAlign.Center)
        .constraintSize({ maxWidth: 400 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off).align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }

  handleLoginSuccess(user: UserData) {
    if (this.onLoginSuccess) {
      this.onLoginSuccess()
    }
  }
}

