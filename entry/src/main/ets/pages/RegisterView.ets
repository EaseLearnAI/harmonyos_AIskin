import { AuthHeader } from '../components/login/AuthHeader'
import { RegisterForm } from '../components/login/RegisterForm'
import { DocumentModal } from '../components/common/DocumentModal'
import { DocumentContent } from '../utils/DocumentContent'
import { AISkinLayout, AISkinSpacing } from '../design/Foundation/AISkinTokens'
@Component
export struct RegisterView {
  @State showTermsModal: boolean = false
  @State showPrivacyModal: boolean = false
  onRegisterSuccess?: () => void
  onNavigateToLogin?: () => void
  build() {
    Stack() {
      Column() {
        AuthHeader({ title: '创建账号', subtitle: '开始你的护肤之旅', showBackButton: true, onBack: this.onNavigateToLogin })
        Scroll() {
          RegisterForm({ onRegisterSuccess: () => this.onRegisterSuccess?.(), onNavigateToLogin: this.onNavigateToLogin,
            onShowTerms: () => { this.showTermsModal = true }, onShowPrivacy: () => { this.showPrivacyModal = true } })
            .width('100%').constraintSize({ maxWidth: AISkinLayout.modalMaxWidth })
            .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.xxLarge })
        }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
      }.width('100%').height('100%')
      DocumentModal({ show: this.showTermsModal, title: '使用条款', content: DocumentContent.getTermsOfUse(), onClose: () => { this.showTermsModal = false } })
      DocumentModal({ show: this.showPrivacyModal, title: '隐私政策', content: DocumentContent.getPrivacyPolicy(), onClose: () => { this.showPrivacyModal = false } })
    }.width('100%').height('100%')
  }
}
