import { AppHeader } from '../components/common/AppHeader'
import { ProfileCard } from '../components/profile/ProfileCard'
import { AchievementCard, AchievementItem } from '../components/profile/AchievementCard'
import { SettingsMenu } from '../components/profile/SettingsMenu'
import { AuthService } from '../services/AuthService'

@Component
export struct ProfileView {
  private authService: AuthService = AuthService.getInstance()
  onLogout?: () => void
  @State achievements: AchievementItem[] = [
    {
      id: '1',
      title: '护肤达人',
      description: '连续使用15天护肤品',
      icon: '⭐',
      color: 'sakura',
      unlocked: true,
      expReward: 500
    },
    {
      id: '2',
      title: '水分满满',
      description: '肌肤水分值达到90%',
      icon: '💧',
      color: 'blue',
      unlocked: true,
      expReward: 300
    },
    {
      id: '3',
      title: '打卡达人',
      description: '连续打卡30天',
      icon: '📅',
      color: 'gray',
      unlocked: false,
      progress: 15,
      target: 30
    },
    {
      id: '4',
      title: '产品收藏家',
      description: '收集50件护肤品',
      icon: '🧪',
      color: 'gold',
      unlocked: false,
      progress: 28,
      target: 50
    }
  ]

  build() {
    Column() {
      // Header
      AppHeader({
        title: '我的护肤档案',
        icon: 'paw',
        rightIcon: 'settings',
        bgColor: 'bg-sakura'
      })
      .width('100%')

      // Main Content
      Scroll() {
        Column() {
          // Profile Card
          ProfileCard({
            userName: '',
            userLevel: 25,
            userTitle: '护肤达人',
            progress: 75,
            nextLevelExp: 250,
            usedProducts: 28,
            skincareDays: 15,
            achievementCount: 8,
            avatarUrl: 'https://abc1567849.oss-cn-beijing.aliyuncs.com/avatars/1763021106334-avatar.jpeg'
          })
          .margin({ top: 14, left: 14, right: 14, bottom: 12 })

          // Achievement Card
          AchievementCard({
            achievements: this.achievements,
            unlockedCount: 8,
            totalCount: 12
          })
          .margin({ left: 14, right: 14, bottom: 12 })

          // Settings Menu
          Column() {
            SettingsMenu({
              onSettingClick: (settingId: string) => {
                this.handleSettingClick(settingId)
              }
            })
          }
          .width('100%')
          .padding({ left: 14, right: 14, bottom: 12 })

          // Logout Button
          Button('退出登录')
            .width('100%')
            .height(48)
            .backgroundColor('#FFEBEE')
            .fontColor('#F44336')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .margin({ left: 14, right: 14, bottom: 80 })
            .onClick(() => {
              this.handleLogout()
            })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff9fb')
  }

  handleSettingClick(settingId: string) {
    // TODO: Handle setting click
    console.info('Setting clicked:', settingId)
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
      console.error('❌ 退出登录失败:', JSON.stringify(error))
    }
  }
}






