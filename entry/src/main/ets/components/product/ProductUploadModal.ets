import { ProcessingPanel } from '../common/ProcessingPanel'
import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { AISkinButton, AISkinStateView } from '../../design/AISkinPrimitives'
import { AISkinProcessingScreen } from '../../design/AISkinProcessingScreen'
import { Modal } from '../common/Modal'
import { AISkinButtonVariant, AISkinSpacing, AISkinStateKind } from '../../design/Foundation/AISkinTokens'
import { ProductApiService } from './ProductApiService'
import { IngredientAnalysisApiService } from './IngredientAnalysisApiService'
import { ImagePickerService } from '../../services/ImagePickerService'
import { common } from '@kit.AbilityKit'

@Component
export struct ProductUploadModal {
  @Prop showModal: boolean = false
  @Prop initialSource: string = ''
  aboutToAppear() {
    this.isDestroyed = false
    this.registerBackHandler?.((): boolean => { this.handleClose(); return true })
    this.onOverlay?.(true)
    if (this.initialSource) this.requestImageConsent(this.initialSource)
  }
  aboutToDisappear() {
    this.isDestroyed = true
    this.generation++
    this.registerBackHandler?.((): boolean => false)
    this.onOverlay?.(false)
  }
  @State selectedImage: string | null = null
  @State selectedImagePath: string | null = null
  @State productId: string | null = null
  @State isLoading: boolean = false
  @State isExtracting: boolean = false
  @State isAnalyzing: boolean = false
  @State currentStep: number = 0
  @State stepStatus: StepStatus = {
    create: '等待创建',
    upload: '等待上传',
    extract: '等待提取',
    analyze: '等待分析'
  }
  @State modalError: boolean = false
  @State modalErrorMessage: string = ''
  private productApiService: ProductApiService = ProductApiService.getInstance()
  private ingredientAnalysisApiService: IngredientAnalysisApiService = IngredientAnalysisApiService.getInstance()
  private imagePickerService: ImagePickerService = ImagePickerService.getInstance()
  private isDestroyed: boolean = false
  private isPicking: boolean = false
  private generation: number = 0
  registerBackHandler?: (handler: () => boolean) => void
  onOverlay?: (visible: boolean) => void
  onClose?: () => void
  onProductAdded?: (productId: string) => void

  build() {
    if (this.showModal) {
      if (this.isLoading || this.isExtracting || this.isAnalyzing) {
        AISkinProcessingScreen({ title: '成分分析', message: '正在识别产品并整理成分报告', onCancel: (): void => { this.handleClose() } })
      } else {
        Modal({ show: true, title: '添加护肤产品', onClose: (): void => { this.handleClose() }, content: () => { this.UploadContent() }, footer: () => { this.UploadFooter() } })
      }
    }
  }
  @Builder
  UploadContent() {
    Column({ space: AISkinSpacing.medium }) {
      if (this.modalError) { AISkinStateView({ title: '成分分析未完成', message: this.modalErrorMessage, kind: AISkinStateKind.Error, onRetry: (): void => { this.submitProduct() } }) }
      AISkinStateView({ title: '拍一张，就能分析', message: '拍摄或上传清晰的产品成分表，查看主要功效与潜在风险。', kind: AISkinStateKind.Empty })
      AISkinButton({ title: '拍照分析', onAction: (): void => { this.requestImageConsent('camera') } })
      AISkinButton({ title: '从相册上传', variant: AISkinButtonVariant.Secondary, onAction: (): void => { this.requestImageConsent('library') } })
    }.width('100%').padding(AISkinSpacing.screenEdge)
  }
  @Builder
  UploadFooter() { Column() {} }

  canSubmit(): boolean {
    return this.selectedImage !== null
  }

  getSubmitButtonText(): string {
    if (this.isExtracting) return '正在提取成分...'
    if (this.isAnalyzing) return '正在分析成分...'
    return '上传图片并分析'
  }

  handleClose() {
    this.isDestroyed = true
    this.generation++
    this.resetModal()
    this.onOverlay?.(false)
    if (this.onClose) {
      this.onClose()
    }
  }

