import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct AnalysisOverview {
  @Prop analysis: AnalysisData = {
    safetyIndex: 0,
    efficacyScore: 0,
    activeIngredients: 0,
    acneRisk: { level: '未知', percentage: 0 },
    irritationRisk: { level: '未知', percentage: 0 },
    allergyRisk: { level: '未知', percentage: 0 }
  }

  build() {
    Column() {
      Text('安全性分析')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AISkinColor.text)
        .margin({ bottom: 16 })

      // Score Cards
      Row() {
        this.ScoreCard('安全指数', this.analysis.safetyIndex || 0, AISkinColor.success, AISkinColor.successSurface)
        this.ScoreCard('功效评分', this.analysis.efficacyScore || 0, AISkinColor.accent, AISkinColor.selected)
        this.ScoreCard('活性成分', this.analysis.activeIngredients || 0, AISkinColor.accent, AISkinColor.muted)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      // Risk Indicators
      Column() {
        this.RiskIndicator('致痘风险', this.analysis.acneRisk || { level: '未知', percentage: 0 })
        this.RiskIndicator('刺激风险', this.analysis.irritationRisk || { level: '未知', percentage: 0 })
        this.RiskIndicator('过敏风险', this.analysis.allergyRisk || { level: '未知', percentage: 0 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .attributeModifier(new CardStyle())
    .margin({ bottom: 16 })
    .shadow({
      radius: 8,
      color: AISkinColor.shadow,
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  ScoreCard(label: string, score: number, textColor: ResourceColor, bgColor: ResourceColor) {
    Column() {
      Text(score.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(textColor)
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(12)
        .fontColor(AISkinColor.secondary)
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
        .fontColor(AISkinColor.secondary)
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
          .color(this.getRiskColor(risk.level || '未知'))
          .backgroundColor(AISkinColor.muted)
        }
        .width(96)
        .height(8)
        .borderRadius(4)
        .margin({ right: 8 })

        Text(risk.level || '未知')
          .fontSize(12)
          .fontColor(this.getRiskColor(risk.level || '未知'))
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
        return AISkinColor.danger
      case '中':
        return AISkinColor.warning
      case '低':
        return AISkinColor.success
      default:
        return AISkinColor.secondary
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
