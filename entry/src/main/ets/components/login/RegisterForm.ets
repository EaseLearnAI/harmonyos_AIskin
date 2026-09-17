import { CardStyle, TextStyle } from '../../design/AISkinTheme'
import { AISkinButton, AISkinField, AISkinTag, AISkinStateView } from '../../design/AISkinPrimitives'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinButtonVariant, AISkinButtonLayout, AISkinTagState, AISkinTagVariant, AISkinStateKind, AISkinCardRole, AISkinCardState, AISkinCardInset } from '../../design/Foundation/AISkinTokens'
import { AuthService, UserData } from '../../services/AuthService'

@Component
export struct RegisterForm {
  @State name: string = ''
  @State phone: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State gender: 'male' | 'female' | '' = ''
  @State agreeTerms: boolean = false
  @State loading: boolean = false
  @State errorMessage: string = ''
  @State nameError: string = ''
  @State phoneError: string = ''
  @State passwordError: string = ''
  @State confirmError: string = ''
  @State genderError: string = ''
  @State termsError: string = ''
  private isDestroyed: boolean = false
  onRegisterSuccess?: (user: UserData) => void
  onNavigateToLogin?: () => void
  onShowTerms?: () => void
  onShowPrivacy?: () => void
  aboutToAppear() { this.isDestroyed = false }
  aboutToDisappear() { this.isDestroyed = true }

  build() {
    Column({ space: AISkinSpacing.large }) {
      if (this.errorMessage) {
        AISkinStateView({ title: '注册失败', message: this.errorMessage, kind: AISkinStateKind.Error })
      }
      Column({ space: AISkinSpacing.xSmall }) {
        Text('用户名').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        AISkinField({ value: this.name, placeholder: '请输入用户名', error: this.nameError, isLoading: this.loading,
          onChange: (value: string) => { this.name = value; this.nameError = ''; this.errorMessage = '' } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        Text('性别').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        Row({ space: AISkinSpacing.small }) {
          AISkinTag({ title: '男生', variant: AISkinTagVariant.SelectionCell,
            state: this.loading ? AISkinTagState.Disabled : (this.gender === 'male' ? AISkinTagState.Selected : AISkinTagState.Normal),
            onAction: () => { this.gender = 'male'; this.genderError = '' } }).layoutWeight(1)
          AISkinTag({ title: '女生', variant: AISkinTagVariant.SelectionCell,
            state: this.loading ? AISkinTagState.Disabled : (this.gender === 'female' ? AISkinTagState.Selected : AISkinTagState.Normal),
            onAction: () => { this.gender = 'female'; this.genderError = '' } }).layoutWeight(1)
        }.width('100%')
        if (this.genderError) { Text(this.genderError).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Destructive)) }
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        Text('手机号').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        AISkinField({ value: this.phone, placeholder: '请输入手机号', inputType: InputType.PhoneNumber,
          error: this.phoneError, isLoading: this.loading,
          onChange: (value: string) => { this.phone = value.trim(); this.phoneError = ''; this.errorMessage = '' } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        Text('密码').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        AISkinField({ value: this.password, placeholder: '请输入密码（至少6个字符）', isPassword: true,
          error: this.passwordError, isLoading: this.loading,
          onChange: (value: string) => { this.password = value; this.passwordError = ''; this.errorMessage = '' } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        Text('确认密码').attributeModifier(new TextStyle(AISkinTextRole.BodyEmphasized))
        AISkinField({ value: this.confirmPassword, placeholder: '请再次输入密码', isPassword: true,
          error: this.confirmError, isLoading: this.loading,
          onChange: (value: string) => { this.confirmPassword = value; this.confirmError = ''; this.errorMessage = '' } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xxSmall }) {
        AISkinTag({ title: this.agreeTerms ? '已阅读并同意条款和政策' : '我已阅读并同意条款和政策', variant: AISkinTagVariant.SelectionCell,
          state: this.loading ? AISkinTagState.Disabled : (this.agreeTerms ? AISkinTagState.Selected : AISkinTagState.Normal),
          onAction: () => { this.agreeTerms = !this.agreeTerms; this.termsError = '' } })
        Row({ space: AISkinSpacing.xSmall }) {
          AISkinButton({ title: '使用条款', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: () => this.onShowTerms?.() })
          AISkinButton({ title: '隐私政策', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: () => this.onShowPrivacy?.() })
        }.width('100%').justifyContent(FlexAlign.Center)
        if (this.termsError) { Text(this.termsError).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Destructive)) }
      }.width('100%').alignItems(HorizontalAlign.Start)
      AISkinButton({ title: '注册账号', isLoading: this.loading, onAction: () => { this.handleRegister() } })
      Row({ space: AISkinSpacing.xxSmall }) {
        Text('已有账号？').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
        AISkinButton({ title: '立即登录', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact,
          isEnabled: !this.loading, onAction: () => this.onNavigateToLogin?.() })
      }.width('100%').justifyContent(FlexAlign.Center)
    }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
  }

  validateForm(): boolean {
    this.name = this.name.trim()
    this.phone = this.phone.trim()
    this.nameError = this.name ? '' : '请输入用户名'
    this.genderError = this.gender ? '' : '请选择性别'
    this.phoneError = !this.phone ? '请输入手机号' : (!/^1[3-9]\d{9}$/.test(this.phone) ? '请输入有效的手机号' : '')
    this.passwordError = !this.password ? '请输入密码' : (this.password.length < 6 ? '密码长度至少6个字符' : '')
    this.confirmError = !this.confirmPassword ? '请确认密码' : (this.password !== this.confirmPassword ? '两次输入的密码不一致' : '')
    this.termsError = this.agreeTerms ? '' : '请阅读并同意条款和政策'
    return !this.nameError && !this.genderError && !this.phoneError && !this.passwordError && !this.confirmError && !this.termsError
  }

  async handleRegister() {
    if (this.loading || !this.validateForm() || this.isDestroyed) return
    this.loading = true
    this.errorMessage = ''
    try {
      const response = await AuthService.getInstance().register({ name: this.name, phone: this.phone, password: this.password, gender: this.gender as 'male' | 'female' })
      if (this.isDestroyed) return
      if (response.success && response.user) this.onRegisterSuccess?.(response.user)
      else this.errorMessage = response.message || '注册失败，请重试'
    } catch (error) {
      if (!this.isDestroyed) this.errorMessage = '网络请求失败，请稍后重试'
    } finally {
      if (!this.isDestroyed) this.loading = false
    }
  }
}
