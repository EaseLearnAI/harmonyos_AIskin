import { SkinStatusView } from './SkinStatusView'
import { AISkinPlanContent } from '../design/AISkinPlanContent'
import { AISkinButton, AISkinStateView } from '../design/AISkinPrimitives'
import { Modal, AISkinModalPresentation } from '../components/common/Modal'
import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinStateKind, AISkinButtonVariant, AISkinButtonLayout, AISkinCardRole, AISkinCardState, AISkinCardInset } from '../design/Foundation/AISkinTokens'
import { AISkinBackground, AISkinColor, CardStyle, TextStyle } from '../design/AISkinTheme'
import { AppHeader } from '../components/common/AppHeader'
import { CoreFeatures } from '../components/home/CoreFeatures'
import { DailyRoutine } from '../components/home/DailyRoutine'
import { PersonalizedRoutineModal } from '../components/home/PersonalizedRoutineModal'
import { PlanApiService, PlanData, PlanStep } from '../components/plan/PlanApiService'
import { ProductApiService } from '../components/product/ProductApiService'
import { SkinAnalysisApiService, SkinAnalysisData } from '../services/SkinAnalysisApiService'
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
  @State sourceReport: SkinAnalysisData | null = null
  @State showSourceFlow: boolean = false
  @State sourceRevision: number = 0
  private sourceBack: (() => boolean) | undefined = undefined
  private planBack: (() => boolean) | undefined = undefined
  registerBackHandler?: (handler: () => boolean) => void
  private generation: number = 0
  private loadGeneration: number = 0
  onProfile?: () => void
  onNavigate?: (route: string, params?: ProductViewParams) => void
  @Prop openPlan: boolean = false
  onConsumeOpenPlan?: () => void
  onOverlay?: (value: boolean) => void
  aboutToAppear() {
    this.registerBackHandler?.(() => this.handleBack())
    this.load()
    if (this.openPlan) {
      this.onConsumeOpenPlan?.()
      this.prepare()
    }
  }
  aboutToDisappear() { this.generation++; this.loadGeneration++; this.registerBackHandler?.(() => false); this.onOverlay?.(false) }
  private handleBack(): boolean {
    if (this.showSourceFlow) { if (this.sourceBack?.()) return true; this.closeSource(); return true }
    if (this.adopting) return true
    if (this.creating && this.planBack?.()) return true
    if (this.creating) { this.creating = false; this.onOverlay?.(false); return true }
    if (this.detail || this.showHistory) { this.closeHistory(); return true }
    if (this.preparing) { this.generation++; this.preparing = false; return true }
    return false
  }
  async load(): Promise<void> {
    const request = ++this.loadGeneration
    this.loading = true
    this.error = ''
    try {
      const response = await PlanApiService.getInstance().getActivePlan()
      if (request !== this.loadGeneration) return
      if (!response.success || !response.data) {
        this.error = response.message || '暂时无法获取护肤方案'
        return
      }
      this.plan = response.data.plan || null
    } catch (error) {
      if (request === this.loadGeneration) this.error = '护肤方案加载失败，请检查网络后重试'
    } finally {
      if (request === this.loadGeneration) this.loading = false
    }
  }
  async prepare(): Promise<void> {
    if (this.preparing) return
    this.preparing = true
    const request = ++this.generation
    const user = AuthService.getInstance().getCurrentUser()
    const products = await ProductApiService.getInstance().getUserProducts(user?.id || '')
    const skin = await SkinAnalysisApiService.getInstance().getAnalysisHistory(1, 1)
    if (request !== this.generation) return
    this.preparing = false
    if (!products.success || !skin.success) {
      this.error = products.message || skin.message || '无法检查准备情况，请重试'
      return
    }
    const needsProducts = !(products.data?.products?.length)
    const needsSkin = !(skin.data?.analyses?.length)
    if (!needsProducts && !needsSkin) { this.creating = true; this.onOverlay?.(true); return }
    AlertDialog.show({
      title: '先准备好这两样' ,
      message: needsProducts && needsSkin ? '添加护肤产品并完成一次肌肤检测后，就能根据你的实际情况制定方案。' : needsProducts ? '先添加护肤产品，就能用你已有的产品制定方案。' : '先完成一次肌肤检测，让方案更贴合你现在的肤况。',
      primaryButton: { value: needsProducts ? '添加护肤品' : '检测肌肤', action: () => { this.onNavigate?.(needsProducts ? '/product' : '/skinstatus') } },
      secondaryButton: { value: needsProducts && needsSkin ? '检测肌肤' : '稍后', action: () => { if (needsProducts && needsSkin) this.onNavigate?.('/skinstatus') } }
    })
  }
  private closeSource(): void { this.sourceReport = null; this.showSourceFlow = false; this.sourceRevision++ }
  private closeHistory(): void { if (this.adopting) return; this.detail = null; this.showHistory = false; this.onOverlay?.(false) }
  async openHistory(): Promise<void> {
    const request = this.generation
    const response = await PlanApiService.getInstance().getAllPlans()
    if (request !== this.generation) return
    if (!response.success) { this.error = response.message || '历史方案加载失败'; return }
    this.history = response.data?.plans || []
    this.showHistory = true; this.onOverlay?.(true)
  }
  async adopt(plan: PlanData): Promise<void> {
    if (this.adopting) return
    this.adopting = true
    const request = this.generation
    const response = await PlanApiService.getInstance().adoptPlan(plan._id || plan.id || '')
    if (request !== this.generation) return
    this.adopting = false
    if (!response.success) { AlertDialog.show({ title: '采用方案失败', message: response.message || '请稍后重试', primaryButton: { value: '知道了', action: () => {} } }); return }
    this.creating = false; this.onOverlay?.(false); this.showHistory = false; this.detail = null
    await this.load()
  }
  build() {
    Stack() {
      if (!this.creating && !this.showSourceFlow) {
      Column() {
        AppHeader({ title: '首页', onProfile: this.onProfile })
        Scroll() {
          Column({ space: AISkinSpacing.sectionGap }) {
            CoreFeatures({ onNavigate: this.onNavigate, onShowPersonalizedRoutineModal: () => { this.prepare() } })
            if (this.error) { AISkinStateView({ title: '暂时无法完成', message: this.error, kind: AISkinStateKind.Error, onRetry: () => { this.load() } }) }
            if (this.loading || this.preparing) { AISkinStateView({ title: '正在获取护肤方案', kind: AISkinStateKind.Loading }) }
            else if (this.plan) { DailyRoutine({ plan: this.plan, onHistory: () => { this.openHistory() }, onDetails: () => { this.detail = this.plan; this.onOverlay?.(true) } }) }
            else if (!this.error) {
              Column({ space: AISkinSpacing.small }) {
                Row() { Text('每日护肤').attributeModifier(new TextStyle(AISkinTextRole.HomeHeading)).layoutWeight(1); AISkinButton({ title: '历史', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: () => { this.openHistory() } }) }.width('100%')
                AISkinStateView({ title: '还没有护肤计划', message: '根据护肤柜里的产品和肌肤检测结果，安排早晚护肤。' })
                AISkinButton({ title: '创建护肤计划', onAction: () => { this.prepare() } })
              }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content,AISkinCardState.Normal,AISkinCardInset.Regular))
            }
          }.width('100%').constraintSize({ maxWidth: AISkinLayout.maxWidth }).padding({ left: AISkinSpacing.screenEdge,right: AISkinSpacing.screenEdge,top: AISkinSpacing.medium,bottom: AISkinLayout.bottomClearance })
        }.layoutWeight(1).width('100%').scrollBar(BarState.Off).align(Alignment.Top)
      }.width('100%').height('100%')
      }
      if (this.creating) { PersonalizedRoutineModal({ isAdopting: this.adopting, sourceRevision: this.sourceRevision, registerBackHandler: (handler: () => boolean) => { this.planBack = handler }, onViewSkinSource: (record: SkinAnalysisData | null) => { this.sourceReport = record; this.showSourceFlow = true }, onClose: () => { this.creating = false; this.onOverlay?.(false) }, onSaveRoutine: (data: PlanSaveData) => { this.adopt(data.plan) } }).visibility(this.showSourceFlow ? Visibility.Hidden : Visibility.Visible) }
      Modal({ show: this.showHistory || this.detail !== null, title: this.detail ? '当前护肤方案' : '护肤方案历史', isBusy: this.adopting, presentation: AISkinModalPresentation.Reading,
        onClose: () => { this.closeHistory() }, content: () => { this.historyContent() } })
      if (this.showSourceFlow) {
        Stack() {
          AISkinBackground()
          SkinStatusView({ initialReport: this.sourceReport, presentedAsSource: true, registerBackHandler: (handler: () => boolean) => { this.sourceBack = handler }, onBack: () => { this.closeSource() }, onCreatePlan: () => { this.closeSource() } })
        }.width('100%').height('100%')
      }
    }.width('100%').height('100%')
  }
  @Builder
  historyContent() {
    Column({ space: AISkinSpacing.medium }) {
      if (!this.detail && !this.history.length) { AISkinStateView({ title: '暂无历史方案' }) }
      ForEach(this.detail ? [this.detail] : this.history, (plan: PlanData) => {
        AISkinPlanContent({ plan: plan })
        if ((plan._id || plan.id) !== (this.plan?._id || this.plan?.id)) {
          AISkinButton({ title: '使用此方案', isLoading: this.adopting, onAction: () => { this.adopt(plan) } })
        }
      })
    }.width('100%').padding(AISkinSpacing.screenEdge)
  }
}
interface ProductViewParams { autoEnableConflictMode?: boolean }
interface PlanSaveData { planId: string; plan: PlanData }
