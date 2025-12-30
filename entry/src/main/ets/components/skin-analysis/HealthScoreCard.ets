@Component
export struct HealthScoreCard {
  @Prop score: number = 0
  @State animatedScore: number = 0

  aboutToAppear() {
    this.animateScore()
  }

  animateScore() {
    const duration = 2000
    const startTime = Date.now()
    const startScore = 0
    const endScore = this.score

    const animate = () => {
      const elapsed = Date.now() - startTime
      const progress = Math.min(elapsed / duration, 1)
      const easeOutCubic = 1 - Math.pow(1 - progress, 3)
      this.animatedScore = Math.round(startScore + (endScore - startScore) * easeOutCubic)

      if (progress < 1) {
        setTimeout(() => {
          animate()
        }, 16)
      }
    }

    animate()
  }

  getRatingText(): string {
    if (this.animatedScore >= 90) return '优秀'
    if (this.animatedScore >= 80) return '良好'
    if (this.animatedScore >= 70) return '一般'
    if (this.animatedScore >= 60) return '需改善'
    return '需关注'
  }

  getRatingClass(): string {
    if (this.animatedScore >= 90) return 'excellent'
    if (this.animatedScore >= 80) return 'very-good'
    if (this.animatedScore >= 70) return 'good'
    if (this.animatedScore >= 60) return 'fair'
    return 'needs-improvement'
  }

  getStarRating(): number {
    if (this.animatedScore >= 90) return 5
    if (this.animatedScore >= 80) return 4
    if (this.animatedScore >= 70) return 3
    if (this.animatedScore >= 60) return 2
    return 1
  }

  getAchievementText(): string {
    if (this.animatedScore >= 90) return '肌肤状态极佳！'
    if (this.animatedScore >= 80) return '肌肤状态良好'
    if (this.animatedScore >= 70) return '肌肤状态一般'
    if (this.animatedScore >= 60) return '需要加强护理'
    return '建议咨询专业医生'
  }

  build() {
    Column() {
      // Score Header
      Row() {
        Column() {
          Row() {
            Text('✨')
              .fontSize(20)
              .margin({ right: 0 })
            Text('AI肌肤健康评分')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 8 })

          Text('基于深度学习智能分析')
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.8)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // Score Circle
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Text(this.animatedScore.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text('分')
              .fontSize(14)
              .fontColor(Color.White)
              .opacity(0.8)
          }
          .width(96)
          .height(96)
          .borderRadius(48)
          .border({
            width: 4,
            color: Color.White,
            style: BorderStyle.Solid
          })
          .backgroundColor('rgba(255, 255, 255, 0.15)')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width(96)
        .height(96)
      }
      .width('100%')
      .margin({ bottom: 24 })

      // Score Details
      Column() {
        // Rating
        Row() {
          Text('健康等级:')
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.8)

          Blank()

          Row() {
            Text(this.getRatingText())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('rgba(255, 255, 255, 0.2)')
              .borderRadius(8)
              .margin({ right: 8 })

            Row() {
              ForEach([1, 2, 3, 4, 5], (star: number) => {
                Text('★')
                  .fontSize(14)
                  .fontColor(star <= this.getStarRating() ? '#FCD34D' : 'rgba(255, 255, 255, 0.3)')
              })
            }
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 16 })

        // Achievement Badge
        Row() {
          Text('🏆')
            .fontSize(16)
            .margin({ right: 8 })
          Text(this.getAchievementText())
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .opacity(0.9)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('rgba(255, 255, 255, 0.15)')
        .borderRadius(12)
        .border({
          width: 1,
          color: 'rgba(255, 255, 255, 0.2)',
          style: BorderStyle.Solid
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#667eea')
    .borderRadius(24)
    .margin({ bottom: 16 })
  }
}

