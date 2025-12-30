@Component
export struct AnalysisOverview {
  @Prop analysis: AnalysisData = {
    safetyIndex: 0,
    efficacyScore: 0,
    activeIngredients: 0,
    acneRisk: { level: '低', percentage: 0 },
    irritationRisk: { level: '低', percentage: 0 },
    allergyRisk: { level: '低', percentage: 0 }
  }

  build() {
    Column() {
      Text('安全性分析')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 16 })

      // Score Cards
      Row() {
        this.ScoreCard('安全指数', this.analysis.safetyIndex || 0, '#2e7d32', '#e8f5e9')
        this.ScoreCard('功效评分', this.analysis.efficacyScore || 0, '#1565c0', '#e3f2fd')
        this.ScoreCard('活性成分', this.analysis.activeIngredients || 0, '#6a1b9a', '#f3e5f5')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      // Risk Indicators
      Column() {
        this.RiskIndicator('致痘风险', this.analysis.acneRisk || { level: '低', percentage: 0 })
        this.RiskIndicator('刺激风险', this.analysis.irritationRisk || { level: '低', percentage: 0 })
        this.RiskIndicator('过敏风险', this.analysis.allergyRisk || { level: '低', percentage: 0 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({
      radius: 8,
      color: 'rgba(255, 182, 193, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  ScoreCard(label: string, score: number, textColor: string, bgColor: string) {
    Column() {
      Text(score.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(textColor)
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('30%')
    .padding(12)
    .backgroundColor(bgColor)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  RiskIndicator(label: string, risk: RiskData) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#555555')
        .layoutWeight(1)

      Row() {
        Stack() {
          Progress({
            value: risk.percentage || 0,
            total: 100,
            type: ProgressType.Linear
          })
          .width(96)
          .height(8)
          .color(this.getRiskColor(risk.level || '低'))
          .backgroundColor('#f1f1f1')
        }
        .width(96)
        .height(8)
        .borderRadius(4)
        .margin({ right: 8 })

        Text(risk.level || '低')
          .fontSize(12)
          .fontColor(this.getRiskColor(risk.level || '低'))
          .width(32)
      }
    }
    .width('100%')
    .height(32)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 12 })
  }

  getRiskColor(level: string): ResourceColor {
    switch (level) {
      case '高':
        return '#f44336'
      case '中':
        return '#ff9800'
      case '低':
      default:
        return '#4caf50'
    }
  }
}

// Data Models
export interface RiskData {
  level?: string
  percentage?: number
}

export interface AnalysisData {
  safetyIndex?: number
  efficacyScore?: number
  activeIngredients?: number
  acneRisk?: RiskData
  irritationRisk?: RiskData
  allergyRisk?: RiskData
}