  requestImageConsent(source: string = 'library'): void {
    if (this.isDestroyed || this.isPicking || this.isLoading) return
    AlertDialog.show({ title: '确认AI图片处理', message: '你选择的产品图片将上传至阿里云对象存储并交由通义千问模型识别成分、生成分析报告。图片和结果保存在账号中，可随产品或账号一并删除。请避免上传含个人信息的图片。',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '同意并选择图片', action: () => { this.handleSelectImage(source) } } })
  }

  async handleSelectImage(source: string = 'library') {
    if (this.isDestroyed || this.isPicking || this.isLoading) return
    const generation = ++this.generation
    this.isPicking = true
    console.log('===== 🖼️ 启动照片选择功能 =====')
    console.log('📱 在 ProductUploadModal 中处理图片选择')
    
    try {
      // 获取应用上下文
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      console.log(`📋 已获取应用上下文`)
      
      // 从相册选择图片
      console.log('📂 调用 ImagePickerService.selectFromGallery...')
      const pickResult = source === 'camera' ? await this.imagePickerService.takePhoto(context) : await this.imagePickerService.selectFromGallery(context)
      if (this.isDestroyed || generation !== this.generation) return
      this.isPicking = false
      
      if (pickResult.success && pickResult.filePath) {
        console.log('✅ 已选择图片')
        console.log(`📸 设置 selectedImagePath 和 selectedImage`)
        this.selectedImagePath = pickResult.filePath
        this.selectedImage = pickResult.filePath
        this.modalError = false
        console.log(`✅ 图片状态已更新，自动开始分析流程`)
        // 自动开始执行分析流程
        this.submitProduct()
      } else {
        console.log(`ℹ️ 用户取消选择或选择失败: ${pickResult.message || '未知错误'}`)
      }
    } catch (error) {
      if (this.isDestroyed || generation !== this.generation) return
      console.error('❌ 选择图片失败')
      this.modalError = true
      this.modalErrorMessage = '选择图片失败，请重试'
    } finally {
      if (!this.isDestroyed && generation === this.generation) this.isPicking = false
    }
  }

  async submitProduct() {
    if (this.isDestroyed || this.isLoading || !this.canSubmit() || !this.selectedImagePath) return
    const generation = ++this.generation
    const imagePath = this.selectedImagePath

    this.isLoading = true
    this.modalError = false
    this.currentStep = 1
    this.stepStatus.create = '创建中...'

    try {
      // Keep the draft product on retry instead of creating a duplicate.
      if (!this.productId) {
      const createResponse = await this.productApiService.createProduct({
        name: '未命名产品',
        description: '这是一个用于成分分析的产品',
        label: ''
      })
      if (this.isDestroyed || generation !== this.generation) return

      if (!createResponse.success || !createResponse.data?.product) {
        throw new Error(createResponse.message || '创建产品失败')
      }

      this.productId = createResponse.data.product._id || createResponse.data.product.id || null
      if (!this.productId) {
        throw new Error('无法获取产品ID')
      }

      }
      this.stepStatus.create = '创建成功'
      this.currentStep = 2

      // Step 2: Upload image
      this.stepStatus.upload = '上传中...'
      const uploadResponse = await this.productApiService.uploadProductImage(this.productId, imagePath)
      if (this.isDestroyed || generation !== this.generation) return

      if (!uploadResponse.success) {
        throw new Error(uploadResponse.message || '上传图片失败')
      }

      this.stepStatus.upload = '上传成功'
      this.currentStep = 3

      // Step 3: Extract ingredients
      this.isExtracting = true
      this.stepStatus.extract = '提取中...'
      const extractResponse = await this.productApiService.extractIngredients(this.productId)
      if (this.isDestroyed || generation !== this.generation) return

      if (!extractResponse.success) {
        throw new Error(extractResponse.message || '提取成分失败')
      }

      const ingredientCount = extractResponse.data?.ingredients?.length || 0
      this.stepStatus.extract = `提取成功，识别到${ingredientCount}种成分`
      this.currentStep = 4
      this.isExtracting = false

      // Step 4: Analyze ingredients
      this.isAnalyzing = true
      this.stepStatus.analyze = '分析中...'
      const analyzeResponse = await this.ingredientAnalysisApiService.analyzeIngredients(this.productId)
      if (this.isDestroyed || generation !== this.generation) return

      if (!analyzeResponse.success) {
        throw new Error(analyzeResponse.message || '分析成分失败')
      }

      this.stepStatus.analyze = '分析成功'
      this.currentStep = 5
      this.isAnalyzing = false

      // Complete
      const completedProductId = this.productId
      this.isLoading = false
      this.handleClose()
      if (completedProductId) this.onProductAdded?.(completedProductId)
    } catch (error) {
      if (this.isDestroyed || generation !== this.generation) return
      console.error('❌ Error submitting product')
      this.modalError = true
      this.modalErrorMessage = error instanceof Error ? error.message : '处理失败，请重试'
      
      // Update step status based on error
      if (this.currentStep === 1) {
        this.stepStatus.create = '创建失败'
      } else if (this.currentStep === 2) {
        this.stepStatus.upload = '上传失败'
      } else if (this.currentStep === 3) {
        this.stepStatus.extract = '提取失败'
        this.isExtracting = false
      } else if (this.currentStep === 4) {
        this.stepStatus.analyze = '分析失败'
        this.isAnalyzing = false
      }
    } finally {
      if (!this.isDestroyed && generation === this.generation) this.isLoading = false
    }
  }

  resetModal() {
    this.isLoading = false
    this.isExtracting = false
    this.isAnalyzing = false
    this.isPicking = false
    this.selectedImage = null
    this.selectedImagePath = null
    this.productId = null
    this.currentStep = 0
    this.modalError = false
    this.modalErrorMessage = ''
    this.stepStatus = {
      create: '等待创建',
      upload: '等待上传',
      extract: '等待提取',
      analyze: '等待分析'
    }
  }
}

// Data Models
interface StepStatus {
  create: string
  upload: string
  extract: string
  analyze: string
}
