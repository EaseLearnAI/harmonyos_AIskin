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
    Column({ space: 16 }) {
      Row() {
        Text('每日护肤').fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).layoutWeight(1)
        Text(this.progress ? `${this.progress.completedCount} / ${this.progress.totalCount}` : '—').fontSize(14).fontColor(AISkinColor.secondary)
        Button() { AISkinIcon({ name: 'history' }) }.width(44).height(44).backgroundColor(AISkinColor.surface).margin({ left: 8 }).onClick(this.onHistory)
      }.width('100%')
      Row({ space: 6 }) {
        this.periodButton('早间','morning')
        this.periodButton('晚间','evening')
      }.width('100%').padding(4).backgroundColor(AISkinColor.selected).borderRadius(24)
      if (this.error) { Text(this.error).fontSize(13).fontColor(AISkinColor.danger).lineHeight(20) }
      ForEach((this.period === 'morning' ? this.plan.morning : this.plan.evening) || [], (step: PlanStep) => {
        Button() {
          Row({ space: 14 }) {
            Text(this.completed(step.step || 0) ? '✓' : '○').fontSize(26).fontColor(AISkinColor.accent).width(28)
            Column({ space: 6 }) {
              Text(step.product || '护肤步骤').fontSize(16).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
              Text(step.reason || '').fontSize(13).lineHeight(21).fontColor(AISkinColor.secondary)
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            Text(String(step.step || 0).padStart(2,'0')).fontSize(12).fontColor(AISkinColor.secondary)
          }.width('100%').padding({ top: 12, bottom: 12 })
        }.type(ButtonType.Normal).backgroundColor(Color.Transparent).width('100%').enabled(!this.saving && this.progress !== null)
          .accessibilityText(`${step.product} ${this.completed(step.step || 0) ? '已完成' : '未完成'}`)
          .onClick(() => { this.toggle(step.step || 0) })
      })
      Divider().color(AISkinColor.divider)
      Button('查看完整护肤方案  →').width('100%').height(44).backgroundColor(Color.Transparent)
        .fontColor(AISkinColor.accent).onClick(this.onDetails)
    }.width('100%').padding(20).attributeModifier(new CardStyle())
  }
  @Builder
  periodButton(title: string, value: string) {
    Button(title).layoutWeight(1).height(40).fontColor(this.period === value ? AISkinColor.text : AISkinColor.secondary)
      .backgroundColor(this.period === value ? AISkinColor.elevated : Color.Transparent).borderRadius(20)
      .onClick(() => { this.period = value })
  }
}
