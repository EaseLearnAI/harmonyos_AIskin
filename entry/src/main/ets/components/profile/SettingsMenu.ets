import { AISkinSettingsGroup, AISkinSettingsItem } from '../../design/AISkinAccountComponents'
export enum ProfileMenuSection { Account, Legal }
@Component
export struct SettingsMenu {
  @Prop section: ProfileMenuSection = ProfileMenuSection.Account
  @Prop isBusy: boolean = false
  onSettingClick?: (id: string) => void
  private account: AISkinSettingsItem[] = [
    { id: 'personal', title: '个人信息', icon: 'profile', isAction: true },
    { id: 'security', title: '账户与安全', icon: 'profile', isAction: true },
    { id: 'logout', title: '退出登录', isDestructive: true, showsChevron: false, isAction: true }
  ]
  private legal: AISkinSettingsItem[] = [
    { id: 'terms', title: '使用条款', icon: 'plan', isAction: true },
    { id: 'privacy', title: '隐私政策', icon: 'profile', isAction: true }
  ]
  build() {
    AISkinSettingsGroup({ items: this.section === ProfileMenuSection.Account ? this.account : this.legal,
      isEnabled: !this.isBusy, onSelect: this.onSettingClick })
  }
}
