import { AISkinPlanContent } from '../../design/AISkinPlanContent'
import { AISkinButton } from '../../design/AISkinPrimitives'
import { AISkinSpacing, AISkinButtonVariant } from '../../design/Foundation/AISkinTokens'
import { PlanData } from '../plan/PlanApiService'
@Component
export struct PersonalizedRoutinePreview {
  @Prop plan: PlanData | null = null
  @Prop isSaving: boolean = false
  onSaveRoutine?: () => void
  onCustomizeRoutine?: () => void
  build() {
    if (this.plan) {
      Column({ space: AISkinSpacing.medium }) {
        Scroll() { AISkinPlanContent({ plan: this.plan }) }.width('100%').layoutWeight(1).align(Alignment.Top)
        Row({ space: AISkinSpacing.small }) {
          AISkinButton({ title: '采用这份方案', isLoading: this.isSaving, isEnabled: !this.isSaving, onAction: () => { if (!this.isSaving) this.onSaveRoutine?.() } }).layoutWeight(1)
          AISkinButton({ title: '重新定制', variant: AISkinButtonVariant.Secondary, isEnabled: !this.isSaving, onAction: () => { if (!this.isSaving) this.onCustomizeRoutine?.() } }).layoutWeight(1)
        }.width('100%')
      }.width('100%').height('100%').padding(AISkinSpacing.screenEdge)
    }
  }
}
