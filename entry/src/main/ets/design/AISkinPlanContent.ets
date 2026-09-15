import { PlanData, PlanStep } from '../components/plan/PlanApiService'
import { AISkinColor, TextStyle, CardStyle } from './AISkinTheme'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinCardRole, AISkinCardState, AISkinCardInset } from './Foundation/AISkinTokens'
import { AIContentNotice } from '../components/common/AIContentNotice'
@Component
export struct AISkinPlanContent {
  @Prop plan: PlanData = {}
  build() {
    Column({ space: AISkinSpacing.sectionGap }) {
      AIContentNotice({ scene: '护肤方案' })
      Text(this.plan.name || '个性化护肤方案').attributeModifier(new TextStyle(AISkinTextRole.ScreenTitle))
      this.period('早间护理', this.plan.morning || [])
      this.period('晚间护理', this.plan.evening || [])
      Text('护理建议').attributeModifier(new TextStyle(AISkinTextRole.CardTitle))
      ForEach(this.plan.recommendations || [], (tip: string) => { Text(tip).attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary)).width('100%') })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
  @Builder
  period(title: string, steps: PlanStep[]) {
    Column({ space: AISkinSpacing.small }) {
      Text(title).attributeModifier(new TextStyle(AISkinTextRole.CardTitle))
      ForEach(steps, (step: PlanStep, index: number) => {
        Column({ space: AISkinSpacing.xSmall }) {
          Text(`${index + 1}. ${step.product || '护肤步骤'}`).attributeModifier(new TextStyle(AISkinTextRole.ProductTitle))
          Text(step.reason || '该步骤未提供说明').attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary))
        }.width('100%').alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
      })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
