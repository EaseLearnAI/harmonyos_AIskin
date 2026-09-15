import { TextStyle } from '../design/AISkinTheme'
import { AISkinButton, AISkinField, AISkinStateView } from '../design/AISkinPrimitives'
import { AccountTextStyle, AISkinProfilePanel, AISkinProfileIdentity, AISkinSettingsGroup, AISkinSettingsItem } from '../design/AISkinAccountComponents'
import { AISkinAccountTokens, AISkinAccountTextRole } from '../design/Foundation/AISkinAccountTokens'
import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinFieldVariant, AISkinStateKind } from '../design/Foundation/AISkinTokens'
import { AppHeader } from '../components/common/AppHeader'
import { SettingsMenu, ProfileMenuSection } from '../components/profile/SettingsMenu'
import { AuthService } from '../services/AuthService'
import { AuthApiService } from '../services/AuthApiService'
import { DocumentModal } from '../components/common/DocumentModal'
import { DeleteConfirmModal } from '../components/common/DeleteConfirmModal'
import { Modal } from '../components/common/Modal'
import { DocumentContent } from '../utils/DocumentContent'

@Component
export struct ProfileView {
  private authService: AuthService = AuthService.getInstance()
  private authApiService: AuthApiService = AuthApiService.getInstance()
  onLogout?: () => void
  onBack?: () => void
  onNavigate?: (route: string) => void
  registerBackHandler?: (handler: () => boolean) => void
  @State page: 'profile' | 'personal' | 'security' = 'profile'
  @State legal: string = ''
  @State isDeletingAccount: boolean = false
  @State showDeleteConfirm: boolean = false
  @State showLogoutConfirm: boolean = false
  @State userName: string = '析肤用户'
  @State phone: string = ''
  @State avatarURL: string = ''
  @State age: number = 0
  @State showsAgeEditor: boolean = false
  @State ageInput: string = ''
  @State isSavingAge: boolean = false
  @State ageError: string = ''
  @State actionError: string = ''
  @State availableHeight: number = 0
  private isDestroyed: boolean = false
  private records: AISkinSettingsItem[] = [
    { id: '/skin-history', title: '检测历史', icon: 'skin', isAction: true },
    { id: '/conflict-history', title: '冲突检测', icon: 'conflict', isAction: true }
  ]
  private management: AISkinSettingsItem[] = [
    { id: 'delete-account', title: '注销账户', icon: 'profile', isDestructive: true, isAction: true }
  ]

  aboutToAppear() {
    this.isDestroyed = false
    this.readCurrentUser()
    this.registerBackHandler?.(() => this.handleNestedBack())
    this.refreshUser()
  }
  aboutToDisappear() { this.isDestroyed = true }
  private readCurrentUser(): void {
    const user = this.authService.getCurrentUser()
    this.userName = user?.name || '析肤用户'
    const phone = user?.phone || ''
    this.phone = phone.length === 11 ? phone.slice(0, 3) + '****' + phone.slice(7) : phone
    this.avatarURL = user?.avatar || ''
    this.age = user?.age || 0
  }
  private async refreshUser(): Promise<void> {
    try {
      const response = await this.authService.fetchCurrentUser()
      if (!this.isDestroyed && response.success) this.readCurrentUser()
    } catch (error) {
      // Keep the authenticated account snapshot when a background refresh fails.
    }
  }
  private title(): string {
    return this.page === 'personal' ? '个人信息' : this.page === 'security' ? '账户与安全' : '我的'
  }
  private handleNestedBack(): boolean {
    if (this.isDeletingAccount || this.isSavingAge) return true
    if (this.legal) { this.legal = ''; return true }
    if (this.showsAgeEditor) { this.showsAgeEditor = false; return true }
    if (this.showDeleteConfirm) { this.showDeleteConfirm = false; return true }
    if (this.showLogoutConfirm) { this.showLogoutConfirm = false; return true }
    if (this.page !== 'profile') { this.page = 'profile'; return true }
    return false
  }
  private closePage(): void { if (!this.handleNestedBack()) this.onBack?.() }

