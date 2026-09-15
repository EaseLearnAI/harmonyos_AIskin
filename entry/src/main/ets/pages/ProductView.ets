import { AISkinButton, AISkinStateView } from '../design/AISkinPrimitives'
import { AISkinSpacing, AISkinStateKind } from '../design/Foundation/AISkinTokens'
import { AISkinProcessingScreen } from '../design/AISkinProcessingScreen'
import { AISkinToast } from '../design/AISkinToast'
import { AISkinToastTokens } from '../design/Foundation/AISkinToastTokens'
import { AppHeader } from '../components/common/AppHeader'
import { AddProduct } from '../components/product/AddProduct'
import { ProductList, ProductItem } from '../components/product/ProductList'
import { ProductUploadModal } from '../components/product/ProductUploadModal'
import { ProductApiService } from '../components/product/ProductApiService'
import { ConflictApiService, ConflictAnalysisData } from '../components/product/ConflictApiService'
import { AuthService } from '../services/AuthService'

@Component
export struct ProductView {
  @State products: ProductItem[] = []
  @State loadError: string = ''
  @State loading: boolean = false
  @State conflictMode: boolean = false
  @State selectedProductIds: string[] = []
  @State uploadSource: string = ''
  @State showUploadModal: boolean = false
  @State analyzingConflict: boolean = false
  @Prop autoEnableConflictMode: boolean = false
  @Prop initialSelectedProductId: string = ''
  private productApiService: ProductApiService = ProductApiService.getInstance()
  private conflictApiService: ConflictApiService = ConflictApiService.getInstance()
  private authService: AuthService = AuthService.getInstance()
  private isDestroyed: boolean = false
  private loadGeneration: number = 0
  private conflictGeneration: number = 0
  private uploadBack: (() => boolean) | undefined = undefined
  registerBackHandler?: (handler: () => boolean) => void
  onOverlay?: (visible: boolean) => void
  onNavigateToIngredient?: (productId: string) => void
  onEditProduct?: (productId: string) => void
  onNavigateToConflict?: (conflictData: ConflictAnalysisData) => void
  onBack?: () => void

  aboutToAppear() {
    this.isDestroyed = false
    this.registerBackHandler?.((): boolean => this.handleLocalBack())
    this.loadProducts()
    if (this.autoEnableConflictMode) {
      this.enableConflictMode()
      if (this.initialSelectedProductId) this.selectedProductIds = [this.initialSelectedProductId]
    }
  }

  aboutToDisappear() {
    this.isDestroyed = true
    this.loadGeneration++
    this.conflictGeneration++
    this.registerBackHandler?.((): boolean => false)
    this.onOverlay?.(false)
  }

  handleLocalBack(): boolean {
    if (this.analyzingConflict) { this.cancelAnalysis(); return true }
    if (this.showUploadModal) {
      if (!this.uploadBack?.()) this.closeUpload()
      return true
    }
    if (this.conflictMode) { this.cancelConflictMode(); return true }
    return false
  }

  openUpload(source: string = ''): void {
    this.uploadSource = source
    this.showUploadModal = true
    this.onOverlay?.(true)
  }

  closeUpload(): void {
    this.showUploadModal = false
    this.onOverlay?.(this.analyzingConflict)
  }

  cancelAnalysis(): void {
    this.conflictGeneration++
    this.analyzingConflict = false
    this.onOverlay?.(this.showUploadModal)
  }

