import { AISkinColor, CardStyle } from '../design/AISkinTheme'
import router from '@ohos.router'
import { AppHeader } from '../components/common/AppHeader'
import { ProductInfo, ProductData } from '../components/ingredient/ProductInfo'
import { AnalysisOverview, AnalysisData, RiskData } from '../components/ingredient/AnalysisOverview'
import { AnalysisSummary, SummaryData } from '../components/ingredient/AnalysisSummary'
import { ProductApiService, UpdateProductRequest } from '../components/product/ProductApiService'
import { IngredientAnalysisApiService } from '../components/product/IngredientAnalysisApiService'
import { TagSelector, TagSelectorData } from '../components/product/TagSelector'
import { DeleteConfirmModal } from '../components/common/DeleteConfirmModal'
import { Modal } from '../components/common/Modal'
import { AIContentNotice } from '../components/common/AIContentNotice'

@Component
export struct IngredientView {
  private reportScroller: ListScroller = new ListScroller()
  @State loading: boolean = true
  @State loadingText: string = '加载中...'
  @State error: boolean = false
  @State errorMessage: string = ''
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
  private productApiService: ProductApiService = ProductApiService.getInstance()
  private ingredientAnalysisApiService: IngredientAnalysisApiService = IngredientAnalysisApiService.getInstance()
  onBack?: () => void

  @Prop productIdParam: string = ''

