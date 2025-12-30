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
          Text(this.plan.name || '个性化护肤方案')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 8 })

          Text(this.plan.requirement || '日常基础护肤')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .padding({ bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#F0F0F0',
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
          Button('保存到我的方案')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#F8BBD0')
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
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
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
          color: '#F0F0F0',
          style: BorderStyle.Solid
        })
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(20)
    }
  }

  @Builder
  RoutineSection(title: string, steps: PlanStep[]) {
    Column() {
      Row() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#444444')
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
                .backgroundColor('#F8BBD0')
                .margin({ right: 12 })

              Text(step.product || '')
                .fontSize(15)
                .fontColor('#333333')
                .layoutWeight(1)
            }
            .width('100%')
            
            if (step.reason) {
              Text(step.reason)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4, left: 36 })
                .width('100%')
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F9FAFB')
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
        Text('专业建议')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#444444')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(recommendations, (tip: string, index: number) => {
          Row() {
            Text('✓')
              .fontSize(16)
              .fontColor('#F8BBD0')
              .margin({ right: 10 })

            Text(tip)
              .fontSize(14)
              .fontColor('#555555')
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


