import { AppHeader } from '../components/common/AppHeader'
import { AddProduct } from '../components/product/AddProduct'
import { ProductList, ProductItem } from '../components/product/ProductList'
import { ProductUploadModal } from '../components/product/ProductUploadModal'
import { ProductApiService } from '../components/product/ProductApiService'
import { ConflictApiService, ConflictAnalysisData } from '../components/product/ConflictApiService'
import { AuthService } from '../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct ProductView {
  @State products: ProductItem[] = []
  @State loading: boolean = false
  @State conflictMode: boolean = false
  @State selectedProductIds: string[] = []
  @State showUploadModal: boolean = false
  @State analyzingConflict: boolean = false
  @Prop autoEnableConflictMode: boolean = false
  private productApiService: ProductApiService = ProductApiService.getInstance()
  private conflictApiService: ConflictApiService = ConflictApiService.getInstance()
  private authService: AuthService = AuthService.getInstance()
  onNavigateToIngredient?: (productId: string) => void
  onNavigateToConflict?: (conflictData: ConflictAnalysisData) => void
  onBack?: () => void

  aboutToAppear() {
    this.loadProducts()
    if (this.autoEnableConflictMode) {
      this.enableConflictMode()
    }
  }

  build() {
    Stack() {
      Column() {
        // Header
        AppHeader({
          title: '护肤产品库',
          icon: 'paw',
          showBackButton: false,
          bgColor: 'bg-sakura'
        })
        .width('100%')

        // Main Content - Fixed layout, no scroll
        Column() {
          // Add Product Component
          AddProduct({
            showUploadModal: this.showUploadModal,
            onOpenUploadModal: () => {
              this.showUploadModal = true
            },
            onEnableConflictMode: () => {
              this.enableConflictMode()
            }
          })
          .margin({ top: 14, left: 14, right: 14, bottom: 12 })

          // Conflict Mode Header
          if (this.conflictMode) {
            this.ConflictModeHeader()
          }

          // Product List - Scrollable
          Scroll() {
            ProductList({
              products: this.products,
              selectionMode: this.conflictMode,
              selectedProductIds: this.selectedProductIds,
              onSelectProduct: (product: ProductItem) => {
                this.handleSelectProduct(product)
              },
              onToggleSelection: (productId: string) => {
                this.handleToggleSelection(productId)
              },
              onDeleteProduct: (productId: string) => {
                this.handleDeleteProduct(productId)
              }
            })
            .width('100%')
            .margin({ left: 14, right: 14 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#fff9fb')

      // Upload Modal - Floating on top
      if (this.showUploadModal) {
        ProductUploadModal({
          showModal: this.showUploadModal,
          onClose: () => {
            this.showUploadModal = false
          },
          onProductAdded: (productId: string) => {
            this.handleProductAdded(productId)
          }
        })
        .width('100%')
        .height('100%')
        .zIndex(9999)
      }

      // Analyzing Conflict Loading Overlay
      if (this.analyzingConflict) {
        this.AnalyzingConflictOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ConflictModeHeader() {
    Column() {
      Row() {
        Row() {
          Text('⚠️')
            .fontSize(16)
            .margin({ right: 8 })
          Text('选择需要检测冲突的产品')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .layoutWeight(1)

        Button('分析冲突')
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(this.selectedProductIds.length >= 2 ? '#CE93D8' : '#E0E0E0')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(6)
          .enabled(this.selectedProductIds.length >= 2)
          .margin({ right: 8 })
          .onClick(() => {
            this.analyzeConflict()
          })

        Button('取消')
          .fontSize(12)
          .fontColor('#757575')
          .backgroundColor('#f5f5f5')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(6)
          .onClick(() => {
            this.cancelConflictMode()
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(`已选择 ${this.selectedProductIds.length} 个产品 (至少需要2个)`)
        .fontSize(12)
        .fontColor('#757575')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 14, right: 14, bottom: 12 })
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  async loadProducts() {
    console.log('===== 📚 加载用户产品列表 =====')
    this.loading = true
    
    try {
      // 获取当前用户
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      const user = await this.authService.getCurrentUser()
      
      if (!user || !user.id) {
        console.error('❌ 无法获取用户信息')
        this.loading = false
        return
      }

      const userId = user.id
      console.log(`📊 用户ID: ${userId}`)

      // 调用API获取产品列表
      const response = await this.productApiService.getUserProducts(userId)

      if (response.success && response.data) {
        const products = response.data.products || []
        console.log(`✅ 产品列表加载成功，共${products.length}个产品`)

        // 转换为ProductItem格式
        this.products = products.map((product): ProductItem => {
          const item: ProductItem = {
            id: product._id || product.id || '',
            name: product.name || '未命名产品',
            description: product.description || '暂无描述',
            imageUrl: product.imageUrl || '',
            label: product.label || '',
            safetyScore: product.safetyScore,
            efficacyScore: product.efficacyScore,
            overallRating: product.overallRating,
            openingDate: product.openingDate || product.createdAt || new Date().toISOString()
          }
          return item
        })
      } else {
        console.error('❌ 获取产品列表失败:', response.message)
        this.products = []
      }
    } catch (error) {
      console.error('❌ Error loading products:', JSON.stringify(error))
      this.products = []
    } finally {
      this.loading = false
    }
  }

  handleProductAdded(productId: string) {
    // Reload products after adding
    this.loadProducts()
    
    // Navigate to ingredient view
    if (this.onNavigateToIngredient) {
      this.onNavigateToIngredient(productId)
    }
  }

  handleSelectProduct(product: ProductItem) {
    // Navigate to ingredient view
    if (product.id && this.onNavigateToIngredient) {
      this.onNavigateToIngredient(product.id)
    }
  }

  handleToggleSelection(productId: string) {
    const index = this.selectedProductIds.indexOf(productId)
    if (index === -1) {
      this.selectedProductIds.push(productId)
    } else {
      this.selectedProductIds.splice(index, 1)
    }
  }

  async handleDeleteProduct(productId: string) {
    console.log(`===== 🗑️ 删除产品 =====`)
    console.log(`🆔 产品ID: ${productId}`)

    try {
      const response = await this.productApiService.deleteProduct(productId)
      
      if (response.success) {
        console.log('✅ 删除产品成功')
        // 从列表中移除
        this.products = this.products.filter(p => p.id !== productId)
      } else {
        console.error('❌ 删除产品失败:', response.message)
      }
    } catch (error) {
      console.error('❌ 删除产品异常:', JSON.stringify(error))
    }
  }

  enableConflictMode() {
    this.conflictMode = true
    this.selectedProductIds = []
  }

  cancelConflictMode() {
    this.conflictMode = false
    this.selectedProductIds = []
  }

  async analyzeConflict() {
    if (this.selectedProductIds.length < 2) {
      return
    }

    console.log('===== ⚠️ 开始冲突分析 =====')
    console.log(`📊 分析产品: ${this.selectedProductIds.join(', ')}`)

    // Show analyzing overlay
    this.analyzingConflict = true

    try {
      const response = await this.conflictApiService.analyzeConflict(this.selectedProductIds)

      if (response.success && response.data) {
        console.log('✅ 冲突分析成功')
        console.info('冲突分析结果:', JSON.stringify(response.data))
        
        // Hide analyzing overlay
        this.analyzingConflict = false
        
        // Navigate to conflict analysis page with response.data
        if (this.onNavigateToConflict) {
          this.onNavigateToConflict(response.data)
        }
      } else {
        console.error('❌ 冲突分析失败:', response.message)
        this.analyzingConflict = false
      }
    } catch (error) {
      console.error('❌ 冲突分析异常:', JSON.stringify(error))
      this.analyzingConflict = false
    }

    this.cancelConflictMode()
  }

  @Builder
  AnalyzingConflictOverlay() {
    Column() {
      Column() {
        LoadingProgress()
          .width(60)
          .height(60)
          .color('#F8BBD0')
          .margin({ bottom: 20 })

        Text('正在分析冲突...')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text('请稍候，正在检测产品成分冲突')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width(280)
      .padding(32)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({
        radius: 20,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .justifyContent(FlexAlign.Center)
    .zIndex(10000)
  }
}

