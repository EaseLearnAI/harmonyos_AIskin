@Component
export struct ProfileCard {
  @Prop userName: string = ''
  @Prop userLevel: number = 25
  @Prop userTitle: string = '护肤达人'
  @Prop progress: number = 75
  @Prop nextLevelExp: number = 250
  @Prop usedProducts: number = 28
  @Prop skincareDays: number = 15
  @Prop achievementCount: number = 8
  @Prop avatarUrl: string = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop'

  build() {
    Column() {
      // User Info Section
      Row() {
        // Avatar with Level Badge
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.avatarUrl)
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .border({
              width: 4,
              color: Color.White,
              style: BorderStyle.Solid
            })
            .shadow({
              radius: 8,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 2
            })
            .alt('用户头像')

          // Level Badge
          Row() {
            Text(this.userLevel.toString())
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .width(32)
          .height(32)
          .borderRadius(16)
          .backgroundColor('#F8BBD0')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: -4, right: -4 })
          .shadow({
            radius: 4,
            color: 'rgba(0, 0, 0, 0.15)',
            offsetX: 0,
            offsetY: 2
          })
        }
        .width(80)
        .height(80)
        .margin({ right: 16 })

        // User Details
        Column() {
          Row() {
            Text(this.userName)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1f2937')
              .layoutWeight(1)

            // Title Badge
            Row() {
              Text('👑')
                .fontSize(12)
                .margin({ right: 4 })
              Text(this.userTitle)
                .fontSize(11)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
            .backgroundColor('#FFD700')
            .shadow({
              radius: 2,
              color: 'rgba(255, 215, 0, 0.3)',
              offsetX: 0,
              offsetY: 1
            })
          }
          .width('100%')
          .margin({ bottom: 8 })

          // Progress Bar
          Stack() {
            // Background
            Row()
              .width('100%')
              .height(8)
              .backgroundColor('rgba(0, 0, 0, 0.08)')
              .borderRadius(4)

            // Progress Fill
            Row()
              .width(`${this.progress}%`)
              .height(8)
              .backgroundColor('#F8BBD0')
              .borderRadius(4)
          }
          .width('100%')
          .height(8)
          .margin({ bottom: 6 })

          // Level Info
          Row() {
            Text(`Lv.${this.userLevel} 护肤专家`)
              .fontSize(11)
              .fontColor('#6b7280')
              .layoutWeight(1)

            Text(`距离下一级还需 ${this.nextLevelExp} 经验`)
              .fontSize(11)
              .fontColor('#F8BBD0')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // Stats Grid
      Row() {
        this.StatItem('已用产品', this.usedProducts.toString(), '#F8BBD0')
        this.StatItem('护肤天数', this.skincareDays.toString(), '#C8E6C9')
        this.StatItem('成就徽章', this.achievementCount.toString(), '#FFECB3')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
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
  StatItem(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(11)
        .fontColor('#6b7280')
    }
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .layoutWeight(1)
    .backgroundColor(this.getStatBgColor(color))
    .borderRadius(12)
    .margin({ left: 4, right: 4 })
  }

  getStatBgColor(color: string): string {
    if (color === '#F8BBD0') {
      return '#FFF9FB'
    } else if (color === '#C8E6C9') {
      return '#E8F5E9'
    } else {
      return '#FFF9E6'
    }
  }
}

