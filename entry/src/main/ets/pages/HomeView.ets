import { AISkinColor, CardStyle } from '../design/AISkinTheme'
import { AppHeader } from '../components/common/AppHeader'
import { CoreFeatures } from '../components/home/CoreFeatures'
import { DailyRoutine } from '../components/home/DailyRoutine'
import { PersonalizedRoutineModal } from '../components/home/PersonalizedRoutineModal'
import { PlanApiService, PlanData, PlanStep } from '../components/plan/PlanApiService'
import { ProductApiService } from '../components/product/ProductApiService'
import { SkinAnalysisApiService } from '../services/SkinAnalysisApiService'
import { AuthService } from '../services/AuthService'
import { AIContentNotice } from '../components/common/AIContentNotice'
@Component
export struct HomeView {
  @State plan: PlanData | null = null
  @State loading: boolean = true
  @State error: string = ''
  @State preparing: boolean = false
  @State creating: boolean = false
  @State history: PlanData[] = []
  @State showHistory: boolean = false
  @State detail: PlanData | null = null
  @State adopting: boolean = false
  onProfile?: () => void
  onNavigate?: (route: string, params?: ProductViewParams) => void
  aboutToAppear() { this.load() }
  async load(): Promise<void> {
    this.loading = true
    const response = await PlanApiService.getInstance().getActivePlan()
    this.error = response.success ? '' : response.message || '暂时无法获取护肤方案'
    this.plan = response.data?.plan || null
    this.loading = false
  }
  async prepare(): Promise<void> {
    if (this.preparing) return
    this.preparing = true
    const user = AuthService.getInstance().getCurrentUser()
    const products = await ProductApiService.getInstance().getUserProducts(user?.id || '')
    const skin = await SkinAnalysisApiService.getInstance().getAnalysisHistory(1, 1)
    this.preparing = false
    if (!products.success || !skin.success) {
      this.error = products.message || skin.message || '无法检查准备情况，请重试'
      return
    }
    const needsProducts = !(products.data?.products?.length)
    const needsSkin = !(skin.data?.analyses?.length)
    if (!needsProducts && !needsSkin) { this.creating = true; return }
    AlertDialog.show({
      title: '先准备好这两样' ,
      message: needsProducts && needsSkin ? '添加护肤产品并完成一次肌肤检测后，就能根据你的实际情况制定方案。' : needsProducts ? '先添加护肤产品，就能用你已有的产品制定方案。' : '先完成一次肌肤检测，让方案更贴合你现在的肤况。',
      primaryButton: { value: needsProducts ? '添加护肤品' : '检测肌肤', action: () => { this.onNavigate?.(needsProducts ? '/product' : '/skinstatus') } },
      secondaryButton: { value: needsProducts && needsSkin ? '检测肌肤' : '稍后', action: () => { if (needsProducts && needsSkin) this.onNavigate?.('/skinstatus') } }
    })
  }
  async openHistory(): Promise<void> {
    const response = await PlanApiService.getInstance().getAllPlans()
    if (!response.success) { this.error = response.message || '历史方案加载失败'; return }
    this.history = response.data?.plans || []
    this.showHistory = true
  }
  async adopt(plan: PlanData): Promise<void> {
    if (this.adopting) return
    this.adopting = true
    const response = await PlanApiService.getInstance().adoptPlan(plan._id || plan.id || '')
    this.adopting = false
    if (!response.success) { AlertDialog.show({ title: '采用方案失败', message: response.message || '请稍后重试', primaryButton: { value: '知道了', action: () => {} } }); return }
    this.creating = false; this.showHistory = false; this.detail = null
    await this.load()
  }
  build() {
    Stack() {
      Column() {
        AppHeader({ title: '首页', onProfile: this.onProfile })
        Scroll() {
          Column({ space: 18 }) {
            CoreFeatures({ onNavigate: this.onNavigate, onShowPersonalizedRoutineModal: () => { this.prepare() } })
            if (this.error) { Text(this.error).fontColor(AISkinColor.danger).lineHeight(22) }
            if (this.loading || this.preparing) {
              LoadingProgress().width(40).height(40).color(AISkinColor.accent)
            } else if (this.plan) {
              DailyRoutine({ plan: this.plan, onHistory: () => { this.openHistory() }, onDetails: () => { this.detail = this.plan } })
            } else {
              Column({ space: 16 }) {
                Row() {
                  Text('每日护肤').fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).layoutWeight(1)
                  Button('历史').fontColor(AISkinColor.accent).backgroundColor(Color.Transparent).height(44).onClick(() => { this.openHistory() })
                }
                Text('还没有护肤计划').fontSize(18).fontColor(AISkinColor.text)
                Text('根据护肤柜里的产品和肌肤检测结果，安排早晚护肤。').fontSize(13).lineHeight(21).textAlign(TextAlign.Center).fontColor(AISkinColor.secondary)
                Button(this.error ? '重新加载' : '创建护肤计划').height(48).width('100%').borderRadius(16).backgroundColor(AISkinColor.primary).fontColor(Color.White)
                  .onClick(() => { if (this.error) this.load(); else this.prepare() })
              }.padding(20).width('100%').attributeModifier(new CardStyle())
            }
          }.width('100%').constraintSize({ maxWidth: 600 }).padding({ left: 24, right: 24, top: 16, bottom: 96 })
        }.layoutWeight(1).width('100%').scrollBar(BarState.Off).align(Alignment.Top)
      }.width('100%').height('100%')
      if (this.creating) {
        PersonalizedRoutineModal({ onClose: () => { this.creating = false }, onSaveRoutine: (data: PlanSaveData) => { this.adopt(data.plan) } })
      }
      if (this.showHistory || this.detail) { this.historyPanel() }
    }.width('100%').height('100%')
  }
  @Builder
  historyPanel() {
    Column() {
      AppHeader({ title: this.detail ? '完整护肤方案' : '护肤方案历史', showBackButton: true, onBack: () => { this.detail = null; this.showHistory = false } })
      Scroll() {
        Column({ space: 16 }) {
          if (!this.detail && this.history.length === 0) { Text('暂无历史方案').fontColor(AISkinColor.secondary).padding(40) }
          ForEach(this.detail ? [this.detail] : this.history, (plan: PlanData) => {
            Column({ space: 14 }) {
              AIContentNotice({ scene: '护肤方案' })
              Text(plan.name || '护肤方案').fontSize(20).fontColor(AISkinColor.text)
              Text('早间护理').fontSize(16).fontColor(AISkinColor.accent)
              ForEach(plan.morning || [], (step: PlanStep) => { Text(`${step.step}. ${step.product}\n${step.reason || ''}`).fontSize(14).lineHeight(22).fontColor(AISkinColor.text).width('100%') })
              Text('晚间护理').fontSize(16).fontColor(AISkinColor.accent)
              ForEach(plan.evening || [], (step: PlanStep) => { Text(`${step.step}. ${step.product}\n${step.reason || ''}`).fontSize(14).lineHeight(22).fontColor(AISkinColor.text).width('100%') })
              ForEach(plan.recommendations || [], (tip: string) => { Text(tip).fontSize(14).lineHeight(22).fontColor(AISkinColor.secondary).width('100%') })
              if ((plan._id || plan.id) !== (this.plan?._id || this.plan?.id)) {
                Button('使用此方案').enabled(!this.adopting).onClick(() => { this.adopt(plan) }).backgroundColor(AISkinColor.primary).fontColor(Color.White)
              }
            }.width('100%').padding(20).attributeModifier(new CardStyle())
          })
        }.width('100%').padding(24)
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(AISkinColor.bottom)
  }
}
interface ProductViewParams { autoEnableConflictMode?: boolean }
interface PlanSaveData { planId: string; plan: PlanData }