  @Builder
  sectionLabel(title: string) {
    Text(title).attributeModifier(new AccountTextStyle(AISkinAccountTextRole.SectionLabel)).padding({ left: AISkinSpacing.xxSmall })
  }
  @Builder
  profileContent() {
    Column({ space: AISkinAccountTokens.profileSectionGap }) {
      if (this.actionError) { AISkinStateView({ title: '操作未完成', message: this.actionError, kind: AISkinStateKind.Error }) }
      AISkinProfileIdentity({ name: this.userName, avatarURL: this.avatarURL })
      Column({ space: AISkinSpacing.xSmall }) {
        this.sectionLabel('我的记录')
        AISkinSettingsGroup({ items: this.records, onSelect: (route: string) => this.onNavigate?.(route) })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        this.sectionLabel('账户')
        SettingsMenu({ onSettingClick: (id: string): void => { this.handleSettingClick(id) } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Text('让每一步护肤更清楚').attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary)).width('100%').textAlign(TextAlign.Center)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
  private personalItems(): AISkinSettingsItem[] {
    return [{ id: 'age', title: '年龄', value: this.age ? `${this.age}岁` : '未设置', isAction: true }]
  }
  private accountItems(): AISkinSettingsItem[] {
    return [
      { id: 'name', title: '昵称', value: this.userName, showsChevron: false },
      { id: 'method', title: '登录方式', value: this.phone ? '手机号' : '未提供', showsChevron: false }
    ]
  }
  @Builder
  personalContent() {
    AISkinSettingsGroup({ items: this.personalItems(), onSelect: () => {
      this.ageInput = this.age ? String(this.age) : ''; this.ageError = ''; this.showsAgeEditor = true
    } }).padding(AISkinSpacing.screenEdge)
  }
  @Builder
  securityContent() {
    Column({ space: AISkinAccountTokens.profileSectionGap }) {
      if (this.actionError) { AISkinStateView({ title: '操作失败', message: this.actionError, kind: AISkinStateKind.Error }) }
      Column({ space: AISkinSpacing.xSmall }) {
        this.sectionLabel('账户信息')
        AISkinSettingsGroup({ items: this.accountItems() })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        this.sectionLabel('了解更多')
        SettingsMenu({ section: ProfileMenuSection.Legal, onSettingClick: (id: string): void => { this.handleSettingClick(id) } })
      }.width('100%').alignItems(HorizontalAlign.Start)
      Column({ space: AISkinSpacing.xSmall }) {
        this.sectionLabel('账户管理')
        AISkinSettingsGroup({ items: this.management, isEnabled: !this.isDeletingAccount,
          onSelect: () => { this.actionError = ''; this.showDeleteConfirm = true } })
        Text('注销后将删除账户及相关数据，且无法恢复。').attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary))
      }.width('100%').alignItems(HorizontalAlign.Start)
    }.width('100%').padding(AISkinSpacing.screenEdge).alignItems(HorizontalAlign.Start)
  }
  @Builder
  ageEditorContent() {
    Column({ space: AISkinSpacing.small }) {
      Text('保存后将用于定制护肤方案，也可在个人信息中修改。').attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary))
      AISkinField({ value: this.ageInput, placeholder: '请输入年龄', inputType: InputType.Number,
        variant: AISkinFieldVariant.Form, isLoading: this.isSavingAge, error: this.ageError,
        onChange: (value: string) => { this.ageInput = value; this.ageError = '' } })
      if (this.ageInput && !this.validAge()) {
        AISkinStateView({ title: '请检查年龄', message: '请输入13–120的整数。', kind: AISkinStateKind.Error })
      }
    }.width('100%').padding(AISkinSpacing.cardPadding).alignItems(HorizontalAlign.Start)
  }
  @Builder
  ageEditorFooter() {
    AISkinButton({ title: '保存', isLoading: this.isSavingAge, isEnabled: this.validAge(), onAction: () => { this.saveAge() } })
      .padding({ left: AISkinSpacing.cardPadding, right: AISkinSpacing.cardPadding })
  }
  build() {
    Stack() {
      Column() {
        AppHeader({ title: this.title(), showBackButton: true, onBack: (): void => { this.closePage() } })
        Scroll() {
          if (this.page === 'profile') {
            AISkinProfilePanel({ minimumHeight: this.availableHeight, content: () => { this.profileContent() } })
          } else if (this.page === 'personal') { this.personalContent() }
          else { this.securityContent() }
        }.width('100%').constraintSize({ maxWidth: AISkinLayout.maxWidth }).layoutWeight(1)
          .scrollBar(BarState.Off).align(Alignment.Top)
          .onAreaChange((_old: Area, area: Area) => { this.availableHeight = Number(area.height) })
      }.width('100%').height('100%')
      DocumentModal({ show: this.legal !== '', title: this.legal,
        content: this.legal === '隐私政策' ? DocumentContent.getPrivacyPolicy() : DocumentContent.getTermsOfUse(), onClose: () => { this.legal = '' } })
      Modal({ show: this.showsAgeEditor, title: '年龄', isBusy: this.isSavingAge, onClose: () => { this.showsAgeEditor = false },
        content: () => { this.ageEditorContent() }, footer: () => { this.ageEditorFooter() } })
      DeleteConfirmModal({ show: this.showDeleteConfirm, title: '注销账户', confirmTitle: '确定注销',
        message: '确定要永久注销账户吗？此操作将删除账户及相关数据，且无法恢复。', isLoading: this.isDeletingAccount,
        onCancel: () => { this.showDeleteConfirm = false }, onConfirm: () => { this.deleteAccount() } })
      DeleteConfirmModal({ show: this.showLogoutConfirm, title: '退出登录', confirmTitle: '退出登录',
        message: '确定要退出当前账户吗？', onCancel: () => { this.showLogoutConfirm = false }, onConfirm: (): void => { this.handleLogout() } })
    }.width('100%').height('100%')
  }

  private handleSettingClick(id: string): void {
    if (id === 'personal' || id === 'security') { this.page = id; this.actionError = '' }
    else if (id === 'logout') this.showLogoutConfirm = true
    else if (id === 'terms') this.legal = '使用条款'
    else if (id === 'privacy') this.legal = '隐私政策'
  }
  private validAge(): boolean { return /^\d+$/.test(this.ageInput) && Number(this.ageInput) >= 13 && Number(this.ageInput) <= 120 }
  private async saveAge(): Promise<void> {
    if (!this.validAge() || this.isSavingAge) return
    this.isSavingAge = true
    this.ageError = ''
    try {
      const response = await this.authService.updateAge(Number(this.ageInput))
      if (this.isDestroyed) return
      if (response.success) { this.readCurrentUser(); this.showsAgeEditor = false }
      else this.ageError = response.message || '年龄保存失败，请稍后重试'
    } catch (error) {
      if (!this.isDestroyed) this.ageError = '网络请求失败，请稍后重试'
    } finally { if (!this.isDestroyed) this.isSavingAge = false }
  }
  private async deleteAccount(): Promise<void> {
    if (this.isDeletingAccount) return
    const token = this.authService.getToken()
    if (!token) { this.actionError = '登录状态已失效，请重新登录'; this.showDeleteConfirm = false; return }
    this.isDeletingAccount = true
    try {
      const response = await this.authApiService.deleteAccount(token)
      if (this.isDestroyed) return
      if (response.success) {
        try { this.authService.logout(); this.onLogout?.() }
        catch (error) { this.actionError = '账户已注销，但本机安全退出未完成，请重试退出登录'; this.showDeleteConfirm = false }
      }
      else { this.actionError = response.message || '注销失败，请稍后重试'; this.showDeleteConfirm = false }
    } catch (error) {
      if (!this.isDestroyed) { this.actionError = '网络请求失败，请稍后重试'; this.showDeleteConfirm = false }
    } finally { if (!this.isDestroyed) this.isDeletingAccount = false }
  }
  private handleLogout(): void {
    try { this.authService.logout(); this.onLogout?.() }
    catch (error) { this.actionError = '安全退出未完成，请重试'; this.showLogoutConfirm = false }
  }
}