  onProfile?: () => void

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '护肤柜', onProfile: this.onProfile, rightIcon: 'plus', rightAccessibilityLabel: '添加产品',
          rightAction: (): void => { this.openUpload() } })
        if (this.loadError) {
          AISkinStateView({ title: '护肤柜加载失败', message: this.loadError, kind: AISkinStateKind.Error, onRetry: (): void => { this.loadProducts() } })
        } else if (this.loading) {
          AISkinStateView({ title: '正在整理护肤柜', kind: AISkinStateKind.Loading })
        } else if (this.products.length === 0) {
          Scroll() {
            AddProduct({ onOpenUploadModal: (source?: string): void => { this.openUpload(source || '') } })
              .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge })
          }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
        } else {
          ProductList({ products: this.products, selectionMode: this.conflictMode, selectedProductIds: this.selectedProductIds,
            onSelectProduct: (product: ProductItem): void => { this.handleSelectProduct(product) },
            onToggleSelection: (productId: string): void => { this.handleToggleSelection(productId) },
            onEditProduct: (product: ProductItem): void => { if (product.id) this.onEditProduct?.(product.id) },
            onDeleteProduct: (productId: string): void => { this.confirmDeleteProduct(productId) },
            onBeginConflict: (productId?: string): void => { this.enableConflictMode(productId) },
            onCancelConflict: (): void => { this.cancelConflictMode() }, onAddProduct: (): void => { this.openUpload('camera') } })
            .width('100%').layoutWeight(1)
        }
        if (this.conflictMode) {
          Column() {
            if (this.selectedProductIds.length >= 2) {
              Column() {
                AISkinButton({ title: '开始检测', onAction: (): void => { this.analyzeConflict() } })
                  .accessibilityText(`开始检测，已选择 ${this.selectedProductIds.length} 个产品`)
              }.width(AISkinToastTokens.floatingActionMaxWidth).constraintSize({ maxWidth: '100%' })
            } else {
              AISkinToast({ message: '请选择 2 个产品进行冲突检测', iconName: 'checkCircle',
                dismissAccessibilityLabel: '退出冲突检测', onDismiss: (): void => { this.cancelConflictMode() } })
            }
          }.width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.xLarge })
        }
      }.width('100%').height('100%').padding({ bottom: AISkinSpacing.xxxLarge + AISkinSpacing.xxLarge })
      if (this.showUploadModal) {
        ProductUploadModal({ showModal: this.showUploadModal, initialSource: this.uploadSource,
          registerBackHandler: (handler: () => boolean): void => { this.uploadBack = handler },
          onClose: (): void => { this.closeUpload() }, onProductAdded: (productId: string): void => { this.handleProductAdded(productId) } })
      }
      if (this.analyzingConflict) { this.AnalyzingConflictOverlay() }
    }.width('100%').height('100%')
  }

  async loadProducts() {
    const generation = ++this.loadGeneration
    console.log('===== 📚 加载用户产品列表 =====')
    this.loading = true
    this.loadError = ''
    
    try {
      // 获取当前用户
      const user = await this.authService.getCurrentUser()
      if (this.isDestroyed || generation !== this.loadGeneration) return
      
      if (!user || !user.id) {
        console.error('❌ 无法获取用户信息')
        this.loading = false
        return
      }

      const userId = user.id

      // 调用API获取产品列表
      const response = await this.productApiService.getUserProducts(userId)
      if (this.isDestroyed || generation !== this.loadGeneration) return

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
            openingDate: product.openingDate || '',
            openingStatus: product.openingStatus || 'unknown'
          }
          return item
        })
      } else {
        console.error('❌ 获取产品列表失败:', response.message)
        this.loadError = response.message || '护肤柜加载失败，请重试'
        this.products = []
      }
    } catch (error) {
      if (this.isDestroyed || generation !== this.loadGeneration) return
      this.loadError = '护肤柜加载失败，请重试'
      console.error('❌ Error loading products')
      this.products = []
    } finally {
      if (!this.isDestroyed && generation === this.loadGeneration) this.loading = false
    }
  }

  handleProductAdded(productId: string) {
    if (this.isDestroyed) return
    this.closeUpload()
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
      this.selectedProductIds = this.selectedProductIds.concat([productId])
    } else {
      this.selectedProductIds = this.selectedProductIds.filter(id => id !== productId)
    }
  }

  async handleDeleteProduct(productId: string) {
    console.log(`===== 🗑️ 删除产品 =====`)
    try {
      const response = await this.productApiService.deleteProduct(productId)
      if (this.isDestroyed) return
      
      if (response.success) {
        console.log('✅ 删除产品成功')
        // 从列表中移除
        this.products = this.products.filter(p => p.id !== productId)
        this.selectedProductIds = this.selectedProductIds.filter(id => id !== productId)
      } else {
        console.error('❌ 删除产品失败:', response.message)
        AlertDialog.show({ title: '删除失败', message: response.message || '请稍后重试', confirm: { value: '知道了', action: () => {} } })
      }
    } catch (error) {
      if (this.isDestroyed) return
      console.error('❌ 删除产品异常')
      AlertDialog.show({ title: '删除失败', message: '请检查网络后重试', confirm: { value: '知道了', action: () => {} } })
    }
  }

  confirmDeleteProduct(productId: string): void {
    const product = this.products.find(item => item.id === productId)
    AlertDialog.show({ title: '删除产品？', message: `删除后将无法恢复“${product?.name || '产品'}”及其分析结果。`,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '删除', action: (): void => { if (!this.isDestroyed) this.handleDeleteProduct(productId) } } })
  }

  enableConflictMode(productId?: string) {
    this.conflictMode = true
    this.selectedProductIds = productId ? [productId] : []
  }

  cancelConflictMode() {
    this.conflictMode = false
    this.selectedProductIds = []
  }

  async analyzeConflict() {
    if (this.analyzingConflict || this.selectedProductIds.length < 2) {
      return
    }

    console.log('===== ⚠️ 开始冲突分析 =====')
    // Show analyzing overlay
    this.analyzingConflict = true
    this.onOverlay?.(true)
    const generation = ++this.conflictGeneration

    try {
      const response = await this.conflictApiService.analyzeConflict(this.selectedProductIds)
      if (this.isDestroyed || generation !== this.conflictGeneration) return

      if (response.success && response.data) {
        console.log('✅ 冲突分析成功')
        // Hide analyzing overlay
        this.analyzingConflict = false
        this.onOverlay?.(false)
        this.cancelConflictMode()
        
        // Navigate to conflict analysis page with response.data
        if (this.onNavigateToConflict) {
          this.onNavigateToConflict(response.data)
        }
      } else {
        AlertDialog.show({ title: '冲突分析失败', message: response.message || '请稍后重试', confirm: { value: '知道了', action: () => {} } })
        this.analyzingConflict = false
        this.onOverlay?.(false)
      }
    } catch (error) {
      if (this.isDestroyed || generation !== this.conflictGeneration) return
      AlertDialog.show({ title: '冲突分析失败', message: '网络请求失败，请重试', confirm: { value: '知道了', action: () => {} } })
      this.analyzingConflict = false
      this.onOverlay?.(false)
    }
  }

  @Builder
  AnalyzingConflictOverlay() {
    AISkinProcessingScreen({ title: '冲突检测', message: '正在核对产品成分与搭配建议', onCancel: (): void => { this.cancelAnalysis() } })
  }
}
