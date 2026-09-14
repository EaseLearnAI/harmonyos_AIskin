import { AIContentNotice } from '../common/AIContentNotice'
import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { PlanData, PlanStep } from '../plan/PlanApiService'

@Component
export struct PersonalizedRoutinePreview {
  @Prop plan: PlanData | null = null
  onSaveRoutine?: () => void
  onCustomizeRoutine?: () => void

  build() {
    if (this.plan) {
      Column() {
        // Preview Header
        Column() {
          AIContentNotice({ scene: '护肤方案' })

          Text(this.plan.name || '个性化护肤方案')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 8 })

          Text(this.plan.requirement || '日常基础护肤')
            .fontSize(14)
            .fontColor(AISkinColor.secondary)
        }
        .width('100%')
        .padding({ bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: AISkinColor.muted,
          style: BorderStyle.Solid
        })

        // Preview Content
        Scroll() {
          Column() {
            // Morning Routine
            this.RoutineSection('早间护理', this.plan.morning || [])

            // Evening Routine
            this.RoutineSection('晚间护理', this.plan.evening || [])

            // Recommendations
            if (this.plan.recommendations && this.plan.recommendations.length > 0) {
              this.RecommendationsSection(this.plan.recommendations)
            }
          }
          .width('100%')
          .padding({ top: 20 })
        }
        .layoutWeight(1)

        // Actions
        Row() {
          Button('使用此方案')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AISkinColor.primary)
            .fontColor(Color.White)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(10)
            .onClick(() => {
              if (this.onSaveRoutine) {
                this.onSaveRoutine()
              }
            })

          Button('重新定制')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AISkinColor.muted)
            .fontColor(AISkinColor.secondary)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(10)
            .margin({ left: 12 })
            .onClick(() => {
              if (this.onCustomizeRoutine) {
                this.onCustomizeRoutine()
              }
            })
        }
        .width('100%')
        .margin({ top: 24 })
        .padding({ top: 24 })
        .border({
          width: { top: 1 },
          color: AISkinColor.muted,
          style: BorderStyle.Solid
        })
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .attributeModifier(new CardStyle())
    }
  }

  @Builder
  RoutineSection(title: string, steps: PlanStep[]) {
    Column() {
      Row() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(steps, (step: PlanStep, index: number) => {
          Column() {
            Row() {
              Text((step.step || (index + 1)).toString())
                .width(24)
                .height(24)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
                .borderRadius(12)
                .backgroundColor(AISkinColor.primary)
                .margin({ right: 12 })

              Text(step.product || '')
                .fontSize(15)
                .fontColor(AISkinColor.text)
                .layoutWeight(1)
            }
            .width('100%')
            
            if (step.reason) {
              Text(step.reason)
                .fontSize(12)
                .fontColor(AISkinColor.secondary)
                .margin({ top: 4, left: 36 })
                .width('100%')
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor(AISkinColor.muted)
          .borderRadius(12)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  RecommendationsSection(recommendations: string[]) {
    Column() {
      Row() {
        Text('AI生成建议')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(recommendations, (tip: string, index: number) => {
          Row() {
            Text('✓')
              .fontSize(16)
              .fontColor(AISkinColor.accent)
              .margin({ right: 10 })

            Text(tip)
              .fontSize(14)
              .fontColor(AISkinColor.secondary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
  }
}

