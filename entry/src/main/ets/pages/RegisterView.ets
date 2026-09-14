import { AuthHeader } from '../components/login/AuthHeader'
import { RegisterForm } from '../components/login/RegisterForm'
import { UserData } from '../services/AuthService'
import { DocumentModal } from '../components/common/DocumentModal'
import { DocumentContent } from '../utils/DocumentContent'

@Component
export struct RegisterView {
  @State showTermsModal: boolean = false
  @State showPrivacyModal: boolean = false
  onRegisterSuccess?: () => void
  onNavigateToLogin?: () => void

  build() {
    Stack() {
      Column() {
        // Header
        AuthHeader({
          title: '创建账号',
          subtitle: '加入我们的护肤社区',
          bgColor: 'bg-sakura',
          showBackButton: true,
          onBack: () => {
            if (this.onNavigateToLogin) {
              this.onNavigateToLogin()
            }
          }
        })
        .width('100%')

        // Main Content
        Scroll() {
          Column() {
            RegisterForm({
              onRegisterSuccess: (user: UserData) => {
                this.handleRegisterSuccess(user)
              },
              onNavigateToLogin: () => {
                if (this.onNavigateToLogin) {
                  this.onNavigateToLogin()
                }
              },
              onShowTerms: () => {
                this.showTermsModal = true
              },
              onShowPrivacy: () => {
                this.showPrivacyModal = true
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

      // Terms Modal - 全屏覆盖
      DocumentModal({
        show: this.showTermsModal,
        title: '使用条款',
        content: DocumentContent.getTermsOfUse(),
        onClose: () => {
          this.showTermsModal = false
        }
      })

      // Privacy Policy Modal - 全屏覆盖
      DocumentModal({
        show: this.showPrivacyModal,
        title: '隐私政策',
        content: DocumentContent.getPrivacyPolicy(),
        onClose: () => {
          this.showPrivacyModal = false
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  handleRegisterSuccess(user: UserData) {
    if (this.onRegisterSuccess) {
      this.onRegisterSuccess()
    }
  }
}

