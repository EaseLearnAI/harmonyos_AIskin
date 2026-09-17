import { AISkinBackground, TextStyle } from '../../design/AISkinTheme'
import { AISkinHeader, AISkinButton, AISkinField, AISkinStateView } from '../../design/AISkinPrimitives'
import { AISkinProcessingScreen } from '../../design/AISkinProcessingScreen'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinStateKind, AISkinFieldVariant } from '../../design/Foundation/AISkinTokens'
import { AuthService } from '../../services/AuthService'
import { SkinAnalysisApiService, SkinAnalysisData } from '../../services/SkinAnalysisApiService'
import { AISkinReportScreen, AISkinReportFooter } from '../../design/AISkinReportComponents'
import { AISkinPlanSourceRow, AISkinPlanGoals, AISkinPlanRequirements, AISkinPlanPersonalStates, PlanConcernOption } from '../../design/AISkinPlanInputComponents'
import { Modal } from '../common/Modal'
import { PersonalizedRoutinePreview } from './PersonalizedRoutinePreview'
import { PlanApiService, PlanData, CreatePlanRequest } from '../plan/PlanApiService'
@Component
export struct PersonalizedRoutineModal {
  @Prop isAdopting: boolean = false
  @Prop @Watch('refreshSource') sourceRevision: number = 0
  @State latestSkinAnalysis: SkinAnalysisData | null = null
  @State sourceLoading: boolean = false
  @State sourceError: string = ''
  @State showPersonalDetails: boolean = false
  @State isInCycle: boolean = false
  @State cycleDay: string = '1'
  @State showsAgeEditor: boolean = false
  @State ageDraft: string = ''
  @State ageError: string = ''
  @State checkingSource: boolean = false
  registerBackHandler?: (handler: () => boolean) => void
  onViewSkinSource?: (record: SkinAnalysisData | null) => void
  private sourceGeneration: number = 0
  @State loadingPlan: boolean = false
  @State savingAge: boolean = false
  @State operationPending: boolean = false
  @State planError: string = ''
  @State cancellationNotice: string = ''
  @State generatedPlan: PlanData | null = null
  @State selectedConcerns: string[] = []
  @State userAge: string = ''
  @State customRequirements: string = ''
  private requestGeneration: number = 0
  private isDestroyed: boolean = false
  private authService: AuthService = AuthService.getInstance()
  onClose?: () => void
  onSaveRoutine?: (data: PlanSaveData) => void
  private concerns: PlanConcernOption[] = [{label:'补水',value:'hydration'},{label:'修护',value:'repair'},{label:'控油',value:'oil-control'},{label:'抗老',value:'anti-aging'},{label:'提亮',value:'brightening'},{label:'祛痘',value:'acne'}]
  aboutToAppear(): void {
    this.isDestroyed = false
    const age = this.authService.getCurrentUser()?.age
    this.userAge = age !== undefined ? String(age) : ''
    this.showPersonalDetails = age === undefined
    this.registerBackHandler?.(() => this.handleNestedBack())
    this.refreshSource()
  }
  aboutToDisappear(): void {
    this.isDestroyed = true; this.requestGeneration++; this.sourceGeneration++
    this.registerBackHandler?.(() => false)
  }
  private async refreshSource(): Promise<void> {
    if (this.isDestroyed) return
    const generation = ++this.sourceGeneration
    const token = this.authService.getToken()
    this.sourceLoading = true
    this.sourceError = ''
    try {
      const response = await SkinAnalysisApiService.getInstance().getAnalysisHistory(1, 1)
      if (this.isDestroyed || generation !== this.sourceGeneration || this.authService.getToken() !== token) return
      if (response.success) this.latestSkinAnalysis = response.data?.analyses?.[0] || null
      else { this.latestSkinAnalysis = null; this.sourceError = response.message || '最近检测读取失败，请重试' }
    } catch (error) {
      if (!this.isDestroyed && generation === this.sourceGeneration) { this.latestSkinAnalysis = null; this.sourceError = '最近检测读取失败，请检查网络后重试' }
    } finally { if (!this.isDestroyed && generation === this.sourceGeneration) this.sourceLoading = false }
  }
  private sourceDetail(): string {
    const source = this.latestSkinAnalysis
    if (!source) return '完成肌肤检测后，为你定制更合适的护肤步骤。'
    let skinType = source.skinType?.type || ''
    if (!skinType) skinType = '肤质未提供'
    const date = source.createdAt ? new Date(source.createdAt) : null
    const dateText = date && !Number.isNaN(date.getTime()) ? `${date.getFullYear()}年${date.getMonth()+1}月${date.getDate()}日` : '日期未提供'
    return `${skinType} · ${dateText}`
  }
  private viewSource(): void {
    if (this.operationPending || this.sourceLoading || this.isAdopting) return
    if (this.onViewSkinSource) this.onViewSkinSource(this.latestSkinAnalysis)
    else this.planError = '暂时无法打开检测记录，请稍后重试'
  }
  private toggleConcern(value: string): void {
    if (this.operationPending || this.isAdopting) return
    this.selectedConcerns = this.selectedConcerns.includes(value) ? this.selectedConcerns.filter(item => item !== value) : this.selectedConcerns.length < 3 ? this.selectedConcerns.concat([value]) : this.selectedConcerns
    this.planError = ''
  }
  private handleNestedBack(): boolean {
    if (this.isAdopting || (this.showsAgeEditor && this.savingAge)) return true
    if (this.showsAgeEditor) { this.showsAgeEditor = false; return true }
    if (this.loadingPlan) { this.cancelGeneration(); return true }
    if (this.generatedPlan) { this.generatedPlan = null; return true }
    return false
  }
  private editAge(): void {
    if (this.operationPending || this.isAdopting) return
    this.ageDraft = this.userAge; this.ageError = ''; this.showsAgeEditor = true
  }
  private validDraftAge(): boolean { return /^\d+$/.test(this.ageDraft) && Number(this.ageDraft) >= 13 && Number(this.ageDraft) <= 120 }
  private async saveEditedAge(): Promise<void> {
    if (!this.validDraftAge() || this.operationPending || this.isAdopting) return
    const token = this.authService.getToken()
    const ownerID = this.authService.getCurrentUser()?.id
    if (!token || !ownerID) { this.ageError = '请重新登录后保存年龄'; return }
    const generation = ++this.requestGeneration
    const age = Number(this.ageDraft)
    this.savingAge = true; this.operationPending = true; this.ageError = ''
    try {
      const response = await this.authService.updateAge(age)
      if (!this.isCurrent(generation)) return
      if (this.authService.getToken() !== token || this.authService.getCurrentUser()?.id !== ownerID) {
        this.ageError = '登录状态已变化，请重新登录后保存年龄'; return
      }
      if (response.success && response.user?.age === age && response.user?.id === ownerID) {
        this.userAge = String(response.user.age); this.showsAgeEditor = false; this.planError = ''
      } else this.ageError = response.message || '年龄未保存成功，请重试'
    } catch (error) { if (this.isCurrent(generation)) this.ageError = '年龄保存失败，请检查网络后重试' }
    finally { if (!this.isDestroyed) { this.operationPending = false; this.savingAge = false } }
  }
  private validAge(): boolean {
    return /^\d+$/.test(this.userAge) && Number(this.userAge) >= 13 && Number(this.userAge) <= 120
  }
  private isCurrent(generation: number): boolean { return !this.isDestroyed && generation === this.requestGeneration }
  private cancelGeneration(): void {
    if (this.isAdopting) return
    this.requestGeneration++
    this.loadingPlan = false
    this.savingAge = false
    this.checkingSource = false
    this.planError = ''
    this.cancellationNotice = this.operationPending ? '已取消等待，上一次操作结束后可以重新尝试。' : '已取消等待。'
  }
  private close(): void {
    if (this.handleNestedBack()) return
    this.requestGeneration++
    this.onClose?.()
  }
  async generate(): Promise<void> {
    // Keep the lock until the outstanding request settles, including after Cancel.
    // Cancelling the UI cannot undo an age update already accepted by the server.
    if (this.operationPending || this.sourceLoading || this.isAdopting) return
    if (!this.validAge()) { this.showPersonalDetails = true; this.planError = '请在「其他个人状态」中填写13–120的年龄'; return }
    if (this.selectedConcerns.length === 0 || this.selectedConcerns.length > 3) {
      this.planError = '请选择1–3项护肤目标'; return
    }
    if (this.isInCycle && (!/^\d+$/.test(this.cycleDay) || Number(this.cycleDay) < 1 || Number(this.cycleDay) > 7)) {
      this.showPersonalDetails = true; this.planError = '请输入1–7的周期天数'; return
    }
    const token = this.authService.getToken()
    const user = this.authService.getCurrentUser()
    if (!token || !user?.id) { this.planError = '请重新登录后再生成方案'; return }
    const age = Number(this.userAge)
    const concerns = this.selectedConcerns.slice()
    let notes = this.customRequirements.trim()
    if (this.isInCycle) notes += (notes ? '\n' : '') + `补充个人状态：当前处于生理周期第${Number(this.cycleDay)}天。`
    const labels = this.concerns.filter(item => concerns.includes(item.value)).map(item => item.label)
    const generation = ++this.requestGeneration
    this.planError = ''
    this.cancellationNotice = ''
    this.loadingPlan = true
    this.operationPending = true
    this.savingAge = user.age !== age
    try {
      this.checkingSource = true
      const latest = await SkinAnalysisApiService.getInstance().getAnalysisHistory(1, 1)
      if (!this.isCurrent(generation)) return
      if (this.authService.getToken() !== token || this.authService.getCurrentUser()?.id !== user.id) {
        this.planError = '登录状态已变化，请重新登录后再生成方案'; return
      }
      if (!latest.success) { this.planError = latest.message || '暂时无法读取最近检测，请重试'; return }
      this.latestSkinAnalysis = latest.data?.analyses?.[0] || null
      this.sourceError = ''
      if (!this.latestSkinAnalysis) { this.planError = '请先完成肌肤检测，再生成护肤方案'; return }
      this.checkingSource = false
      if (this.savingAge) {
        const saved = await this.authService.updateAge(age)
        if (!this.isCurrent(generation)) return
        const savedUser = saved.user
        if (!saved.success || !savedUser || savedUser.age !== age || savedUser.id !== user.id) {
          this.planError = saved.message || '年龄未保存成功，请重试'
          return
        }
        this.userAge = String(savedUser.age)
      }
      if (!this.isCurrent(generation)) return
      if (this.authService.getToken() !== token || this.authService.getCurrentUser()?.id !== user.id) {
        this.planError = '登录状态已变化，请重新登录后再生成方案'
        return
      }
      this.savingAge = false
      const request: CreatePlanRequest = { age: age, skinConcerns: concerns, customRequirements: notes, requirement: labels.join('、') }
      const result = await PlanApiService.getInstance().createPlan(request)
      if (!this.isCurrent(generation)) return
      if (this.authService.getToken() !== token || this.authService.getCurrentUser()?.id !== user.id) {
        this.planError = '登录状态已变化，请重新登录后再生成方案'; return
      }
      if (result.success && result.data?.plan) this.generatedPlan = result.data.plan
      else this.planError = result.message || '未能生成可用方案，请重试'
    } catch (error) {
      if (this.isCurrent(generation)) this.planError = this.checkingSource ? '最近检测读取失败，请检查网络后重试' : this.savingAge ? '年龄保存失败，请检查网络后重试' : '生成失败，请检查网络后重试'
    } finally {
      if (!this.isDestroyed) {
        this.operationPending = false
        if (generation !== this.requestGeneration && this.cancellationNotice) this.cancellationNotice = '已取消等待。'
        if (this.isCurrent(generation)) { this.loadingPlan = false; this.savingAge = false; this.checkingSource = false }
      }
    }
  }
  @Builder
  formHeader() {
    AISkinHeader({ title: this.generatedPlan ? '方案预览' : '定制方案', leftIcon: 'back', onLeft: (): void => { this.close() } }).enabled(!this.isAdopting)
  }
  @Builder
  formContent() {
    if (this.generatedPlan) {
      PersonalizedRoutinePreview({ plan: this.generatedPlan, isSaving: this.isAdopting,
        onCustomizeRoutine: () => { if (!this.isAdopting) this.generatedPlan = null },
        onSaveRoutine: () => { if (this.generatedPlan && !this.isAdopting) this.onSaveRoutine?.({ planId: this.generatedPlan._id || this.generatedPlan.id || '', plan: this.generatedPlan }) } })
    } else {
      Scroll() {
        Column({ space: AISkinSpacing.xLarge }) {
          Text('根据护肤柜中已有的产品，结合肌肤检测结果与护肤目标，为你安排早晚使用顺序和步骤。\n请先将正在使用的产品添加到护肤柜。')
            .attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
          if (this.planError) { AISkinStateView({ title: '暂时无法生成方案', message: this.planError, kind: AISkinStateKind.Error }) }
          AISkinPlanSourceRow({ title: this.sourceLoading ? '正在读取最近检测' : this.latestSkinAnalysis ? '已关联最近检测' : '先了解你的肌肤',
            detail: this.sourceDetail(), actionTitle: this.latestSkinAnalysis ? '查看' : '去检测',
            isEnabled: !this.sourceLoading && !this.operationPending && !this.isAdopting, onAction: (): void => { this.viewSource() } })
          if (this.sourceError) { AISkinStateView({ title: '最近检测读取失败', message: this.sourceError, kind: AISkinStateKind.Error, onRetry: (): void => { this.refreshSource() } }) }
          AISkinPlanGoals({ options: this.concerns, selection: this.selectedConcerns, isEnabled: !this.operationPending && !this.isAdopting,
            onToggle: (value: string): void => { this.toggleConcern(value) } })
          AISkinPlanRequirements({ value: this.customRequirements, isEnabled: !this.operationPending && !this.isAdopting,
            onChange: (value: string) => { this.customRequirements = value.slice(0, 300) } })
          AISkinPlanPersonalStates({ age: this.validAge() ? Number(this.userAge) : 0, isExpanded: this.showPersonalDetails,
            isInCycle: this.isInCycle, cycleDay: this.cycleDay, isEnabled: !this.operationPending && !this.isAdopting,
            onToggleExpanded: () => { this.showPersonalDetails = !this.showPersonalDetails }, onEditAge: (): void => { this.editAge() },
            onCycleChange: (value: boolean) => { this.isInCycle = value }, onCycleDayChange: (value: string) => { this.cycleDay = value } })
          if (this.cancellationNotice) { Text(this.cancellationNotice).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary)) }
        }.width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, top: AISkinSpacing.medium, bottom: AISkinSpacing.xLarge })
          .alignItems(HorizontalAlign.Start)
      }.width('100%').height('100%').align(Alignment.Top).scrollBar(BarState.Off)
    }
  }
  @Builder
  generateButton() {
    AISkinButton({ title: '生成我的方案', isEnabled: !this.operationPending && !this.sourceLoading && !this.isAdopting,
      isLoading: this.operationPending, onAction: (): void => { this.generate() } })
  }
  @Builder
  formFooter() {
    if (!this.generatedPlan) { AISkinReportFooter({ content: () => { this.generateButton() } }) }
  }
  @Builder
  ageEditorContent() {
    Column({ space: AISkinSpacing.small }) {
      Text('保存后将用于定制护肤方案，也可在个人信息中修改。').attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary))
      AISkinField({ value: this.ageDraft, placeholder: '请输入年龄', trailingText: '岁', inputType: InputType.Number, variant: AISkinFieldVariant.Form,
        isLoading: this.savingAge, error: this.ageError, onChange: (value: string) => { this.ageDraft = value; this.ageError = '' } })
      if (this.ageDraft && !this.validDraftAge()) { AISkinStateView({ title: '请检查年龄', message: '请输入13–120的整数。', kind: AISkinStateKind.Error }) }
    }.width('100%').padding(AISkinSpacing.cardPadding).alignItems(HorizontalAlign.Start)
  }
  @Builder
  ageEditorFooter() {
    AISkinButton({ title: '保存', isLoading: this.savingAge, isEnabled: this.validDraftAge(), onAction: (): void => { this.saveEditedAge() } })
      .padding({ left: AISkinSpacing.cardPadding, right: AISkinSpacing.cardPadding })
  }
  build() {
    Stack() {
      AISkinBackground()
      AISkinReportScreen({ header: () => { this.formHeader() }, content: () => { this.formContent() }, footer: () => { this.formFooter() } })
      Modal({ show: this.showsAgeEditor, title: '年龄', isBusy: this.savingAge, onClose: () => { this.showsAgeEditor = false },
        content: () => { this.ageEditorContent() }, footer: () => { this.ageEditorFooter() } })
      if (this.loadingPlan) {
        AISkinProcessingScreen({ title: this.checkingSource ? '正在准备方案' : this.savingAge ? '正在保存年龄' : '定制方案',
          message: this.checkingSource ? '正在读取最近检测' : this.savingAge ? '正在保存个人信息' : '正在生成护肤方案',
          onCancel: (): void => { this.cancelGeneration() } })
      }
    }.width('100%').height('100%')
  }
}
interface PlanSaveData { planId: string; plan: PlanData }
