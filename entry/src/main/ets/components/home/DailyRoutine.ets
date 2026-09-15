import { AISkinButton, AISkinTabs, AISkinStateView } from '../../design/AISkinPrimitives'
import { AISkinChecklistRow } from '../../design/AISkinJourneyComponents'
import { AISkinTextRole, AISkinTone, AISkinSpacing, AISkinButtonVariant, AISkinButtonLayout, AISkinTabVariant, AISkinStateKind, AISkinCardRole, AISkinCardState, AISkinCardInset } from '../../design/Foundation/AISkinTokens'
import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'
import { PlanApiService, PlanData, PlanStep, DailyProgress } from '../plan/PlanApiService'
@Component
export struct DailyRoutine {
  @Prop @Watch('load') plan: PlanData = {}
  @State period: string = 'morning'
  @State progress: DailyProgress | null = null
  @State saving: boolean = false
  @State error: string = ''
  onDetails: () => void = () => {}
  onHistory: () => void = () => {}
  aboutToAppear() { this.load() }
  private planId(): string { return this.plan._id || this.plan.id || '' }
  async load(): Promise<void> {
    const result = await PlanApiService.getInstance().getDailyProgress(this.planId())
    this.progress = result.data?.daily || null
    this.error = result.success ? '' : result.message || '暂时无法读取今日记录'
  }
  private completed(step: number): boolean {
    const steps = this.period === 'morning' ? this.progress?.morning : this.progress?.evening
    return steps?.find(item => item.step === step)?.completed === true
  }
  async toggle(step: number): Promise<void> {
    if (this.saving) return
    const now = new Date()
    const today = `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`
    if (this.progress?.date !== today) { await this.load(); return }
    this.saving = true
    const result = await PlanApiService.getInstance().completeDailyStep(this.planId(), this.period, step, !this.completed(step))
    if (result.success && result.data) { this.progress = result.data.daily; this.error = '' }
    else { this.error = result.message || '保存失败，请重试' }
    this.saving = false
  }
  build() {
    Column({ space: AISkinSpacing.small }) {
      Row() {
        AISkinButton({ title: '每日护肤', textRole: AISkinTextRole.HomeHeading, tone: AISkinTone.Primary, variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: this.onDetails })
        Blank()
        AISkinButton({ title: '历史', icon: 'history', textRole: AISkinTextRole.Caption, variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: this.onHistory })
      }.width('100%')
      AISkinTabs({ items: ['早间','晚间'], icons: ['sun','moon'], selection: this.period === 'morning' ? 0 : 1, variant: AISkinTabVariant.Segmented, onSelect: (index: number) => { this.period = index === 0 ? 'morning' : 'evening' } })
      if (this.error) { AISkinStateView({ title: '保存未成功', message: this.error, kind: AISkinStateKind.Error, onRetry: () => { this.load() } }) }
      Column() {
      ForEach((this.period === 'morning' ? this.plan.morning : this.plan.evening) || [], (step: PlanStep, index: number) => {
        AISkinChecklistRow({ title: step.product || '护肤步骤', message: step.reason || '', number: index + 1,
          isCompleted: this.completed(step.step || 0), isEnabled: !this.saving && this.progress !== null, onAction: () => { this.toggle(step.step || 0) } })
        if (index < (((this.period === 'morning' ? this.plan.morning : this.plan.evening) || []).length - 1)) { Divider().color(AISkinColor.divider) }
      })
      }.width('100%')
      if (!((this.period === 'morning' ? this.plan.morning : this.plan.evening)?.length)) {
        AISkinStateView({ title: '暂无护理步骤', message: '可以在完整护肤方案中查看安排。' })
      }
    }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Routine, AISkinCardState.Normal, AISkinCardInset.Regular))
  }
}
