@Component
export struct AchievementCard {
  @Prop achievements: AchievementItem[] = []
  @Prop unlockedCount: number = 8
  @Prop totalCount: number = 12

  build() {
    Column() {
      // Header
      Row() {
        Row() {
          Text('🏆')
            .fontSize(16)
            .margin({ right: 8 })
          Text('我的成就')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
        }
        .layoutWeight(1)

        Text(`${this.unlockedCount}/${this.totalCount} 已解锁`)
          .fontSize(11)
          .fontColor('#6b7280')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // Achievements Grid
      Grid() {
        ForEach(this.achievements, (achievement: AchievementItem, index: number) => {
          GridItem() {
            this.AchievementItem(achievement)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(280)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  AchievementItem(achievement: AchievementItem) {
    Column() {
      // Icon
      Row() {
        Text(achievement.icon)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .borderRadius(12)
      .backgroundColor(achievement.unlocked ? this.getIconBgColor(achievement.color) : '#f3f4f6')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      // Title
      Text(achievement.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(achievement.unlocked ? '#1f2937' : '#9ca3af')
        .margin({ bottom: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // Description
      Text(achievement.description)
        .fontSize(10)
        .fontColor(achievement.unlocked ? '#6b7280' : '#d1d5db')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 8 })

      // Status
      if (achievement.unlocked) {
        Row() {
          Text('已获得')
            .fontSize(9)
            .fontColor('#F8BBD0')
            .layoutWeight(1)

          if (achievement.expReward && achievement.expReward > 0) {
            Row() {
              Text('💎')
                .fontSize(9)
                .margin({ right: 2 })
              Text(`+${achievement.expReward}经验`)
                .fontSize(9)
                .fontColor('#FFD700')
            }
          }
        }
        .width('100%')
      } else {
        Text(`进度: ${achievement.progress || 0}/${achievement.target || 0}`)
          .fontSize(9)
          .fontColor('#9ca3af')
          .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor(achievement.unlocked ? '#ffffff' : '#fafafa')
    .borderRadius(12)
    .border({
      width: 1,
      color: achievement.unlocked ? '#f3f4f6' : '#e5e7eb',
      style: BorderStyle.Solid
    })
    .opacity(achievement.unlocked ? 1 : 0.6)
  }

  getIconBgColor(color: string): string {
    switch (color) {
      case 'sakura':
        return '#FFF9FB'
      case 'blue':
        return '#E3F2FD'
      case 'gold':
        return '#FFF9E6'
      default:
        return '#f3f4f6'
    }
  }
}

// Data Models
export interface AchievementItem {
  id: string
  title: string
  description: string
  icon: string
  color: string
  unlocked: boolean
  progress?: number
  target?: number
  expReward?: number
}






