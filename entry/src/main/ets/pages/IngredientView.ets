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

@Component
export struct IngredientView {
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
    acneRisk: { level: '低', percentage: 0 },
    irritationRisk: { level: '低', percentage: 0 },
    allergyRisk: { level: '低', percentage: 0 }
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
    Column() {
      // Header
      AppHeader({
        title: '成分分析',
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
        Scroll() {
          Column() {
            // Product Info
            ProductInfo({
              product: this.product
            })

            // Analysis Overview
            AnalysisOverview({
              analysis: this.analysis
            })

            // Analysis Summary
            AnalysisSummary({
              analysis: this.summary
            })
          }
          .width('100%')
          .padding({ left: 16, right: 20, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }

      // Action Buttons - Hide when modals are open
      if (!this.showTagModal && !this.showDeleteModal) {
        Row() {
          Button('保存分析结果')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#4CAF50')
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .margin({ right: 8 })
            .onClick(() => {
              console.log('===== 💾 点击保存分析结果 =====')
              this.showTagModal = true
            })

          Button('删除分析结果')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#FFE0E0')
            .fontColor('#F44336')
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
        .backgroundColor(Color.White)
        .border({
          width: { top: 1 },
          color: '#eeeeee',
          style: BorderStyle.Solid
        })
      }

      // Tag Selector Modal
      if (this.showTagModal) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .onClick(() => {
              this.showTagModal = false
            })

          Column() {
            TagSelector({
              title: '保存分析结果',
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
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 20,
            color: 'rgba(0, 0, 0, 0.15)',
            offsetX: 0,
            offsetY: 10
          })
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
    .backgroundColor('#f8f8f8')
  }

  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#9c27b0')
        .margin({ bottom: 16 })

      Text(this.loadingText)
        .fontSize(16)
        .fontColor('#757575')
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
        .fontColor('#757575')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 16 })

      Button('重试')
        .width(120)
        .height(40)
        .backgroundColor('#f48fb1')
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

      console.log(`🆔 产品ID: ${this.productId}`)

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
        openingDate: productData.openingDate || productData.createdAt || new Date().toISOString()
      }

      console.log(`✅ 产品信息加载成功: ${this.product.name}`)

      // 2. 获取成分分析结果
      this.loadingText = '加载成分分析...'
      const analysisResponse = await this.ingredientAnalysisApiService.getIngredientAnalysis(this.productId)

      if (analysisResponse.success && analysisResponse.data?.ingredientAnalysis) {
        const analysisData = analysisResponse.data.ingredientAnalysis

        // 更新分析数据
        const defaultRisk: RiskData = {} as RiskData
        defaultRisk.level = '低'
        defaultRisk.percentage = 0
        
        const acneRisk: RiskData = {} as RiskData
        if (analysisData.acneRisk) {
          acneRisk.level = analysisData.acneRisk.level || '低'
          acneRisk.percentage = analysisData.acneRisk.percentage || 0
        } else {
          acneRisk.level = '低'
          acneRisk.percentage = 0
        }
        
        const irritationRisk: RiskData = {} as RiskData
        if (analysisData.irritationRisk) {
          irritationRisk.level = analysisData.irritationRisk.level || '低'
          irritationRisk.percentage = analysisData.irritationRisk.percentage || 0
        } else {
          irritationRisk.level = '低'
          irritationRisk.percentage = 0
        }
        
        const allergyRisk: RiskData = {} as RiskData
        if (analysisData.allergyRisk) {
          allergyRisk.level = analysisData.allergyRisk.level || '低'
          allergyRisk.percentage = analysisData.allergyRisk.percentage || 0
        } else {
          allergyRisk.level = '低'
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
        console.log(`📋 安全性指数: ${this.analysis.safetyIndex}`)
        console.log(`📋 功效评分: ${this.analysis.efficacyScore}`)
        console.log(`📋 整体评级: ${this.summary.overallRating}/5.0`)
      } else {
        console.warn('⚠️ 未找到成分分析结果，可能尚未分析')
        // 使用默认值
      }

      this.loading = false
    } catch (error) {
      console.error('❌ Error loading data:', JSON.stringify(error))
      this.error = true
      this.errorMessage = error instanceof Error ? error.message : '加载数据失败，请重试'
      this.loading = false
    }
  }

  async saveProductInfo(data: TagSelectorData) {
    console.log('===== ✏️ 保存产品信息 =====')
    console.log(`📋 保存数据: ${JSON.stringify(data)}`)
    
    this.loading = true
    this.loadingText = '保存产品信息中...'
    this.showTagModal = false

    try {
      if (!this.productId) {
        throw new Error('产品ID无效')
      }

      console.log(`🆔 产品ID: ${this.productId}`)
      console.log(`🏷️ 标签: ${data.tag}`)
      console.log(`📅 开封日期: ${data.openingDate}`)

      // 更新产品标签和开封日期
      const updateData: UpdateProductRequest = {} as UpdateProductRequest
      updateData.label = data.tag || ''
      updateData.openingDate = data.openingDate || ''

      console.log(`📦 更新请求数据: ${JSON.stringify(updateData)}`)

      const response = await this.productApiService.updateProduct(this.productId, updateData)

      console.log(`📡 API 响应: ${JSON.stringify(response)}`)

      if (!response.success) {
        throw new Error(response.message || '保存产品信息失败')
      }

      // 更新本地数据
      this.product.label = data.tag || ''
      this.product.openingDate = data.openingDate || ''

      console.log('✅ 产品信息保存成功')
      this.loading = false

      // Navigate back to product page
      if (this.onBack) {
        this.onBack()
      }
    } catch (error) {
      console.error('❌ Error saving product info:', JSON.stringify(error))
      this.error = true
      this.errorMessage = error instanceof Error ? error.message : '保存产品信息失败，请重试'
      this.loading = false
    }
  }

  async deleteProduct() {
    console.log('===== 🗑️ 删除产品 =====')
    console.log(`🆔 产品ID: ${this.productId}`)
    console.log(`📋 产品名称: ${this.product.name}`)
    
    this.loading = true
    this.loadingText = '删除中...'
    this.showDeleteModal = false

    try {
      if (!this.productId) {
        throw new Error('产品ID无效')
      }

      console.log(`📡 调用删除产品API: DELETE /products/${this.productId}`)
      const response = await this.productApiService.deleteProduct(this.productId)

      console.log(`📡 API 响应: ${JSON.stringify(response)}`)

      if (!response.success) {
        throw new Error(response.message || '删除产品失败')
      }

      console.log('✅ 产品删除成功')

      // Navigate back to product page
      if (this.onBack) {
        this.onBack()
      }
    } catch (error) {
      console.error('❌ Error deleting product:', JSON.stringify(error))
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

