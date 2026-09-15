import { AISkinReportTokens } from '../design/Foundation/AISkinReportTokens'
import { AISkinButton, AISkinIconButton, AISkinTabs, AISkinStateView } from '../design/AISkinPrimitives'
import { AISkinProcessingScreen } from '../design/AISkinProcessingScreen'
import { AISkinReportHeading, AISkinReportTextItem, AISkinReportTextStyle, AISkinReportScreen, AISkinReportFooter } from '../design/AISkinReportComponents'
import { AISkinButtonVariant, AISkinCardInset, AISkinCardRole, AISkinCardState, AISkinSpacing, AISkinStateKind, AISkinTabVariant, AISkinTextRole, AISkinTone } from '../design/Foundation/AISkinTokens'
import { Modal, AISkinModalPresentation } from '../components/common/Modal'
import { AISkinColor, CardStyle, TextStyle } from '../design/AISkinTheme'
import router from '@ohos.router'
import { AppHeader } from '../components/common/AppHeader'
import { ProductInfo, ProductData } from '../components/ingredient/ProductInfo'
import { AnalysisOverview, AnalysisData, RiskData } from '../components/ingredient/AnalysisOverview'
import { AnalysisSummary, SummaryData } from '../components/ingredient/AnalysisSummary'
import { ProductApiService, UpdateProductRequest } from '../components/product/ProductApiService'
import { IngredientAnalysisApiService } from '../components/product/IngredientAnalysisApiService'
import { TagSelector, TagSelectorData } from '../components/product/TagSelector'
import { DeleteConfirmModal } from '../components/common/DeleteConfirmModal'
import { AIContentNotice } from '../components/common/AIContentNotice'

@Component
export struct IngredientView {
  private reportScroller: ListScroller = new ListScroller()
  @State loading: boolean = true
  @State loadingText: string = '加载中...'
  @State error: boolean = false
  @State errorMessage: string = ''
  @State hasProductDetails: boolean = false
  @State productId: string = ''
  @State product: ProductData = {
    name: '',
    description: '',
    imageUrl: '',
    label: '',
    openingDate: ''
  }
  @State analysis: AnalysisData = {
    safetyIndex: 0,
    efficacyScore: 0,
    activeIngredients: 0,
    acneRisk: { level: '未知', percentage: 0 },
    irritationRisk: { level: '未知', percentage: 0 },
    allergyRisk: { level: '未知', percentage: 0 }
  }
  @State summary: SummaryData = {
    efficacyAnalysis: [],
    potentialRisks: [],
    recommendations: [],
    overallRating: 0,
    summary: ''
  }
  @State showTagModal: boolean = false
  @State showDeleteModal: boolean = false
  @State saving: boolean = false
  @State deleting: boolean = false
  @State actionError: string = ''
  private isDestroyed: boolean = false
  private generation: number = 0
  private appliedInitialEdit: boolean = false
  registerBackHandler?: (handler: () => boolean) => void
  onOverlay?: (visible: boolean) => void
  private productApiService: ProductApiService = ProductApiService.getInstance()
  private ingredientAnalysisApiService: IngredientAnalysisApiService = IngredientAnalysisApiService.getInstance()
  onBack?: () => void
  onNavigateToConflictSelection?: (productId: string) => void
  @State selectedSection: number = 0
  @State savedNotice: string = ''

  @Prop productIdParam: string = ''
  @Prop initialEditMode: boolean = false

  aboutToAppear() {
    this.isDestroyed = false
    this.registerBackHandler?.((): boolean => this.handleLocalBack())
    // Get product ID from prop or route parameters
    try {
      if (this.productIdParam && this.productIdParam.length > 0) {
        this.productId = this.productIdParam
      } else {
        // Use default product ID if not provided
        this.productId = 'default-product-id'
      }
      this.loadData()
    } catch (error) {
      console.error('Error getting route params:', error)
      this.productId = this.productIdParam || 'default-product-id'
      this.loadData()
    }
  }

  aboutToDisappear() {
    this.isDestroyed = true
    this.generation++
    this.registerBackHandler?.((): boolean => false)
    this.onOverlay?.(false)
  }

  handleLocalBack(): boolean {
    if (this.saving || this.deleting) return true
    if (this.showTagModal || this.showDeleteModal) {
      this.showTagModal = false
      this.showDeleteModal = false
      this.onOverlay?.(false)
      return true
    }
    return false
  }

  goBack(): void { if (!this.handleLocalBack()) this.onBack?.() }

  closeEditor(): void {
    if (this.saving) return
    this.showTagModal = false
    this.onOverlay?.(false)
  }

