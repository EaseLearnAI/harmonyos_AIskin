import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
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
            .fontColor(AISkinColor.text)
        }
        .layoutWeight(1)

        Text(`${this.unlockedCount}/${this.totalCount} 已解锁`)
          .fontSize(11)
          .fontColor(AISkinColor.secondary)
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
    .attributeModifier(new CardStyle())
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
      .backgroundColor(achievement.unlocked ? this.getIconBgColor(achievement.color) : AISkinColor.muted)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      // Title
      Text(achievement.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(achievement.unlocked ? AISkinColor.text : AISkinColor.secondary)
        .margin({ bottom: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // Description
      Text(achievement.description)
        .fontSize(10)
        .fontColor(achievement.unlocked ? AISkinColor.secondary : AISkinColor.secondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 8 })

      // Status
      if (achievement.unlocked) {
        Row() {
          Text('已获得')
            .fontSize(9)
            .fontColor(AISkinColor.accent)
            .layoutWeight(1)

          if (achievement.expReward && achievement.expReward > 0) {
            Row() {
              Text('💎')
                .fontSize(9)
                .margin({ right: 2 })
              Text(`+${achievement.expReward}经验`)
                .fontSize(9)
                .fontColor('#8A6D00')
            }
          }
        }
        .width('100%')
      } else {
        Text(`进度: ${achievement.progress || 0}/${achievement.target || 0}`)
          .fontSize(9)
          .fontColor(AISkinColor.secondary)
          .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor(achievement.unlocked ? AISkinColor.white : AISkinColor.muted)
    .borderRadius(12)
    .border({
      width: 1,
      color: achievement.unlocked ? AISkinColor.muted : AISkinColor.divider,
      style: BorderStyle.Solid
    })
    .opacity(achievement.unlocked ? 1 : 0.6)
  }

  getIconBgColor(color: ResourceColor): ResourceColor {
    switch (color) {
      case 'sakura':
        return '#FFF9FB'
      case 'blue':
        return AISkinColor.selected
      case 'gold':
        return AISkinColor.muted
      default:
        return AISkinColor.muted
    }
  }
}

// Data Models
export interface AchievementItem {
  id: string
  title: string
  description: string
  icon: string
  color: ResourceColor
  unlocked: boolean
  progress?: number
  target?: number
  expReward?: number
}