  aboutToAppear() {
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

  build() {
    Stack() {
    Column() {
      // Header
      AppHeader({
        title: '成分分析结果',
        icon: 'flask',
        showBackButton: true,
        bgColor: 'bg-sakura',
        onBack: () => {
          if (this.onBack) {
            this.onBack()
          }
        }
      })
      .width('100%')

      // Main Content
      if (this.loading) {
        this.LoadingState()
      } else if (this.error) {
        this.ErrorState()
      } else {
        List({ scroller: this.reportScroller, space: 16 }) {
          ListItem() {
            Column({ space: 12 }) {
              AIContentNotice({ scene: '产品成分' })
              ProductInfo({ product: this.product })
              AnalysisOverview({ analysis: this.analysis })
            }.width('100%')
          }
          ListItemGroup({ header: this.ReportDirectory, space: 16 }) {
            ListItem() { this.ReportSection('01', '功效分析', this.summary.efficacyAnalysis || []) }
            ListItem() { this.ReportSection('02', '潜在风险', this.summary.potentialRisks || []) }
            ListItem() { this.ReportSection('03', '使用建议', this.summary.recommendations || []) }
            ListItem() { this.ReportSection('04', '成分表', [this.product.ingredients?.length ? this.product.ingredients.join('、') : '该次记录未提供成分表']) }
            ListItem() { this.ReportSection('05', '分析小结', [this.summary.summary || '该次记录暂无小结']) }
          }
        }.width('100%').layoutWeight(1).padding({ left: 24, right: 24, bottom: 20 }).scrollBar(BarState.Off).sticky(StickyStyle.Header)
      }

      // Action Buttons - Hide when modals are open
      if (!this.loading && !this.error && !this.showTagModal && !this.showDeleteModal) {
        Row() {
          Button('编辑产品信息')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AISkinColor.primary)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .margin({ right: 8 })
            .onClick(() => {
              console.log('===== 💾 点击保存分析结果 =====')
              this.showTagModal = true
            })

          Button('删除')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AISkinColor.dangerSurface)
            .fontColor(AISkinColor.danger)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .onClick(() => {
              console.log('===== 🗑️ 点击删除分析结果 =====')
              this.showDeleteModal = true
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16, top: 12 })
        .backgroundColor(AISkinColor.surface)
        .border({
          width: { top: 1 },
          color: AISkinColor.divider,
          style: BorderStyle.Solid
        })
      }

    }.width('100%').height('100%')
      // Tag Selector Modal
      if (this.showTagModal) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(AISkinColor.scrim)
            .onClick(() => {
              this.showTagModal = false
            })

          Column() {
            TagSelector({
              title: '编辑产品信息',
              initialName: this.product.name || '',
              initialOpeningStatus: this.product.openingStatus || 'unknown',
              initialTag: this.product.label || '',
              initialDate: this.product.openingDate ? this.formatDateForInput(new Date(this.product.openingDate)) : '',
              onCancel: () => {
                console.log('===== ❌ 取消保存 =====')
                this.showTagModal = false
              },
              onConfirm: (data: TagSelectorData) => {
                this.saveProductInfo(data)
              }
            })
          }
          .width('90%')
          .constraintSize({ maxWidth: 400 })
          .attributeModifier(new CardStyle()).backgroundColor(AISkinColor.dialog)
          .onClick(() => {
            // Prevent backdrop click from closing when clicking modal content
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(10000)
      }

      // Delete Confirm Modal
      DeleteConfirmModal({
        show: this.showDeleteModal,
        productName: this.product.name || '产品',
        onCancel: () => {
          console.log('===== ❌ 取消删除 =====')
          this.showDeleteModal = false
        },
        onConfirm: () => {
          this.deleteProduct()
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }

  @Builder
  ReportDirectory() {
    Row({ space: 4 }) {
      ForEach(['功效', '风险', '建议', '成分'], (title: string, index: number) => {
        Button(title).height(44).layoutWeight(1).fontSize(13).fontColor(AISkinColor.accent).backgroundColor(Color.Transparent)
          .onClick(() => { this.reportScroller.scrollToItemInGroup(1, index, true, ScrollAlign.START) })
      })
    }.width('100%').padding(4).backgroundColor(AISkinColor.elevated).borderRadius(24).margin({ bottom: 16 })
  }
  @Builder
  ReportSection(number: string, title: string, items: string[]) {
    Column({ space: 16 }) {
      Row({ space: 12 }) { Text(number).fontSize(12).fontColor(AISkinColor.accent); Text(title).fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text) }
      if (!items.length) { Text('该次分析未提供此项内容').fontSize(14).fontColor(AISkinColor.secondary) }
      ForEach(items, (item: string) => { Text(item).fontSize(14).lineHeight(24).fontColor(AISkinColor.text).width('100%') })
    }.width('100%').padding(20).alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle())
  }

  @Builder
  AnalysisBasisCard() {
    Column() {
      Text('分析依据')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AISkinColor.text)
        .width('100%')
        .margin({ bottom: 10 })

      Text('1. 用户主动选择的产品图片与产品信息')
        .fontSize(13)
        .fontColor(AISkinColor.text)
        .lineHeight(20)
        .width('100%')
      Text('2. 服务端返回的成分识别、功效与风险分析结果')
        .fontSize(13)
        .fontColor(AISkinColor.text)
        .lineHeight(20)
        .width('100%')
      Text('3. 致痘、刺激和过敏风险采用分级方式展示')
        .fontSize(13)
        .fontColor(AISkinColor.text)
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AISkinColor.white)
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(AISkinColor.accent)
        .margin({ bottom: 16 })

      Text(this.loadingText)
        .fontSize(16)
        .fontColor(AISkinColor.secondary)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorState() {
    Column() {
      Text('⚠️')
        .fontSize(48)
        .margin({ bottom: 16 })

      Text(this.errorMessage)
        .fontSize(16)
        .fontColor(AISkinColor.secondary)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 16 })

      Button('重试')
        .width(120)
        .height(40)
        .backgroundColor(AISkinColor.primary)
        .fontColor(Color.White)
        .borderRadius(20)
        .onClick(() => {
          this.loadData()
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding(32)
  }

  async loadData() {
    console.log('===== 🔍 加载产品成分分析数据 =====')
    this.loading = true
    this.loadingText = '加载产品信息...'
    this.error = false

    try {
      if (!this.productId || this.productId === 'default-product-id') {
        throw new Error('产品ID无效')
      }

      // 1. 获取产品详情
      this.loadingText = '加载产品信息...'
      const productResponse = await this.productApiService.getProduct(this.productId)

      if (!productResponse.success || !productResponse.data?.product) {
        throw new Error(productResponse.message || '获取产品信息失败')
      }

      const productData = productResponse.data.product
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
        analysis.safetyIndex = analysisData.safetyIndex || 0
        analysis.efficacyScore = analysisData.efficacyScore || 0
        analysis.activeIngredients = analysisData.activeIngredients || 0
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
        throw new Error(analysisResponse.message || '此产品尚无成分分析结果，请返回护肤柜重新分析。')
      }

      this.loading = false
    } catch (error) {
      console.error('❌ Error loading data')
      this.error = true
      this.errorMessage = error instanceof Error ? error.message : '加载数据失败，请重试'
      this.loading = false
    }
  }

  async saveProductInfo(data: TagSelectorData) {
    console.log('===== ✏️ 保存产品信息 =====')
    this.loading = true
    this.loadingText = '保存产品信息中...'
    this.showTagModal = false

    try {
      if (!this.productId) {
        throw new Error('产品ID无效')
      }

      // 更新产品标签和开封日期
      const updateData: UpdateProductRequest = {} as UpdateProductRequest
      updateData.name = data.name
      updateData.label = data.tag || ''
      updateData.openingStatus = data.openingStatus
      if (data.openingDate) updateData.openingDate = data.openingDate

      const response = await this.productApiService.updateProduct(this.productId, updateData)

      if (!response.success) {
        throw new Error(response.message || '保存产品信息失败')
      }

      // 更新本地数据
      this.product.name = data.name
      this.product.label = data.tag || ''
      this.product.openingStatus = data.openingStatus
      this.product.openingDate = data.openingDate || ''

      console.log('✅ 产品信息保存成功')
      this.loading = false

      // Navigate back to product page
      if (this.onBack) {
        this.onBack()
      }
    } catch (error) {
      console.error('❌ Error saving product info')
      this.error = true
      this.errorMessage = error instanceof Error ? error.message : '保存产品信息失败，请重试'
      this.loading = false
    }
  }

  async deleteProduct() {
    console.log('===== 🗑️ 删除产品 =====')
    this.loading = true
    this.loadingText = '删除中...'
    this.showDeleteModal = false

    try {
      if (!this.productId) {
        throw new Error('产品ID无效')
      }

      const response = await this.productApiService.deleteProduct(this.productId)

      if (!response.success) {
        throw new Error(response.message || '删除产品失败')
      }

      console.log('✅ 产品删除成功')

      // Navigate back to product page
      if (this.onBack) {
        this.onBack()
      }
    } catch (error) {
      console.error('❌ Error deleting product')
      this.error = true
      this.errorMessage = error instanceof Error ? error.message : '删除产品失败，请重试'
      this.loading = false
    }
  }

  formatDateForInput(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
