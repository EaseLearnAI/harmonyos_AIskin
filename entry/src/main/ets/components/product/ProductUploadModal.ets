import { ProcessingPanel } from '../common/ProcessingPanel'
import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { ImageUploader } from './ImageUploader'
import { ProductApiService } from './ProductApiService'
import { IngredientAnalysisApiService } from './IngredientAnalysisApiService'
import { ImagePickerService } from '../../services/ImagePickerService'
import { common } from '@kit.AbilityKit'

@Component
export struct ProductUploadModal {
  @Prop showModal: boolean = false
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
  onClose?: () => void
  onProductAdded?: (productId: string) => void

  build() {
    if (this.showModal) {
      this.ModalContent()
    }
  }

  @Builder
  ModalContent() {
    // Full screen backdrop with blur
    Stack({ alignContent: Alignment.Center }) {
      // Modal Content
      Stack() {
        Column() {
          // Modal Header with Title and Close Button
          Row() {
            Blank()
            Text('添加护肤产品')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(AISkinColor.text)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button() {
              Text('✕')
                .fontSize(18)
                .fontColor(AISkinColor.secondary)
            }
            .type(ButtonType.Circle)
            .width(36)
            .height(36)
            .backgroundColor(AISkinColor.muted)
            .onClick(() => {
              this.handleClose()
            })
          }
          .width('100%')
          .padding({ top: 16, bottom: 16, left: 24, right: 24 })

          // Subtitle
          Text('上传产品图片，AI将自动识别产品成分并进行分析')
            .fontSize(14)
            .fontColor(AISkinColor.secondary)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20, left: 24, right: 24 })

          // Error Message
          if (this.modalError) {
            Row() {
              Text('⚠️')
                .fontSize(16)
                .margin({ right: 8 })
              Text(this.modalErrorMessage)
                .fontSize(14)
                .fontColor(AISkinColor.danger)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(AISkinColor.dangerSurface)
            .borderRadius(12)
            .margin({ bottom: 20, left: 24, right: 24 })
          }

          // Image Uploader (只在未开始分析时显示)
          if (this.currentStep === 0 && !this.isLoading && !this.isExtracting && !this.isAnalyzing) {
            ImageUploader({
              placeholder: '点击选择产品图片',
              imagePath: this.selectedImagePath,
              onImageSelected: (image: string) => {
                console.log(`===== 📸 图片已选择回调 =====`)
                this.selectedImage = image
                this.selectedImagePath = image
                this.modalError = false
                console.log(`✅ 图片状态已更新，自动开始分析流程`)
                // 自动开始执行分析流程
                this.submitProduct()
              },
              onImageRemoved: () => {
                console.log(`===== 🗑️ 图片已移除 =====`)
                this.selectedImage = null
                this.selectedImagePath = null
              },
              onSelectImage: () => {
                this.requestImageConsent()
              }
            })
            .margin({ bottom: 20, left: 24, right: 24 })
          }

          if (this.currentStep > 0 && !this.modalError) {
            ProcessingPanel({ title: '成分分析', message: '正在识别产品并整理成分报告' })
          }

          Blank()

          // Submit Button (只在未开始分析时显示)
          if (this.currentStep === 0 && !this.isLoading && !this.isExtracting && !this.isAnalyzing) {
            Button(this.getSubmitButtonText())
              .width('100%')
              .height(44)
              .backgroundColor(this.canSubmit() ? AISkinColor.primary : AISkinColor.divider)
              .fontColor(this.canSubmit() ? Color.White : AISkinColor.secondary)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(12)
              .enabled(this.canSubmit() && !this.isLoading && !this.isExtracting && !this.isAnalyzing)
              .margin({ left: 24, right: 24, bottom: 24 })
              .onClick(() => {
                this.submitProduct()
              })
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('90%')
      .attributeModifier(new CardStyle()).backgroundColor(AISkinColor.dialog)
      .constraintSize({ maxHeight: '90%' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .onClick(() => {
      this.handleClose()
    })
  }

  @Builder
  ProgressStep(step: number, title: string, status: string) {
    Row() {
      Column() {
        Text(step.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentStep >= step ? Color.White : AISkinColor.secondary)
      }
      .width(28)
      .height(28)
      .backgroundColor(this.currentStep >= step ? AISkinColor.primary : AISkinColor.divider)
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      Column() {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 2 })

        Text(status)
          .fontSize(12)
          .fontColor(AISkinColor.secondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .margin({ bottom: 6 })
    .opacity(this.currentStep >= step ? 1 : 0.5)
  }

  canSubmit(): boolean {
    return this.selectedImage !== null
  }

  getSubmitButtonText(): string {
    if (this.isExtracting) return '正在提取成分...'
    if (this.isAnalyzing) return '正在分析成分...'
    return '上传图片并分析'
  }

  handleClose() {
    this.resetModal()
    if (this.onClose) {
      this.onClose()
    }
  }

  requestImageConsent(): void {
    AlertDialog.show({ title: '确认AI图片处理', message: '你选择的产品图片将上传至阿里云对象存储并交由通义千问模型识别成分、生成分析报告。图片和结果保存在账号中，可随产品或账号一并删除。请避免上传含个人信息的图片。',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '同意并选择图片', action: () => { this.handleSelectImage() } } })
  }

  async handleSelectImage() {
    console.log('===== 🖼️ 启动照片选择功能 =====')
    console.log('📱 在 ProductUploadModal 中处理图片选择')
    
    try {
      // 获取应用上下文
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      console.log(`📋 已获取应用上下文`)
      
      // 从相册选择图片
      console.log('📂 调用 ImagePickerService.selectFromGallery...')
      const pickResult = await this.imagePickerService.selectFromGallery(context)
      
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
      console.error('❌ 选择图片失败')
      this.modalError = true
      this.modalErrorMessage = '选择图片失败，请重试'
    }
  }

  async submitProduct() {
    if (!this.canSubmit() || !this.selectedImagePath) return

    this.isLoading = true
    this.modalError = false
    this.currentStep = 1
    this.stepStatus.create = '创建中...'

    try {
      // Step 1: Create product
      const createResponse = await this.productApiService.createProduct({
        name: '未命名产品',
        description: '这是一个用于成分分析的产品',
        label: ''
      })

      if (!createResponse.success || !createResponse.data?.product) {
        throw new Error(createResponse.message || '创建产品失败')
      }

      this.productId = createResponse.data.product._id || createResponse.data.product.id || null
      if (!this.productId) {
        throw new Error('无法获取产品ID')
      }

      this.stepStatus.create = '创建成功'
      this.currentStep = 2

      // Step 2: Upload image
      this.stepStatus.upload = '上传中...'
      const uploadResponse = await this.productApiService.uploadProductImage(this.productId, this.selectedImagePath)

      if (!uploadResponse.success) {
        throw new Error(uploadResponse.message || '上传图片失败')
      }

      this.stepStatus.upload = '上传成功'
      this.currentStep = 3

      // Step 3: Extract ingredients
      this.isExtracting = true
      this.stepStatus.extract = '提取中...'
      const extractResponse = await this.productApiService.extractIngredients(this.productId)

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

      if (!analyzeResponse.success) {
        throw new Error(analyzeResponse.message || '分析成分失败')
      }

      this.stepStatus.analyze = '分析成功'
      this.currentStep = 5
      this.isAnalyzing = false

      // Complete
      if (this.onProductAdded && this.productId) {
        this.onProductAdded(this.productId)
      }

      this.handleClose()
    } catch (error) {
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
      this.isLoading = false
    }
  }

  resetModal() {
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
