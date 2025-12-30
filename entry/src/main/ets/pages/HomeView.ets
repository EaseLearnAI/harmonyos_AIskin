import { AppHeader } from '../components/common/AppHeader'
import { CoreFeatures } from '../components/home/CoreFeatures'
import { TwentyOneDayPlanCard } from '../components/home/TwentyOneDayPlanCard'
import { DailyRoutine } from '../components/home/DailyRoutine'
import { PersonalizedRoutineModal } from '../components/home/PersonalizedRoutineModal'
import { PlanApiService, PlanData, PlanStep } from '../components/plan/PlanApiService'

@Component
export struct HomeView {
  @State morningRoutine: RoutineItem[] = []
  @State eveningRoutine: RoutineItem[] = []
  @State recommendations: string[] = []
  @State loading: boolean = false
  @State hasPlan: boolean = false
  @State planId: string = ''
  @State showPersonalizedRoutineModal: boolean = false
  private planApiService: PlanApiService = PlanApiService.getInstance()
  onNavigate?: (route: string, params?: ProductViewParams) => void

  build() {
    Stack() {
      Column() {
        // Header
        AppHeader({ 
        title: '析肤护肤助手',
        icon: 'paw',
        bgColor: 'bg-sakura'
      })
      .width('100%')

      // Main Content
      Scroll() {
        Column() {
          // Core Features
          CoreFeatures({ 
            onNavigate: (route: string, params?: ProductViewParams) => {
              if (this.onNavigate) {
                this.onNavigate(route, params)
              }
            },
            onShowPersonalizedRoutineModal: () => {
              this.showPersonalizedRoutineModal = true
            }
          })
          .margin({ top: 14, left: 14, right: 12, bottom: 12 })

          // 21 Day Plan Card
          TwentyOneDayPlanCard()
            .margin({ left: 14, right: 14, bottom: 4, top: 6 })

          // Daily Routine
          if (this.loading) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#F8BBD0')
                .margin({ top: 40, bottom: 20 })

              Text('加载中...')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          } else if (this.hasPlan) {
            DailyRoutine({
              planId: this.planId,
              morningRoutine: this.morningRoutine,
              eveningRoutine: this.eveningRoutine,
              recommendations: this.recommendations,
              onRoutineUpdate: (morning: RoutineItem[], evening: RoutineItem[], recommendations: string[]) => {
                this.morningRoutine = morning
                this.eveningRoutine = evening
                this.recommendations = recommendations
              }
            })
            .margin({ left: 12, right: 12, bottom: 12 })
          } else {
            Column() {
              Text('暂无护肤计划')
                .fontSize(18)
                .fontColor('#888888')
                .margin({ top: 40 })
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .padding({ left: 0, right: 0, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#fff9fb')

      // Personalized Routine Modal - Floating on top of entire page
      if (this.showPersonalizedRoutineModal) {
        PersonalizedRoutineModal({
          onClose: () => {
            this.showPersonalizedRoutineModal = false
          },
          onSaveRoutine: (data: PlanSaveData) => {
            this.handleSaveRoutine(data)
            this.showPersonalizedRoutineModal = false
          }
        })
        .width('100%')
        .height('100%')
        .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear() {
    this.fetchRoutine()
  }

  async fetchRoutine() {
    console.log('===== 📚 获取我的护肤方案 =====')
    this.loading = true

    try {
      // 步骤1: 获取所有方案列表
      console.log('📡 步骤1: 获取方案列表')
      const plansResponse = await this.planApiService.getAllPlans()

      if (plansResponse.success && plansResponse.data && plansResponse.data.plans && plansResponse.data.plans.length > 0) {
        // 获取最新的方案（按创建时间排序，第一个是最新的）
        const latestPlan = plansResponse.data.plans[0]
        const planId = latestPlan._id || latestPlan.id || ''
        
        console.log('✅ 找到最新方案')
        console.log('📋 方案ID:', planId)
        console.log('📋 方案名称:', latestPlan.name)

        // 步骤2: 获取方案详情
        console.log('📡 步骤2: 获取方案详情')
        const planResponse = await this.planApiService.getPlan(planId)

        if (planResponse.success && planResponse.data && planResponse.data.plan) {
          const plan = planResponse.data.plan
          
          // 转换数据格式
          this.morningRoutine = (plan.morning || []).map((step: PlanStep): RoutineItem => ({
            step: step.step || 0,
            product: step.product || '',
            completed: step.completed || false
          }))
          
          this.eveningRoutine = (plan.evening || []).map((step: PlanStep): RoutineItem => ({
            step: step.step || 0,
            product: step.product || '',
            completed: step.completed || false
          }))
          
          this.recommendations = plan.recommendations || []
          this.planId = planId
          this.hasPlan = true

          console.log('✅ 方案加载成功')
          console.log('📊 早晨步骤数:', this.morningRoutine.length)
          console.log('📊 晚间步骤数:', this.eveningRoutine.length)
          console.log('📊 建议数:', this.recommendations.length)
        } else {
          console.warn('⚠️ 获取方案详情失败，使用列表数据')
          // 如果获取详情失败，使用列表数据
          this.morningRoutine = (latestPlan.morning || []).map((step: PlanStep): RoutineItem => ({
            step: step.step || 0,
            product: step.product || '',
            completed: step.completed || false
          }))
          
          this.eveningRoutine = (latestPlan.evening || []).map((step: PlanStep): RoutineItem => ({
            step: step.step || 0,
            product: step.product || '',
            completed: step.completed || false
          }))
          
          this.recommendations = latestPlan.recommendations || []
          this.planId = planId
          this.hasPlan = true
        }
      } else {
        console.log('ℹ️ 暂无方案')
        this.hasPlan = false
      }
    } catch (error) {
      console.error('❌ 获取方案失败:', JSON.stringify(error))
      this.hasPlan = false
    } finally {
      this.loading = false
    }
  }

  handleSaveRoutine(data: PlanSaveData) {
    console.log('===== 💾 保存方案到我的方案 =====')
    console.log('📋 方案ID:', data.planId)
    console.log('📋 方案名称:', data.plan.name)

    const plan = data.plan
    
    // 转换数据格式
    this.morningRoutine = (plan.morning || []).map((step: PlanStep): RoutineItem => ({
      step: step.step || 0,
      product: step.product || '',
      completed: step.completed || false
    }))
    
    this.eveningRoutine = (plan.evening || []).map((step: PlanStep): RoutineItem => ({
      step: step.step || 0,
      product: step.product || '',
      completed: step.completed || false
    }))
    
    this.recommendations = plan.recommendations || []
    this.planId = data.planId
    this.hasPlan = true

    console.log('✅ 方案保存成功')
    console.log('📊 早晨步骤数:', this.morningRoutine.length)
    console.log('📊 晚间步骤数:', this.eveningRoutine.length)
    console.log('📊 建议数:', this.recommendations.length)
  }
}

// Data Models
interface RoutineItem {
  step?: number
  product?: string
  completed?: boolean
}

interface PlanSaveData {
  planId: string
  plan: PlanData
}

interface ProductViewParams {
  autoEnableConflictMode?: boolean
}

