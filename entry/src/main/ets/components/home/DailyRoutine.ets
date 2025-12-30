import { PlanApiService, PlanStep } from '../plan/PlanApiService'

@Component
export struct DailyRoutine {
  @Prop planId: string = ''
  @Prop morningRoutine: RoutineItem[] = []
  @Prop eveningRoutine: RoutineItem[] = []
  @Prop recommendations: string[] = []
  onRoutineUpdate?: (morning: RoutineItem[], evening: RoutineItem[], recommendations: string[]) => void
  private planApiService: PlanApiService = PlanApiService.getInstance()

  build() {
    Column() {
      // Section Header
      Row() {
        // Icon Container with gradient background
        Column() {
          Text('📅')
            .fontSize(18)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('#B39DDB')
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Text('我的护肤方案')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#444444')
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Routines Container
      Column() {
        // Morning Routine
        this.RoutineSection('早间护理', this.morningRoutine, 'morning')

        // Evening Routine
        this.RoutineSection('晚间护理', this.eveningRoutine, 'evening')

        // Recommendations
        if (this.recommendations && this.recommendations.length > 0) {
          this.RecommendationsSection()
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 24,
      color: 'rgba(149, 157, 165, 0.15)',
      offsetX: 0,
      offsetY: 8
    })
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  RoutineSection(title: string, items: RoutineItem[], period: string) {
    Column() {
      // Routine Header
      Row() {
        // Routine Icon with gradient
        Column() {
          Text(period === 'morning' ? '☀️' : '🌙')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .width(32)
        .height(32)
        .borderRadius(8)
        .backgroundColor('#B39DDB')
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#444444')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // Routine Items
      Column() {
        ForEach(items, (item: RoutineItem, index: number) => {
          Row() {
            Text(item.completed ? '✓' : '○')
              .fontSize(18)
              .fontColor(item.completed ? '#9575CD' : '#9c9c9c')
              .margin({ right: 12 })

            Text(item.product || '')
              .fontSize(15)
              .fontColor('#444444')
              .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
              .opacity(item.completed ? 0.7 : 1.0)
              .layoutWeight(1)
          }
          .width('100%')
          .height(48)
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .margin({ bottom: 10 })
          .onClick(() => {
            this.toggleTask(items, index, period)
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#F9FAFB')
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 24 })
  }

  @Builder
  RecommendationsSection() {
    Column() {
      // Recommendations Header
      Row() {
        // Tips Icon with gradient
        Column() {
          Text('💡')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .width(32)
        .height(32)
        .borderRadius(8)
        .backgroundColor('#FFCC80')
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Text('专业建议')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#444444')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // Recommendations List
      Column() {
        ForEach(this.recommendations, (tip: string, index: number) => {
          Row() {
            Text('✓')
              .fontSize(16)
              .fontColor('#FF9800')
              .margin({ right: 12, top: 2 })

            Text(tip)
              .fontSize(15)
              .fontColor('#5d4037')
              .lineHeight(22)
              .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('rgba(255, 255, 255, 0.5)')
          .borderRadius(10)
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFF8E1')
    .borderRadius(16)
  }

  async toggleTask(routine: RoutineItem[], index: number, period: string) {
    if (!routine[index] || !this.planId) {
      console.warn('⚠️ 无法更新步骤：缺少必要数据')
      return
    }

    console.log('===== ✅ 切换步骤完成状态 =====')
    console.log(`📋 方案ID: ${this.planId}`)
    console.log(`📋 时段: ${period}`)
    console.log(`📋 步骤索引: ${index}`)
    console.log(`📋 当前步骤: ${routine[index].step}`)
    console.log(`📋 当前状态: ${routine[index].completed}`)

    // 本地先切换状态
    const newCompleted = !routine[index].completed
    routine[index].completed = newCompleted

    // 获取步骤ID
    const stepId = routine[index].step || (index + 1)

    try {
      // 调用API更新步骤状态
      console.log('📡 调用API更新步骤状态')
      const response = await this.planApiService.updateStepCompleted(this.planId, {
        period: period as 'morning' | 'evening',
        step: stepId,
        completed: newCompleted
      })

      if (response.success && response.data && response.data.plan) {
        const plan = response.data.plan
        
        console.log('✅ 步骤状态更新成功')
        console.log('📋 更新后的方案数据已获取')

        // 用后端返回的最新 plan 刷新数据
        const updatedMorning = (plan.morning || []).map((step: PlanStep): RoutineItem => ({
          step: step.step || 0,
          product: step.product || '',
          completed: step.completed || false
        }))
        
        const updatedEvening = (plan.evening || []).map((step: PlanStep): RoutineItem => ({
          step: step.step || 0,
          product: step.product || '',
          completed: step.completed || false
        }))

        // 通过回调更新父组件数据
        if (this.onRoutineUpdate) {
          this.onRoutineUpdate(updatedMorning, updatedEvening, plan.recommendations || [])
        }

        // 检查所有任务是否都完成
        const allDone = updatedMorning.every((t: RoutineItem) => t.completed) && 
                       updatedEvening.every((t: RoutineItem) => t.completed)
        
        if (allDone) {
          console.log('🎉 所有步骤已完成！')
        }
      } else {
        console.error('❌ 更新步骤状态失败:', response.message)
        // 失败时回滚本地状态
        routine[index].completed = !newCompleted
      }
    } catch (error) {
      console.error('❌ 更新步骤状态异常:', JSON.stringify(error))
      // 失败时回滚本地状态
      routine[index].completed = !newCompleted
    }
  }
}

// Data Models
interface RoutineItem {
  step?: number
  product?: string
  completed?: boolean
}

