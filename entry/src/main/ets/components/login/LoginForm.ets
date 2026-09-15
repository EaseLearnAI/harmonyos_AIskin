import { CardStyle, TextStyle } from '../../design/AISkinTheme'
import { AISkinButton, AISkinField, AISkinStateView } from '../../design/AISkinPrimitives'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinButtonVariant, AISkinButtonLayout, AISkinStateKind, AISkinCardRole, AISkinCardState, AISkinCardInset } from '../../design/Foundation/AISkinTokens'
import { AuthService, UserData } from '../../services/AuthService'

// Platform-specific authentication; field, action and feedback appearances are shared.
@Component
export struct LoginForm {
  @State phone: string = ''
  @State password: string = ''
  @State loading: boolean = false
  @State errorMessage: string = ''
  @State phoneError: string = ''
  @State passwordError: string = ''
  private isDestroyed: boolean = false
  onLoginSuccess?: (user: UserData) => void
  onNavigateToRegister?: () => void

  aboutToAppear() { this.isDestroyed = false }
  aboutToDisappear() { this.isDestroyed = true }

  build() {
    Column({ space: AISkinSpacing.large }) {
      if (this.errorMessage) {
        AISkinStateView({ title: '登录失败', message: this.errorMessage, kind: AISkinStateKind.Error })
      }
      Column({ space: AISkinSpacing.xSmall }) {
        Text('手机号').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        AISkinField({ value: this.phone, placeholder: '请输入手机号', inputType: InputType.PhoneNumber,
          error: this.phoneError, isLoading: this.loading,
          onChange: (value: string) => { this.phone = value.trim(); this.phoneError = ''; this.errorMessage = '' } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        Text('密码').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        AISkinField({ value: this.password, placeholder: '请输入密码', isPassword: true,
          error: this.passwordError, isLoading: this.loading,
          onChange: (value: string) => { this.password = value; this.passwordError = ''; this.errorMessage = '' } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      AISkinButton({ title: '登录', isLoading: this.loading, onAction: () => { this.handleLogin() } })
      Row({ space: AISkinSpacing.xxSmall }) {
        Text('还没有账号？').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
        AISkinButton({ title: '立即注册', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact,
          isEnabled: !this.loading, onAction: () => this.onNavigateToRegister?.() })
      }.width('100%').justifyContent(FlexAlign.Center)
    }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
  }

  validateForm(): boolean {
    this.phone = this.phone.trim()
    this.phoneError = !this.phone ? '请输入手机号' : (!/^1[3-9]\d{9}$/.test(this.phone) ? '请输入有效的手机号' : '')
    this.passwordError = this.password ? '' : '请输入密码'
    return !this.phoneError && !this.passwordError
  }

  async handleLogin() {
    if (this.loading || !this.validateForm() || this.isDestroyed) return
    this.loading = true
    this.errorMessage = ''
    try {
      const response = await AuthService.getInstance().login({ phone: this.phone, password: this.password, remember: false })
      if (this.isDestroyed) return
      if (response.success && response.user) this.onLoginSuccess?.(response.user)
      else this.errorMessage = response.message || '登录失败，请重试'
    } catch (error) {
      if (!this.isDestroyed) this.errorMessage = '网络请求失败，请稍后重试'
    } finally {
      if (!this.isDestroyed) this.loading = false
    }
  }
}
