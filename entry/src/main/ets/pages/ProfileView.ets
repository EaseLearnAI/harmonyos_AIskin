import { AISkinColor, CardStyle } from '../design/AISkinTheme'
import { AISkinIcon } from '../design/AISkinIcon'
import { AppHeader } from '../components/common/AppHeader'
import { SettingsMenu } from '../components/profile/SettingsMenu'
import { AuthService } from '../services/AuthService'
import { AuthApiService } from '../services/AuthApiService'
import { DocumentModal } from '../components/common/DocumentModal'
import { DocumentContent } from '../utils/DocumentContent'

@Component
export struct ProfileView {
  private authService: AuthService = AuthService.getInstance()
  private authApiService: AuthApiService = AuthApiService.getInstance()
  onLogout?: () => void
  onBack?: () => void
  onNavigate?: (route: string) => void
  @State showPrivacyModal: boolean = false
  @State showTermsModal: boolean = false
  @State isDeletingAccount: boolean = false
  @State userName: string = '析肤用户'
  @State phone: string = ''
  aboutToAppear() {
    const user = this.authService.getCurrentUser()
    this.userName = user?.name || '析肤用户'
    const phone = user?.phone || ''
    this.phone = phone.length === 11 ? phone.slice(0, 3) + '****' + phone.slice(7) : phone
  }
  build() {
    Stack() {
      Column() {
        AppHeader({ title: '我的', showBackButton: true, onBack: this.onBack })
        Scroll() {
          Column({ space: 22 }) {
            Row({ space: 18 }) {
              Stack() {
                Circle().width(68).height(68).fill(AISkinColor.surface)
                AISkinIcon({ name: 'profile', iconSize: 34, selected: true })
              }
              Column({ space: 8 }) {
                Text(this.userName).fontSize(22).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
                Text(this.phone).fontSize(14).fontColor(AISkinColor.secondary)
              }.alignItems(HorizontalAlign.Start)
            }.width('100%').padding(24).attributeModifier(new CardStyle())
            Text('我的记录').width('100%').fontSize(13).fontColor(AISkinColor.secondary)
            Column() {
              this.recordRow('检测历史', 'skin', '/skinstatus')
              Divider().color(AISkinColor.divider)
              this.recordRow('冲突检测', 'conflict', '/conflict-history')
            }.width('100%').attributeModifier(new CardStyle())
            Text('账户与安全').width('100%').fontSize(13).fontColor(AISkinColor.secondary)
            SettingsMenu({ onSettingClick: (id: string) => this.handleSettingClick(id) })
            Button('退出登录').width('100%').height(48).fontColor(AISkinColor.danger)
              .backgroundColor(AISkinColor.surface).borderRadius(16).onClick(() => {
                AlertDialog.show({ title: '退出登录', message: '确定要退出当前账户吗？',
                  primaryButton: { value: '取消', action: () => {} },
                  secondaryButton: { value: '退出登录', action: () => { this.handleLogout() } } })
              })
            Text('让每一步护肤更清楚').fontSize(12).fontColor(AISkinColor.secondary)
          }.width('100%').constraintSize({ maxWidth: 600 }).padding({ left: 20, right: 20, bottom: 96, top: 10 })
        }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
      }.width('100%').height('100%')
      DocumentModal({ show: this.showPrivacyModal, title: '隐私政策', content: DocumentContent.getPrivacyPolicy(), onClose: () => { this.showPrivacyModal = false } })
      DocumentModal({ show: this.showTermsModal, title: '使用条款', content: DocumentContent.getTermsOfUse(), onClose: () => { this.showTermsModal = false } })
    }.width('100%').height('100%')
  }
  @Builder
  recordRow(title: string, icon: string, route: string) {
    Button() {
      Row({ space: 14 }) {
        AISkinIcon({ name: icon })
        Text(title).fontSize(16).fontColor(AISkinColor.text).layoutWeight(1)
        Text('›').fontSize(22).fontColor(AISkinColor.secondary)
      }.width('100%').padding(20)
    }.width('100%').type(ButtonType.Normal).backgroundColor(Color.Transparent).onClick(() => this.onNavigate?.(route))
  }
  handleSettingClick(settingId: string): void {
    if (settingId === 'privacy') {
      this.showPrivacyModal = true
    } else if (settingId === 'terms') {
      this.showTermsModal = true
    } else if (settingId === 'help') {
      AlertDialog.show({
        title: '帮助与反馈',
        message: '如需帮助、删除数据或反馈问题，请发送邮件至 abc1567849@gmail.com。',
        confirm: { value: '知道了', action: () => {} }
      })
    } else if (settingId === 'delete-account') {
      this.confirmDeleteAccount()
    }
  }

  confirmDeleteAccount(): void {
    AlertDialog.show({
      title: '永久注销账号？',
      message: '账号、皮肤分析、护肤方案、产品和反馈数据将永久删除且无法恢复。',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '永久删除',
        fontColor: AISkinColor.danger,
        action: () => { this.deleteAccount() }
      }
    })
  }

  async deleteAccount() {
    if (this.isDeletingAccount) return
    const token = this.authService.getToken()
    if (!token) return
    this.isDeletingAccount = true
    try {
      const response = await this.authApiService.deleteAccount(token)
      if (response.success) {
        this.authService.logout()
        if (this.onLogout) this.onLogout()
      } else {
        AlertDialog.show({
          title: '注销失败',
          message: response.message || '请稍后重试，或联系 abc1567849@gmail.com。',
          confirm: { value: '知道了', action: () => {} }
        })
      }
    } catch (error) {
      AlertDialog.show({
        title: '注销失败',
        message: '网络请求失败，请稍后重试，或联系 abc1567849@gmail.com。',
        confirm: { value: '知道了', action: () => {} }
      })
    } finally {
      this.isDeletingAccount = false
    }
  }

  async handleLogout() {
    console.log('===== 🚪 退出登录 =====')
    try {
      this.authService.logout()
      console.log('✅ 退出登录成功')
      
      // 通知父组件退出登录
      if (this.onLogout) {
        this.onLogout()
      }
    } catch (error) {
      console.error('❌ 退出登录失败')
    }
  }
}



