import { PersonalizedRoutinePreview } from './PersonalizedRoutinePreview'
import { PlanApiService, PlanData, CreatePlanRequest, PlanStep } from '../plan/PlanApiService'
import { SkinAnalysisApiService } from '../../services/SkinAnalysisApiService'

@Component
export struct PersonalizedRoutineModal {
  @State loadingPlan: boolean = false
  @State planError: string | null = null
  @State generatedPlan: PlanData | null = null
  @State selectedConcerns: string[] = []
  @State userAge: string = ''
  @State customRequirements: string = ''
  private planApiService: PlanApiService = PlanApiService.getInstance()
  private skinAnalysisApiService: SkinAnalysisApiService = SkinAnalysisApiService.getInstance()
  onClose?: () => void
  onSaveRoutine?: (data: PlanSaveData) => void

  // Predefined options
  private skinConcerns: ConcernOption[] = [
    { label: '补水', value: 'hydration' },
    { label: '美白', value: 'brightening' },
    { label: '抗老', value: 'anti-aging' },
    { label: '控油', value: 'oil-control' },
    { label: '修护', value: 'repair' },
    { label: '祛痘', value: 'acne' }
  ]

  build() {
    // Modal Overlay
    Stack({ alignContent: Alignment.Center }) {
      // Modal Content
      Column() {
        // Modal Header
        Row() {
          Row() {
            Text('✨')
              .fontSize(18)
              .margin({ right: 8 })
            Text('个性化护肤方案')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
          .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(24)
              .fontColor('#6B7280')
          }
          .type(ButtonType.Normal)
          .width(36)
          .height(36)
          .borderRadius(18)
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            if (this.onClose) {
              this.onClose()
            }
          })
        }
        .width('100%')
        .margin({ bottom: 24 })
        .padding({ bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#E5E7EB',
          style: BorderStyle.Solid
        })

        if (this.loadingPlan) {
          this.LoadingState()
        } else if (this.planError) {
          this.ErrorState()
        } else if (!this.generatedPlan) {
          this.InputState()
        } else {
          Column() {
            PersonalizedRoutinePreview({ 
              plan: this.generatedPlan,
              onSaveRoutine: () => {
                if (this.generatedPlan && this.onSaveRoutine) {
                  console.log('===== 💾 保存方案到我的方案 =====')
                  console.log('📋 方案ID:', this.generatedPlan._id || this.generatedPlan.id)
                  console.log('📋 方案名称:', this.generatedPlan.name)
                  
                  // 传递完整的 PlanData，包含 planId
                  const planSaveData: PlanSaveData = {
                    planId: this.generatedPlan._id || this.generatedPlan.id || '',
                    plan: this.generatedPlan
                  }
                  this.onSaveRoutine(planSaveData)
                }
              },
              onCustomizeRoutine: () => {
                this.generatedPlan = null
                this.selectedConcerns = []
                this.customRequirements = ''
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('90%')
      .height('75%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
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
    .onClick(() => {
      if (this.onClose) {
        this.onClose()
      }
    })
  }

  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#F8BBD0')
        .margin({ bottom: 16 })

      Text('AI正在为您定制专属护肤方案...')
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorState() {
    Column() {
      Text(this.planError || '获取失败')
        .fontSize(14)
        .fontColor('#d32f2f')
        .padding(16)
        .backgroundColor('#FFEBEE')
        .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  InputState() {
    Scroll() {
      Column() {
        Text('请告诉我您的护肤需求，AI将结合您的个人信息和最新肌肤状态为您定制个性化护肤方案。')
          .fontSize(15)
          .fontColor('#666666')
          .lineHeight(22)
          .margin({ bottom: 12 })

        // Age Input
        Column() {
          Text('年龄')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.Start)

          TextInput({ placeholder: '请输入您的年龄', text: this.userAge })
            .width('100%')
            .height(44)
            .borderRadius(10)
            .backgroundColor('#F5F5F5')
            .padding({ left: 16, right: 16 })
            .type(InputType.Number)
            .fontSize(15)
            .fontColor('#333333')
            .onChange((value: string) => {
              this.userAge = value
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 24 })

        // Skin Concerns
        Column() {
          Text('护肤需求')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.Start)

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.skinConcerns, (concern: ConcernOption) => {
              Button(concern.label)
                .fontSize(14)
                .fontColor(this.selectedConcerns.includes(concern.value) ? '#F8BBD0' : '#6c757d')
                .backgroundColor(this.selectedConcerns.includes(concern.value) ? '#FFF0F5' : '#F8F9FA')
                .border({
                  width: 1,
                  color: this.selectedConcerns.includes(concern.value) ? '#F8BBD0' : '#E9ECEF',
                  style: BorderStyle.Solid
                })
                .borderRadius(20)
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.toggleConcern(concern.value)
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 24 })

        // Custom Requirements
        Column() {
          Text('其他需求（可选）')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.Start)

          TextArea({ placeholder: '描述您的其他特殊需求，如敏感肌、特定产品偏好等...', text: this.customRequirements })
            .width('100%')
            .height(100)
            .borderRadius(10)
            .backgroundColor('#F5F5F5')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .fontSize(15)
            .fontColor('#333333')
            .placeholderColor('#9e9e9e')
            .onChange((value: string) => {
              this.customRequirements = value
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })

        // Generate Button
        Button('✨ 开始生成')
          .width('100%')
          .height(48)
          .backgroundColor(this.canGenerate() ? '#F8BBD0' : '#E0E0E0')
          .fontColor(this.canGenerate() ? Color.White : '#999999')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(12)
          .enabled(this.canGenerate())
          .onClick(() => {
            this.generatePersonalizedPlan()
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    }
    .layoutWeight(1)
  }

  toggleConcern(concern: string) {
    const index = this.selectedConcerns.indexOf(concern)
    if (index === -1) {
      if (this.selectedConcerns.length < 3) {
        this.selectedConcerns.push(concern)
      }
    } else {
      this.selectedConcerns.splice(index, 1)
    }
  }

  canGenerate(): boolean {
    return this.userAge.length > 0 && this.selectedConcerns.length > 0
  }

  async generatePersonalizedPlan() {
    console.log('===== 🚀 开始生成个性化护肤方案 =====')
    this.loadingPlan = true
    this.planError = null

    try {
      // 步骤1: 准备请求数据
      console.log('📋 步骤1: 准备请求数据')
      const age = parseInt(this.userAge)
      if (isNaN(age) || age <= 0) {
        throw new Error('请输入有效的年龄')
      }

      const planRequest: CreatePlanRequest = {
        requirement: this.customRequirements || undefined,
        skinConcerns: this.selectedConcerns.length > 0 ? this.selectedConcerns : undefined,
        customRequirements: this.customRequirements || undefined,
        age: age
      }

      console.log('📊 请求参数:', {
        年龄: age,
        护肤关注点: this.selectedConcerns,
        自定义需求: this.customRequirements || '无'
      })

      // 步骤2: 调用API创建方案
      console.log('📡 步骤2: 调用API创建方案')
      const response = await this.planApiService.createPlan(planRequest)

      if (response.success && response.data && response.data.plan) {
        console.log('✅ 方案生成成功')
        this.generatedPlan = response.data.plan
        this.loadingPlan = false
        
        console.log('🎉 方案生成流程完成！')
        console.log('📋 生成的方案:', {
          方案ID: this.generatedPlan._id || this.generatedPlan.id,
          方案名称: this.generatedPlan.name,
          早晨步骤数: this.generatedPlan.morning?.length || 0,
          晚间步骤数: this.generatedPlan.evening?.length || 0,
          建议数: this.generatedPlan.recommendations?.length || 0
        })
      } else {
        console.error('❌ 方案生成失败:', response.message)
        this.planError = response.message || '生成方案失败，请重试'
        this.loadingPlan = false
      }
    } catch (error) {
      console.error('❌ 生成方案异常:', JSON.stringify(error))
      const errorMessage = error instanceof Error ? error.message : '生成方案失败，请重试'
      this.planError = errorMessage
      this.loadingPlan = false
    }
  }
}

// Data Models
interface ConcernOption {
  label: string
  value: string
}

interface PlanSaveData {
  planId: string
  plan: PlanData
}

