@Component
export struct SettingsMenu {
  onSettingClick?: (settingId: string) => void

  private settings: SettingItem[] = [
    {
      id: 'notification',
      title: '消息通知',
      description: '管理护肤提醒和系统通知',
      icon: '🔔',
      color: '#42A5F5'
    },
    {
      id: 'theme',
      title: '主题设置',
      description: '自定义皮肤和背景',
      icon: '🎨',
      color: '#AB47BC'
    },
    {
      id: 'help',
      title: '帮助与反馈',
      description: '提供使用建议和问题反馈',
      icon: '❓',
      color: '#66BB6A'
    },
    {
      id: 'about',
      title: '关于我们',
      description: '了解产品和服务',
      icon: 'ℹ️',
      color: '#EF5350'
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
          .fontSize(18)
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
          .fontColor('#1f2937')
          .margin({ bottom: 2 })

        Text(setting.description)
          .fontSize(11)
          .fontColor('#6b7280')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Arrow
      Text('›')
        .fontSize(20)
        .fontColor('#d1d5db')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      if (this.onSettingClick) {
        this.onSettingClick(setting.id)
      }
    })
  }

  getIconBgColor(color: string): string {
    switch (color) {
      case '#42A5F5':
        return '#E3F2FD'
      case '#AB47BC':
        return '#F3E5F5'
      case '#66BB6A':
        return '#E8F5E9'
      case '#EF5350':
        return '#FFEBEE'
      default:
        return '#f3f4f6'
    }
  }
}

// Data Models
interface SettingItem {
  id: string
  title: string
  description: string
  icon: string
  color: string
}






