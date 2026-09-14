import { AISkinColor } from '../../design/AISkinTheme'
@Component
export struct SettingsMenu {
  onSettingClick?: (settingId: string) => void

  private settings: SettingItem[] = [
    {
      id: 'privacy',
      title: '隐私政策',
      description: '查看数据收集、AI处理与删除说明',
      icon: '○',
      color: AISkinColor.accent
    },
    {
      id: 'terms',
      title: '使用条款',
      description: '查看服务范围与免责声明',
      icon: '≡',
      color: AISkinColor.accent
    },
    {
      id: 'help',
      title: '帮助与反馈',
      description: '提供使用建议和问题反馈',
      icon: '?',
      color: AISkinColor.success
    },
    {
      id: 'delete-account',
      title: '注销账号',
      description: '永久删除账号及全部关联数据',
      icon: '−',
      color: AISkinColor.danger
    }
  ]

  build() {
    Column() {
      ForEach(this.settings, (setting: SettingItem) => {
        this.SettingItem(setting)
      })
    }
    .width('100%')
  }

  @Builder
  SettingItem(setting: SettingItem) {
    Row() {
      // Icon
      Row() {
        Text(setting.icon)
          .fontSize(18).fontColor(AISkinColor.accent)
      }
      .width(40)
      .height(40)
      .borderRadius(10)
      .backgroundColor(this.getIconBgColor(setting.color))
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // Content
      Column() {
        Text(setting.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 2 })

        Text(setting.description)
          .fontSize(11)
          .fontColor(AISkinColor.secondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Arrow
      Text('›')
        .fontSize(20)
        .fontColor(AISkinColor.secondary)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(AISkinColor.surface)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      if (this.onSettingClick) {
        this.onSettingClick(setting.id)
      }
    })
  }

  getIconBgColor(color: ResourceColor): ResourceColor {
    switch (color) {
      case AISkinColor.accent:
        return AISkinColor.selected
      case AISkinColor.accent:
        return AISkinColor.muted
      case AISkinColor.success:
        return AISkinColor.successSurface
      case AISkinColor.danger:
        return AISkinColor.dangerSurface
      default:
        return AISkinColor.muted
    }
  }
}

// Data Models
interface SettingItem {
  id: string
  title: string
  description: string
  icon: string
  color: ResourceColor
}