  closeDelete(): void {
    if (this.deleting) return
    this.showDeleteModal = false
    this.onOverlay?.(false)
  }

  build() {
    Stack() {
      AISkinReportScreen({ header: () => { this.ReportHeader() }, content: () => { this.ReportContent() }, footer: () => { this.ReportFooter() } })
      Modal({ show: this.showTagModal, presentation: AISkinModalPresentation.Reading, title: '产品信息', isBusy: this.saving, onClose: (): void => { this.closeEditor() }, content: () => { this.EditorContent() }, footer: () => { this.EmptyFooter() } })
      DeleteConfirmModal({ show: this.showDeleteModal, title: '确认删除产品', productName: this.product.name || '产品',
        message: `确定要删除“${this.product.name || '产品'}”及关联图片和分析记录吗？此操作无法撤销。`, confirmTitle: '删除',
        isLoading: this.deleting, onCancel: (): void => { this.closeDelete() }, onConfirm: (): void => { this.deleteProduct() } })
    }.width('100%').height('100%')
  }
  @Builder
  ReportHeader() { AppHeader({ title: '成分分析结果', showBackButton: true, onBack: (): void => { this.goBack() } }) }
  @Builder
  ReportContent() {
        if (this.loading) {
          AISkinStateView({ title: this.loadingText, kind: AISkinStateKind.Loading })
        } else if (this.error) {
          AISkinStateView({ title: '成分分析加载失败', message: this.errorMessage, kind: AISkinStateKind.Error, onRetry: (): void => { this.loadData() } })
        } else {
          List({ scroller: this.reportScroller, space: AISkinReportTokens.sectionGap }) {
            ListItem() {
              Column({ space: AISkinSpacing.small }) {
                AIContentNotice({ scene: '产品成分' })
                ProductInfo({ product: this.product })
                AnalysisOverview({ analysis: this.analysis })
              }.width('100%')
            }
            ListItemGroup({ header: () => { this.ReportDirectory() }, space: AISkinReportTokens.sectionGap }) {
              ListItem() { this.ReportSection('01', '功效分析', this.summary.efficacyAnalysis || []) }
              ListItem() { this.ReportSection('02', '潜在风险', this.summary.potentialRisks || []) }
              ListItem() { this.ReportSection('03', '使用建议', this.summary.recommendations || []) }
              ListItem() { this.ReportSection('04', '成分表', [this.product.ingredients?.length ? this.product.ingredients.join('、') : '该次记录未提供成分表']) }
              ListItem() {
                AISkinButton({ title: '和其他产品检查搭配', variant: AISkinButtonVariant.Secondary, onAction: (): void => { this.onNavigateToConflictSelection?.(this.productId) } })
              }
              ListItem() { AISkinButton({ title: '评分与风险说明', variant: AISkinButtonVariant.Plain, onAction: (): void => { this.showScoreDetails() } }) }
            }
          }.width('100%').layoutWeight(1).padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.large }).scrollBar(BarState.Off).sticky(StickyStyle.Header)
        }
  }
  @Builder
  ReportFooter() {
    if (!this.loading && (!this.error || this.hasProductDetails)) { AISkinReportFooter({ content: () => { this.FooterContent() } }) }
  }
  @Builder
  FooterContent() {
          Column({ space: AISkinSpacing.xSmall }) {
            if (this.savedNotice) { Text(this.savedNotice).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Accent)) }
            if (this.actionError && !this.showTagModal) { Text(this.actionError).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Destructive)) }
            if (this.error) {
              AISkinButton({ title: '删除产品', variant: AISkinButtonVariant.Destructive,
                onAction: (): void => { this.actionError = ''; this.showDeleteModal = true; this.onOverlay?.(true) } })
            } else { Row({ space: AISkinSpacing.xSmall }) {
              AISkinIconButton({ name: 'trash', label: '删除分析结果', onAction: () => { this.actionError = ''; this.showDeleteModal = true; this.onOverlay?.(true) } })
              AISkinButton({ title: '保存分析结果', onAction: () => { this.savedNotice = ''; this.actionError = ''; this.showTagModal = true; this.onOverlay?.(true) } }).layoutWeight(1)
            }.width('100%') }
          }.width('100%')
  }
  @Builder
  EditorContent() {
    Column({ space: AISkinSpacing.small }) {
      if (this.saving) { AISkinStateView({ title: '正在保存产品信息', kind: AISkinStateKind.Loading }) }
      if (this.actionError) { Text(this.actionError).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Destructive)).padding(AISkinSpacing.screenEdge) }
      TagSelector({ title: '保存分析结果', initialName: this.product.name || '', initialTag: this.product.label || '', initialDate: this.product.openingDate || '', initialOpeningStatus: this.product.openingStatus || 'unknown', onCancel: (): void => { this.closeEditor() }, onConfirm: (data: TagSelectorData): void => { this.saveProductInfo(data) } }).enabled(!this.saving)
    }.width('100%')
  }
  @Builder
  EmptyFooter() { Column() {} }
  @Builder
  ReportDirectory() {
    AISkinTabs({ items: ['功效', '风险', '建议', '成分'], selection: this.selectedSection, variant: AISkinTabVariant.Underline,
      onSelect: (index: number) => { this.selectedSection = index; this.reportScroller.scrollToItemInGroup(1, index, true, ScrollAlign.START) } })
  }
  @Builder
  ReportSection(number: string, title: string, items: string[]) {
    Column({ space: AISkinSpacing.small }) {
      AISkinReportHeading({ number, title })
      Column({ space: AISkinSpacing.medium }) {
        if (!items.length) { AISkinReportTextItem({ text: '该次分析未提供此项内容' }) }
        ForEach(items, (item: string) => { AISkinReportTextItem({ text: item, style: AISkinReportTextStyle.Reading }) })
      }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
    }.width('100%')
  }
  showScoreDetails() {
    const risks = [`致痘：${this.analysis.acneRisk?.level || '未提供'}`, `刺激：${this.analysis.irritationRisk?.level || '未提供'}`, `过敏：${this.analysis.allergyRisk?.level || '未提供'}`].join('\n')
    AlertDialog.show({ title: '评分与风险说明', message: `安全性指数：${this.analysis.safetyIndex ?? '未提供'} / 100\n功效评分：${this.analysis.efficacyScore ?? '未提供'} / 5\n活性成分：${this.analysis.activeIngredients ?? '未提供'} 项\n${risks}\n评分为模型估计，仅供日常护肤参考。`, confirm: { value: '知道了', action: () => {} } })
  }

  async loadData() {
    const generation = ++this.generation
    console.log('===== 🔍 加载产品成分分析数据 =====')
    this.loading = true
    this.loadingText = '加载产品信息...'
    this.error = false
    this.hasProductDetails = false

    try {
      if (!this.productId || this.productId === 'default-product-id') {
        throw new Error('产品ID无效')
      }

      // 1. 获取产品详情
      this.loadingText = '加载产品信息...'
      const productResponse = await this.productApiService.getProduct(this.productId)
      if (this.isDestroyed || generation !== this.generation) return

      if (!productResponse.success || !productResponse.data?.product) {
        throw new Error(productResponse.message || '获取产品信息失败')
      }

      const productData = productResponse.data.product
      this.hasProductDetails = true
      this.product = {
        name: productData.name || '未命名产品',
        description: productData.description || '暂无描述',
        imageUrl: productData.imageUrl || '',
        label: productData.label || '',
        openingStatus: productData.openingStatus || 'unknown',
        openingDate: productData.openingDate || '',
        ingredients: productData.ingredients || []
      }

      console.log('✅ 产品信息加载成功')

      // 2. 获取成分分析结果
      this.loadingText = '加载成分分析...'
      const analysisResponse = await this.ingredientAnalysisApiService.getIngredientAnalysis(this.productId)
      if (this.isDestroyed || generation !== this.generation) return

      if (analysisResponse.success && analysisResponse.data?.ingredientAnalysis) {
        const analysisData = analysisResponse.data.ingredientAnalysis

        // 更新分析数据
        const defaultRisk: RiskData = {} as RiskData
        defaultRisk.level = '未知'
        defaultRisk.percentage = 0
        
        const acneRisk: RiskData = {} as RiskData
        if (analysisData.acneRisk) {
          acneRisk.level = analysisData.acneRisk.level || '未知'
          acneRisk.percentage = analysisData.acneRisk.percentage || 0
        } else {
          acneRisk.level = '未知'
          acneRisk.percentage = 0
        }
        
        const irritationRisk: RiskData = {} as RiskData
        if (analysisData.irritationRisk) {
          irritationRisk.level = analysisData.irritationRisk.level || '未知'
          irritationRisk.percentage = analysisData.irritationRisk.percentage || 0
        } else {
          irritationRisk.level = '未知'
          irritationRisk.percentage = 0
        }
        
        const allergyRisk: RiskData = {} as RiskData
        if (analysisData.allergyRisk) {
          allergyRisk.level = analysisData.allergyRisk.level || '未知'
          allergyRisk.percentage = analysisData.allergyRisk.percentage || 0
        } else {
          allergyRisk.level = '未知'
          allergyRisk.percentage = 0
        }
        
        const analysis: AnalysisData = {} as AnalysisData
        analysis.overallRating = analysisData.overallRating
        analysis.summary = analysisData.summary
        analysis.safetyIndex = analysisData.safetyIndex
        analysis.efficacyScore = analysisData.efficacyScore
        analysis.activeIngredients = analysisData.activeIngredients
        analysis.acneRisk = acneRisk
        analysis.irritationRisk = irritationRisk
        analysis.allergyRisk = allergyRisk
        this.analysis = analysis

        // 更新摘要数据
        const summary: SummaryData = {} as SummaryData
        summary.efficacyAnalysis = analysisData.efficacyAnalysis || []
        summary.potentialRisks = analysisData.potentialRisks || []
        summary.recommendations = analysisData.recommendations || []
        summary.overallRating = analysisData.overallRating || 0
        summary.summary = analysisData.summary || ''
        this.summary = summary

        console.log(`✅ 成分分析加载成功`)
      } else {
        console.warn('⚠️ 未找到成分分析结果，可能尚未分析')
        throw new Error(analysisResponse.message || '此产品尚无成分分析结果。可返回护肤柜添加清晰的成分图片；不再需要的草稿可在下方删除。')
      }

      this.loading = false
    } catch (error) {
      if (this.isDestroyed || generation !== this.generation) return
      console.error('❌ Error loading data')
      this.error = true
      this.errorMessage = error instanceof Error ? error.message : '加载数据失败，请重试'
      this.loading = false
    } finally {
      if (!this.isDestroyed && generation === this.generation && this.hasProductDetails && this.initialEditMode && !this.appliedInitialEdit) {
        this.appliedInitialEdit = true
        this.showTagModal = true
        this.onOverlay?.(true)
      }
    }
  }

  async saveProductInfo(data: TagSelectorData) {
    if (this.saving || this.deleting || this.isDestroyed) return
    const generation = ++this.generation
    console.log('===== ✏️ 保存产品信息 =====')
    this.saving = true
    this.actionError = ''

    try {
      if (!this.productId) {
        throw new Error('产品ID无效')
      }

      // 更新产品标签和开封日期
      const updateData: UpdateProductRequest = {} as UpdateProductRequest
      updateData.name = data.name
      updateData.label = data.tag || ''
      updateData.openingStatus = data.openingStatus
      updateData.openingDate = data.openingStatus === 'opened' ? data.openingDate : ''

      const response = await this.productApiService.updateProduct(this.productId, updateData)
      if (this.isDestroyed || generation !== this.generation) return

      if (!response.success) {
        throw new Error(response.message || '保存产品信息失败')
      }

      // 更新本地数据
      this.product = { name: data.name, description: this.product.description, imageUrl: this.product.imageUrl,
        ingredients: this.product.ingredients, label: data.tag || '', openingStatus: data.openingStatus, openingDate: data.openingDate || '' }

      console.log('✅ 产品信息保存成功')
      this.saving = false
      this.closeEditor()
      this.savedNotice = '产品信息已保存'
    } catch (error) {
      if (this.isDestroyed || generation !== this.generation) return
      console.error('❌ Error saving product info')
      this.actionError = error instanceof Error ? error.message : '保存产品信息失败，请重试'
    } finally {
      if (!this.isDestroyed && generation === this.generation) this.saving = false
    }
  }

  async deleteProduct() {
    if (this.saving || this.deleting || this.isDestroyed) return
    const generation = ++this.generation
    console.log('===== 🗑️ 删除产品 =====')
    this.deleting = true
    this.actionError = ''

    try {
      if (!this.productId) {
        throw new Error('产品ID无效')
      }

      const response = await this.productApiService.deleteProduct(this.productId)
      if (this.isDestroyed || generation !== this.generation) return

      if (!response.success) {
        throw new Error(response.message || '删除产品失败')
      }

      console.log('✅ 产品删除成功')
      this.deleting = false
      this.closeDelete()

      // Navigate back to product page
      if (this.onBack) {
        this.onBack()
      }
    } catch (error) {
      if (this.isDestroyed || generation !== this.generation) return
      console.error('❌ Error deleting product')
      this.actionError = error instanceof Error ? error.message : '删除产品失败，请重试'
      this.deleting = false
      this.closeDelete()
    } finally {
      if (!this.isDestroyed && generation === this.generation) this.deleting = false
    }
  }

  formatDateForInput(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
