@Component
export struct AnalysisSummary {
  @Prop analysis: SummaryData = {
    efficacyAnalysis: [],
    potentialRisks: [],
    recommendations: [],
    overallRating: 0,
    summary: ''
  }

  build() {
    Column() {
      // Header
      Row() {
        Row() {
          Text('🤖')
            .fontSize(16)
            .margin({ right: 8 })
          Text('AI智能解析')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .layoutWeight(1)

        Row() {
          Text('🔄')
            .fontSize(12)
            .margin({ right: 4 })
          Text('刚刚更新')
            .fontSize(12)
            .fontColor('#757575')
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      // Analysis Cards
      Column() {
        // Efficacy Analysis
        this.AnalysisCard('✨ 功效分析', this.analysis.efficacyAnalysis || [], '#6a1b9a', '#f3e5f5', '#e1bee7')

        // Potential Risks
        this.AnalysisCard('⚠️ 潜在风险', this.analysis.potentialRisks || [], '#ef6c00', '#fff8e1', '#ffe082')

        // Recommendations
        this.AnalysisCard('💡 使用建议', this.analysis.recommendations || [], '#0d47a1', '#e3f2fd', '#bbdefb')

        // Overall Rating
        this.RatingCard()
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 8 })
    .shadow({
      radius: 8,
      color: 'rgba(255, 182, 193, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  AnalysisCard(title: string, items: string[], titleColor: string, bgColor: string, iconBgColor: string) {
    Column() {
      Row() {
        Column() {
          Text(this.getIconForTitle(title))
            .fontSize(16)
            .fontColor(titleColor)
        }
        .width(40)
        .height(40)
        .backgroundColor(iconBgColor)
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(titleColor)
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 12 })

      Column() {
        ForEach(items, (item: string, index: number) => {
          Row() {
            Text(this.getIconForItem(title))
              .fontSize(12)
              .fontColor(this.getIconColor(title))
              .margin({ right: 8, top: 2 })
            Text(item)
              .fontSize(14)
              .fontColor('#424242')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(bgColor)
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  RatingCard() {
    Column() {
      Row() {
        Row() {
          Text('⭐')
            .fontSize(16)
            .margin({ right: 8 })
          Text('AI综合评分')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .layoutWeight(1)

        Text(`${this.analysis.overallRating || 0}/5.0`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#6a1b9a')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(this.analysis.summary || '暂无评价')
        .fontSize(14)
        .fontColor('#424242')
        .lineHeight(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f3e5f5')
    .borderRadius(12)
  }

  getIconForTitle(title: string): string {
    if (title.includes('功效')) return '✨'
    if (title.includes('风险')) return '⚠️'
    if (title.includes('建议')) return '💡'
    return '📋'
  }

  getIconForItem(title: string): string {
    if (title.includes('功效')) return '✓'
    if (title.includes('风险')) return '!'
    if (title.includes('建议')) return 'i'
    return '•'
  }

  getIconColor(title: string): ResourceColor {
    if (title.includes('功效')) return '#4caf50'
    if (title.includes('风险')) return '#ff9800'
    if (title.includes('建议')) return '#1e88e5'
    return '#666666'
  }
}

// Data Models
export interface SummaryData {
  efficacyAnalysis?: string[]
  potentialRisks?: string[]
  recommendations?: string[]
  overallRating?: number
  summary?: string
}

