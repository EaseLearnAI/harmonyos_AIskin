import { AISkinReportScreen, AISkinReportFooter } from '../design/AISkinReportComponents'
import { common } from '@kit.AbilityKit'
import { AISkinColor, AISkinBackground, CardStyle, TextStyle } from '../design/AISkinTheme'
import { AISkinHeader, AISkinButton, AISkinTabs, AISkinTag, AISkinStateView } from '../design/AISkinPrimitives'
import { AISkinSkinSummaryCard, AISkinSkinPhotoMap } from '../design/AISkinSkinComponents'
import { AISkinProcessingScreen } from '../design/AISkinProcessingScreen'
import { skinObservations } from '../design/SkinReportPresentation'
import { AISkinSpacing, AISkinLayout, AISkinTextRole, AISkinTone, AISkinButtonVariant, AISkinButtonLayout, AISkinCardRole, AISkinCardState, AISkinCardInset, AISkinTagState, AISkinTagVariant, AISkinStateKind } from '../design/Foundation/AISkinTokens'
import { SkinDetectionWelcome } from '../components/skin-analysis/SkinDetectionWelcome'
import { AIContentNotice } from '../components/common/AIContentNotice'
import { Modal, AISkinModalPresentation } from '../components/common/Modal'
import { SkinAnalysisService, SkinAnalysisResponse } from '../services/SkinAnalysisService'
import { SkinAnalysisData, SkinAnalysisApiService, SkinContext } from '../services/SkinAnalysisApiService'
@Component
export struct SkinStatusView {
  @Prop openHistory: boolean = false
  @Prop presentedAsSource: boolean = false
  @Prop initialReport: SkinAnalysisData | null = null
  @State loading: boolean = true
  @State error: string = ''
  @State historyError: string = ''
  @State history: SkinAnalysisData[] = []
  @State result: SkinAnalysisData | null = null
  @State showReport: boolean = false
  @State showHistory: boolean = false
  @State analyzing: boolean = false
  @State capturing: boolean = false
  @State section: number = 0
  @State contextEditing: boolean = false
  @State contextSaving: boolean = false
  @State deleting: boolean = false
  @State contextError: string = ''
  @State contextCondition: string = ''
  @State contextLight: string = ''
  @State contextFeelings: string[] = []
  private reportScroller: Scroller = new Scroller()
  private service: SkinAnalysisService = SkinAnalysisService.getInstance()
  private generation: number = 0
  private historyGeneration: number = 0
  private isDestroyed: boolean = false
  private contextRecordId: string = ''
  registerBackHandler?: (handler: () => boolean) => void
  onBack?: () => void
  onProfile?: () => void
  onCreatePlan?: () => void
  onReportVisibility?: (visible: boolean) => void
  aboutToAppear() { this.isDestroyed = false; this.registerBackHandler?.(() => this.handleBack()); this.showHistory = this.openHistory; if (this.initialReport) { this.result = this.initialReport; this.setReport(true) }; this.load() }
  aboutToDisappear() { this.isDestroyed = true; this.generation++; this.historyGeneration++; this.registerBackHandler?.(() => false); this.onReportVisibility?.(false) }
  private isBusy(): boolean { return this.isDestroyed || this.capturing || this.deleting || this.contextSaving }
  private isCurrent(generation: number): boolean { return !this.isDestroyed && generation === this.generation }
  private invalidateHistoryLoad(): void { this.historyGeneration++; this.loading = false }
  private handleBack(): boolean {
    if (this.isBusy()) return true
    if (this.contextEditing) { this.closeContext(); return true }
    if (this.showHistory) { this.showHistory = false; if (this.openHistory) this.onBack?.(); return true }
    if (this.analyzing) { this.generation++; this.analyzing = false; this.onReportVisibility?.(this.showReport); return true }
    if (this.showReport) { if (this.presentedAsSource) { this.onBack?.(); return true }; this.setReport(false); if (this.openHistory) this.showHistory = true; return true }
    return false
  }
  private setReport(value: boolean): void { this.showReport = value; this.section = 0; this.onReportVisibility?.(value || this.deleting || this.contextSaving) }
  private recordId(data: SkinAnalysisData): string { return data._id || data.analysisId || '' }
  private date(data: SkinAnalysisData): string { return data.createdAt ? new Date(data.createdAt).toLocaleDateString('zh-CN') : '未记录时间' }
  async load(): Promise<void> {
    if (this.isDestroyed) return
    const generation = this.generation
    const historyGeneration = ++this.historyGeneration
    this.loading = true
    this.historyError = ''
    try {
      const response = await this.service.getHistory(1,50)
      if (!this.isCurrent(generation) || historyGeneration !== this.historyGeneration) return
      if (!response.success) { this.historyError = response.message || '检测历史加载失败'; return }
      this.history = response.data?.analyses || []
      if (!this.result) this.result = this.history[0] || null
    } catch (error) {
      if (this.isCurrent(generation) && historyGeneration === this.historyGeneration) this.historyError = '检测历史加载失败，请检查网络后重试'
    } finally {
      if (this.isCurrent(generation) && historyGeneration === this.historyGeneration) this.loading = false
    }
  }
  private select(data: SkinAnalysisData): void {
    if (this.isBusy() || this.analyzing || this.contextEditing) return
    this.result = data; this.showHistory = false; this.error = ''; this.setReport(true)
  }
  private async analyze(source: string): Promise<void> {
    if (this.isBusy() || this.analyzing || this.contextEditing) return
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    const generation = ++this.generation
    this.invalidateHistoryLoad()
    this.error = ''
    const callback = (progress: number, status: string): void => { if (this.isCurrent(generation) && progress >= 20) { this.capturing = false; this.analyzing = true; this.onReportVisibility?.(true) } }
    this.capturing = true
    let response: SkinAnalysisResponse
    try {
      response = source === 'gallery' ? await this.service.analyzeFromGallery(context,callback) : await this.service.analyzeFromCamera(context,callback)
    } catch (error) {
      if (this.isCurrent(generation)) { this.analyzing = false; this.error = '分析失败，请重试'; this.onReportVisibility?.(this.showReport) }
      return
    } finally {
      if (this.isCurrent(generation)) this.capturing = false
    }
    if (!this.isCurrent(generation)) return
    this.analyzing = false
    if (response.success && response.data) { this.result = response.data; this.setReport(true); await this.load() }
    else { this.onReportVisibility?.(this.showReport); this.error = response.message?.includes('取消') || response.message === '未选择图片' || response.message === '未拍摄照片' ? '' : response.message || '分析失败，请重试' }
  }
  private deleteRecord(): void {
    if (!this.result || this.isBusy() || this.analyzing || this.contextEditing) return
    const id = this.recordId(this.result)
    AlertDialog.show({ title: '删除检测记录', message: '将删除本次检测照片和报告，无法恢复。',
      primaryButton: { value: '取消', action: () => {} }, secondaryButton: { value: '删除', action: () => { this.remove(id) } } })
  }
  private async remove(id: string): Promise<void> {
    if (this.isBusy() || this.analyzing || this.contextEditing || !id || !this.result || this.recordId(this.result) !== id) return
    const generation = ++this.generation
    this.invalidateHistoryLoad()
    this.deleting = true
    this.error = ''
    this.onReportVisibility?.(true)
    try {
      const response = await this.service.deleteAnalysis(id)
      if (!this.isCurrent(generation)) return
      if (!response.success) { this.error = response.message || '删除失败'; return }
      this.history = this.history.filter(record => this.recordId(record) !== id)
      this.clearContextDraft()
      if (this.result && this.recordId(this.result) === id) { this.result = null; this.setReport(false) }
      await this.load()
    } catch (error) {
      if (this.isCurrent(generation)) this.error = '删除失败，请检查网络后重试'
    } finally {
      if (this.isCurrent(generation)) { this.deleting = false; this.onReportVisibility?.(this.showReport || this.analyzing) }
    }
  }
  private editContext(): void {
    if (!this.result || this.isBusy() || this.analyzing) return
    this.contextRecordId = this.recordId(this.result)
    if (!this.contextRecordId) return
    this.contextError = ''
    this.contextCondition = this.result?.context?.condition || ''
    this.contextLight = this.result?.context?.light || ''
    this.contextFeelings = (this.result?.context?.feelings || []).slice()
    this.contextEditing = true
  }
  private clearContextDraft(): void {
    this.contextEditing = false; this.contextRecordId = ''; this.contextCondition = ''; this.contextLight = ''; this.contextFeelings = []; this.contextError = ''
  }
  private closeContext(): void { if (!this.isBusy()) this.clearContextDraft() }
  private async saveContext(): Promise<void> {
    if (this.isBusy() || !this.contextEditing || !this.contextRecordId) return
    const id = this.contextRecordId
    if (!this.result || this.recordId(this.result) !== id) { this.contextError = '检测记录已变化，请关闭后重新编辑'; return }
    const input: SkinContext = { condition: this.contextCondition, light: this.contextLight, feelings: this.contextFeelings.slice() }
    const generation = ++this.generation
    this.invalidateHistoryLoad()
    this.contextSaving = true
    this.contextError = ''
    try {
      const response = await SkinAnalysisApiService.getInstance().updateContext(id,input)
      if (!this.isCurrent(generation) || this.contextRecordId !== id) return
      if (!response.success) { this.contextError = response.message || '保存失败'; return }
      const updated = response.data?.analysis
      if (!updated || this.recordId(updated) !== id) { this.contextError = '未能确认保存结果，请重试'; return }
      if (this.result && this.recordId(this.result) === id) this.result = updated
      this.history = this.history.map(record => this.recordId(record) === id ? updated : record)
      this.clearContextDraft()
      await this.load()
    } catch (error) {
      if (this.isCurrent(generation)) this.contextError = '保存失败，请检查网络后重试'
    } finally {
      if (this.isCurrent(generation)) this.contextSaving = false
    }
  }
  private comparison(): string {
    const index = this.history.findIndex(item => this.recordId(item) === (this.result ? this.recordId(this.result) : ''))
    const previous = this.history[index + 1]
    if (index < 0 || !previous) return '这是该时间点的首次记录，后续可在历史中比较变化。'
    return `上次 ${this.date(previous)}：${previous.overallAssessment?.healthScore ?? '未记录'} 分 · 本次：${this.result?.overallAssessment?.healthScore ?? '未记录'} 分。拍摄光线与状态可能影响结果。`
  }
  build() {
    Stack() {
      AISkinReportScreen({ header: () => { this.screenHeader() }, anchor: () => { this.screenAnchor() }, content: () => { this.screenContent() }, footer: () => { this.screenFooter() } })
        .enabled(!this.isBusy() && !this.contextEditing && !this.showHistory && !this.analyzing)
      if (this.analyzing) { AISkinProcessingScreen({ title: '正在分析肌肤', message: '稍等一下，细节也想照顾到', onCancel: () => { this.generation++; this.analyzing = false; this.onReportVisibility?.(this.showReport) } }) }
      Modal({ show: this.showHistory, title: '检测历史', presentation: AISkinModalPresentation.Reading, isBusy: this.isBusy(), onClose: () => { if (!this.isBusy()) { this.showHistory = false; if (this.openHistory) this.onBack?.() } }, content: () => { this.historyContent() } })
      Modal({ show: this.contextEditing, title: '拍摄时的状态', presentation: AISkinModalPresentation.Reading, isBusy: this.isBusy(), onClose: () => { this.closeContext() }, content: () => { this.contextContent() } })
    }.width('100%').height('100%')
  }
  @Builder
  screenHeader() {
        AISkinHeader({ title: this.showReport ? '肌肤报告' : '肌肤检测', leftIcon: this.showReport || this.presentedAsSource ? 'back' : 'profile', leftLabel: this.showReport || this.presentedAsSource ? '返回' : '我的',
          onLeft: () => { if (this.showReport) this.handleBack(); else if (this.presentedAsSource) this.onBack?.(); else this.onProfile?.() }, rightIcon: 'history', rightLabel: '检测历史', onRight: () => { this.showHistory = true } })
  }
  @Builder
  screenAnchor() {
    if (this.showReport && this.result) {
      if (this.error) { Text(this.error).attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Destructive)).padding(AISkinSpacing.small) }
      if (this.historyError) { AISkinStateView({ title: '检测历史加载失败', message: this.historyError, kind: AISkinStateKind.Error, onRetry: () => { this.load() } }) }
          AISkinTabs({ items: ['肌肤问题','肤况概览','护肤建议','前后对比'], selection: this.section, onSelect: (index: number) => { this.section = index; this.reportScroller.scrollToIndex(index,true) } }).padding({ left: AISkinSpacing.medium, right: AISkinSpacing.medium })
    }
  }
  @Builder
  screenContent() {
    if (this.showReport && this.result) {
          List({ scroller: this.reportScroller, space: AISkinSpacing.sectionGap }) {
            ListItem() {
              Column({ space: AISkinSpacing.small }) {
                Text('01  肌肤问题').attributeModifier(new TextStyle(AISkinTextRole.SectionTitle)).width('100%')
                AISkinSkinPhotoMap({ imageUrl: this.result.imageUrl || '', observations: skinObservations(this.result) })
              }
            }
            ListItem() { Column({ space: AISkinSpacing.small }) {
              Text('02  肤况概览').attributeModifier(new TextStyle(AISkinTextRole.SectionTitle)).width('100%')
              AISkinSkinSummaryCard({ data: this.result })
              Text(this.result.skinType?.basis || '该次记录未提供肤质判断依据').attributeModifier(new TextStyle(AISkinTextRole.ReportBody,AISkinTone.Secondary))
              Text(this.date(this.result)).attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Secondary)).width('100%')
            } }
            ListItem() { Column({ space: AISkinSpacing.small }) {
              Text('03  护肤建议').attributeModifier(new TextStyle(AISkinTextRole.SectionTitle)).width('100%')
              ForEach(this.result.overallAssessment?.recommendations || [], (tip: string,index: number) => { Text(`${String(index+1).padStart(2,'0')}  ${tip}`).attributeModifier(new TextStyle(AISkinTextRole.ReportBody,AISkinTone.Secondary)).width('100%').padding(AISkinSpacing.small) })
            } }
            ListItem() { Column({ space: AISkinSpacing.small }) {
              Text('04  前后对比').attributeModifier(new TextStyle(AISkinTextRole.SectionTitle)).width('100%')
              Text(this.comparison()).attributeModifier(new TextStyle(AISkinTextRole.ReportBody,AISkinTone.Secondary)).width('100%')
              Text([this.result.context?.condition || '未记录状态',this.result.context?.light || '未记录光线',(this.result.context?.feelings || []).join('、')].filter(value => value.length > 0).join(' · ')).attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Secondary))
              AISkinButton({ title: '补充拍摄状态', variant: AISkinButtonVariant.Secondary, onAction: () => { this.editContext() } })
              AISkinButton({ title: '删除检测记录', variant: AISkinButtonVariant.Destructive, isLoading: this.deleting, onAction: () => { this.deleteRecord() } })
            }.attributeModifier(new CardStyle(AISkinCardRole.Content,AISkinCardState.Normal,AISkinCardInset.Regular)) }
            ListItem() { AIContentNotice({ scene: '肌肤检测' }) }
          }.layoutWeight(1).width('100%').padding({ left: AISkinSpacing.screenEdge,right: AISkinSpacing.screenEdge,top: AISkinSpacing.small,bottom: AISkinSpacing.xLarge }).scrollBar(BarState.Off)
            .onScrollIndex((first: number) => { this.section = Math.min(3,first) })
    } else {
          Scroll() {
            Column({ space: AISkinSpacing.sectionGap }) {
              if (this.loading) { AISkinStateView({ title: '正在读取检测记录', kind: AISkinStateKind.Loading }) }
              else if (this.result) {
                AISkinSkinSummaryCard({ data: this.result })
                Row({ space: AISkinSpacing.small }) {
                  AISkinButton({ title: '查看完整报告', variant: AISkinButtonVariant.Secondary, onAction: () => { this.setReport(true) } }).layoutWeight(1)
                  AISkinButton({ title: '重新检测', onAction: () => { this.analyze('camera') } }).layoutWeight(1)
                }
                Column({ space: AISkinSpacing.small }) {
                  Text('定制护肤方案').attributeModifier(new TextStyle(AISkinTextRole.CardTitle))
                  Text('根据本次肤况，结合护肤柜里的产品安排早晚护肤。').attributeModifier(new TextStyle(AISkinTextRole.ReportBody,AISkinTone.Secondary))
                  AISkinButton({ title: '定制护肤方案', onAction: this.onCreatePlan })
                }.attributeModifier(new CardStyle(AISkinCardRole.Action,AISkinCardState.Normal,AISkinCardInset.Regular))
                AIContentNotice({ scene: '肌肤检测' })
                AISkinButton({ title: '检测历史', variant: AISkinButtonVariant.Plain, onAction: () => { this.showHistory = true } })
              } else if (!this.historyError) { SkinDetectionWelcome({ onTakePhoto: () => { this.analyze('camera') }, onSelectPhoto: () => { this.analyze('gallery') } }) }
              if (this.historyError) { AISkinStateView({ title: '检测历史加载失败', message: this.historyError, kind: AISkinStateKind.Error, onRetry: () => { this.load() } }) }
              if (this.error) { AISkinStateView({ title: '暂时无法完成', message: this.error, kind: AISkinStateKind.Error }) }
            }.width('100%').padding({ left: AISkinSpacing.screenEdge,right: AISkinSpacing.screenEdge,top: AISkinSpacing.medium,bottom: AISkinLayout.bottomClearance })
          }.width('100%').layoutWeight(1).align(Alignment.Top)
    }
  }
  @Builder
  screenFooter() {
    if (this.showReport && this.result) { AISkinReportFooter({ content: () => { this.reportActions() } }) }
  }
  @Builder
  reportActions() {
          Row({ space: AISkinSpacing.small }) {
            AISkinButton({ title: '重新检测', variant: AISkinButtonVariant.Secondary, onAction: () => { this.setReport(false); this.analyze('camera') } }).layoutWeight(1)
            AISkinButton({ title: '定制护肤方案', onAction: this.onCreatePlan }).layoutWeight(1)
          }
  }
  @Builder
  historyContent() {
    Column({ space: AISkinSpacing.small }) {
      if (this.loading) { AISkinStateView({ title: '正在读取检测历史', kind: AISkinStateKind.Loading }) }
      else if (this.historyError) { AISkinStateView({ title: '历史加载失败', message: this.historyError, kind: AISkinStateKind.Error, onRetry: () => { this.load() } }) }
      else if (!this.history.length) { AISkinStateView({ title: '暂无检测历史' }) }
      ForEach(this.history, (record: SkinAnalysisData) => {
        AISkinButton({ title: `${this.date(record)} · ${record.overallAssessment?.healthScore ?? '—'} 分`, variant: AISkinButtonVariant.Surface, onAction: () => this.select(record) })
      })
    }.width('100%').enabled(!this.isBusy())
  }
  @Builder
  contextContent() {
    Column({ space: AISkinSpacing.medium }) {
      Text('帮助理解两次检测结果的差异，不会改变AI原始评分。').attributeModifier(new TextStyle(AISkinTextRole.ReportBody,AISkinTone.Secondary))
      Flex({ wrap: FlexWrap.Wrap }) { ForEach(['未记录','洁面前','洁面后','护肤后','上妆后'], (value: string) => {
        AISkinTag({ title: value, variant: AISkinTagVariant.SelectionCell, state: (this.contextCondition || '未记录') === value ? AISkinTagState.Selected : AISkinTagState.Normal, onAction: () => { this.contextCondition = value === '未记录' ? '' : value } }).width('31%').margin(AISkinSpacing.xxxSmall)
      }) }
      Flex({ wrap: FlexWrap.Wrap }) { ForEach(['自然光','室内光','不确定'], (value: string) => {
        AISkinTag({ title: value, state: this.contextLight === value ? AISkinTagState.Selected : AISkinTagState.Normal, onAction: () => { this.contextLight = value } }).margin(AISkinSpacing.xxxSmall)
      }) }
      Flex({ wrap: FlexWrap.Wrap }) { ForEach(['紧绷','出油','刺痛','泛红','无不适'], (value: string) => {
        AISkinTag({ title: value, state: this.contextFeelings.includes(value) ? AISkinTagState.Selected : AISkinTagState.Normal, onAction: () => { this.contextFeelings = this.contextFeelings.includes(value) ? this.contextFeelings.filter(item => item !== value) : value === '无不适' ? [value] : this.contextFeelings.filter(item => item !== '无不适').concat([value]) } }).margin(AISkinSpacing.xxxSmall)
      }) }
      if (this.contextError) { Text(this.contextError).attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Destructive)) }
      AISkinButton({ title: '保存拍摄状态', isLoading: this.contextSaving, onAction: () => { this.saveContext() } })
    }.width('100%').enabled(!this.isBusy())
  }
}
