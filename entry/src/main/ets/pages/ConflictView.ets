import { AppHeader } from '../components/common/AppHeader'
import { ConflictAnalysis } from '../components/conflict/ConflictAnalysis'
import { ConflictAnalysisData, ConflictItem, SafeComboItem, RecommendationData } from '../components/product/ConflictApiService'

@Component
export struct ConflictView {
  @State activeTab: string = 'overview'
  @Prop conflictData: ConflictAnalysisData | null = null
  @State conflicts: ConflictItem[] = []
  @State safeCombo: SafeComboItem[] = []
  @State recommendations: RecommendationData = {
    productPairings: {
      cannotUseTogether: [],
      canUseTogether: []
    },
    routines: {
      morning: [],
      evening: []
    }
  }
  @State loading: boolean = false
  @State error: string | null = null
  private scroller: Scroller = new Scroller()
  onBack?: () => void

  aboutToAppear() {
    if (this.conflictData) {
      this.loadConflictData(this.conflictData)
    } else {
      this.error = '未提供冲突分析数据'
    }
  }

  loadConflictData(data: ConflictAnalysisData) {
    console.log('===== 📋 加载冲突分析数据 =====')
    this.conflicts = data.conflicts || []
    this.safeCombo = data.safeCombo || []
    this.recommendations = data.recommendations || {
      productPairings: {
        cannotUseTogether: [],
        canUseTogether: []
      },
      routines: {
        morning: [],
        evening: []
      }
    }
    console.log(`✅ 加载完成: 冲突数=${this.conflicts.length}, 安全组合数=${this.safeCombo.length}`)
  }

  build() {
    Stack() {
      Column() {
        // Header
        AppHeader({
          title: '成分冲突检测',
          icon: 'paw',
          showBackButton: true,
          bgColor: 'bg-sakura',
          onBack: () => {
            if (this.onBack) {
              this.onBack()
            }
          }
        })
        .width('100%')

        // Tab Navigation
        this.TabNavigation()

        // Main Content - All sections in one scrollable view
        Scroll(this.scroller) {
          Column() {
            if (this.error) {
              this.ErrorState()
            } else if (this.loading) {
              this.LoadingState()
            } else {
              // Overview Section
              Column() {
                this.OverviewSection()
              }
              .id('overview-section')
              .width('100%')

              // Conflicts Section
              Column() {
                this.ConflictsSection()
              }
              .id('conflicts-section')
              .width('100%')

              // Safe Combinations Section
              Column() {
                this.SafeCombinationsSection()
              }
              .id('safe-section')
              .width('100%')

              // Usage Recommendations Section
              Column() {
                this.UsageRecommendationsSection()
              }
              .id('routine-section')
              .width('100%')
            }
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .width('100%')
        .scrollable(ScrollDirection.Vertical)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#fff9fb')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabNavigation() {
    Row() {
      this.TabButton('overview', '📊', '概览')
      this.TabButton('conflicts', '⚠️', '冲突')
      this.TabButton('safe', '🛡️', '安全组合')
      this.TabButton('routine', '💡', '使用建议')
    }
    .width('100%')
    .height(50)
    .padding({ left: 14, right: 14 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceAround)
    .border({
      width: { bottom: 1 },
      color: 'rgba(0, 0, 0, 0.05)',
      style: BorderStyle.Solid
    })
  }

  @Builder
  TabButton(tab: string, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(18)
        .margin({ bottom: 4 })
      Text(label)
        .fontSize(12)
        .fontColor(this.activeTab === tab ? '#F8BBD0' : '#8E8E93')
        .fontWeight(this.activeTab === tab ? FontWeight.Medium : FontWeight.Normal)
    }
    .width(60)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.activeTab = tab
      this.scrollToSection(tab)
    })
  }

  scrollToSection(tab: string) {
    console.log(`===== 📍 滚动到标签页: ${tab} =====`)
    
    // Calculate approximate offsets based on actual content heights
    // Header: ~60px, Tabs: ~50px = ~110px base offset
    // Overview section: Summary card (~280px) = ~280px
    // Conflicts section: Header (~80px) + each conflict card (~180px) + margins
    // Safe section: Header (~80px) + each combo card (~150px) + margins
    // Routine section: Header (~80px) + reminders (~200px) + routines (~300px) = ~580px
    
    let offset = 0
    const baseOffset = 110 // Header + Tabs
    
    switch (tab) {
      case 'overview':
        offset = 0
        break
      case 'conflicts':
        // Overview section height
        const overviewHeight = 280 + 28 // Summary card + margins
        offset = baseOffset + overviewHeight
        break
      case 'safe':
        // Overview + Conflicts sections
        const overviewH = 280 + 28
        const conflictsHeaderH = 80
        const conflictsCardsH = this.conflicts.length > 0 ? this.conflicts.length * 180 : 0
        const conflictsMargins = this.conflicts.length > 0 ? (this.conflicts.length - 1) * 12 + 28 : 28
        const conflictsTotalH = conflictsHeaderH + conflictsCardsH + conflictsMargins
        offset = baseOffset + overviewH + conflictsTotalH
        break
      case 'routine':
        // Overview + Conflicts + Safe sections
        const overviewH2 = 280 + 28
        const conflictsHeaderH2 = 80
        const conflictsCardsH2 = this.conflicts.length > 0 ? this.conflicts.length * 180 : 0
        const conflictsMargins2 = this.conflicts.length > 0 ? (this.conflicts.length - 1) * 12 + 28 : 28
        const conflictsTotalH2 = conflictsHeaderH2 + conflictsCardsH2 + conflictsMargins2
        const safeHeaderH = 80
        const safeCardsH = this.safeCombo.length > 0 ? this.safeCombo.length * 150 : 0
        const safeMargins = this.safeCombo.length > 0 ? (this.safeCombo.length - 1) * 12 + 28 : 28
        const safeTotalH = safeHeaderH + safeCardsH + safeMargins
        offset = baseOffset + overviewH2 + conflictsTotalH2 + safeTotalH
        break
    }
    
    console.log(`📊 计算滚动偏移量: ${offset}px`)
    console.log(`📋 当前数据: 冲突数=${this.conflicts.length}, 安全组合数=${this.safeCombo.length}`)
    
    // Scroll to section with smooth animation
    setTimeout(() => {
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: offset,
        animation: {
          duration: 300,
          curve: Curve.EaseOut
        }
      })
      console.log(`✅ 已滚动到 ${tab} 部分，偏移量: ${offset}px`)
    }, 50)
  }

  @Builder
  OverviewSection() {
    Column() {
      // Analysis Summary Card
      Column() {
        Row() {
          Column() {
            Text('⚠️')
              .fontSize(24)
              .margin({ right: 12 })
          }
          .width(48)
          .height(48)
          .backgroundColor('rgba(255, 152, 0, 0.1)')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('分析结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text('成分冲突检测报告')
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('⚠️')
              .fontSize(14)
              .margin({ bottom: 4 })
            Text('警告')
              .fontSize(12)
              .fontColor('#ff9800')
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('rgba(255, 152, 0, 0.1)')
          .borderRadius(12)
        }
        .width('100%')
        .margin({ bottom: 20 })

        // Stats Grid
        Row() {
          this.StatItem('danger', this.conflicts.length.toString(), '严重冲突')
          this.StatItem('warning', this.getMinorConflicts().toString(), '轻微冲突')
          this.StatItem('success', this.safeCombo.length.toString(), '安全组合')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .margin({ top: 14, left: 14, right: 14, bottom: 14 })
      .shadow({
        radius: 10,
        color: 'rgba(0, 0, 0, 0.08)',
        offsetX: 0,
        offsetY: 10
      })

      // Note: ConflictAnalysis component is shown in individual sections below
    }
    .width('100%')
  }

  @Builder
  StatItem(type: string, number: string, label: string) {
    Column() {
      Text(number)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getStatColor(type))
        .margin({ bottom: 4 })
      Text(label)
        .fontSize(12)
        .fontColor(this.getStatLabelColor(type))
    }
    .width('30%')
    .padding(16)
    .backgroundColor(this.getStatBgColor(type))
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }

  getStatColor(type: string): ResourceColor {
    switch (type) {
      case 'danger':
        return '#f44336'
      case 'warning':
        return '#ff9800'
      case 'success':
        return '#4caf50'
      default:
        return '#666666'
    }
  }

  getStatLabelColor(type: string): ResourceColor {
    switch (type) {
      case 'danger':
        return '#d32f2f'
      case 'warning':
        return '#f57c00'
      case 'success':
        return '#388e3c'
      default:
        return '#666666'
    }
  }

  getStatBgColor(type: string): ResourceColor {
    switch (type) {
      case 'danger':
        return 'rgba(244, 67, 54, 0.1)'
      case 'warning':
        return 'rgba(255, 152, 0, 0.1)'
      case 'success':
        return 'rgba(76, 175, 80, 0.1)'
      default:
        return '#f5f5f5'
    }
  }

  @Builder
  ConflictsSection() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text('⚠️')
              .fontSize(24)
              .margin({ right: 12 })
          }
          .width(48)
          .height(48)
          .backgroundColor('rgba(244, 67, 54, 0.1)')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('冲突检测')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text('发现的成分冲突和注意事项')
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ bottom: 20 })

        if (this.conflicts.length === 0) {
          this.NoConflictsBanner()
        } else {
          ForEach(this.conflicts, (conflict: ConflictItem, index: number) => {
            this.ConflictCard(conflict, index)
          })
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .margin({ top: 14, left: 14, right: 14, bottom: 14 })
      .shadow({
        radius: 10,
        color: 'rgba(0, 0, 0, 0.08)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
  }

  @Builder
  SafeCombinationsSection() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text('🛡️')
              .fontSize(24)
              .margin({ right: 12 })
          }
          .width(48)
          .height(48)
          .backgroundColor('rgba(76, 175, 80, 0.1)')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('安全组合推荐')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text('经过验证的安全成分搭配')
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ bottom: 20 })

        if (this.safeCombo.length === 0) {
          Text('暂无安全组合数据')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(20)
        } else {
          ForEach(this.safeCombo, (combo: SafeComboItem, index: number) => {
            this.SafeComboCard(combo, index)
          })
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .margin({ top: 14, left: 14, right: 14, bottom: 14 })
      .shadow({
        radius: 10,
        color: 'rgba(0, 0, 0, 0.08)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
  }

  @Builder
  UsageRecommendationsSection() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text('💡')
              .fontSize(24)
              .margin({ right: 12 })
          }
          .width(48)
          .height(48)
          .backgroundColor('rgba(14, 165, 233, 0.1)')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('使用建议')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text('个性化护肤方案推荐')
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ bottom: 20 })

        // Important Reminders
        this.ImportantReminders()

        // Usage Schedule
        if (this.hasRecommendations()) {
          this.UsageSchedule()
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .margin({ top: 14, left: 14, right: 14, bottom: 14 })
      .shadow({
        radius: 10,
        color: 'rgba(0, 0, 0, 0.08)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
  }

  @Builder
  NoConflictsBanner() {
    Column() {
      Text('😊')
        .fontSize(48)
        .margin({ bottom: 16 })
      Text('太棒了！这些产品没有发现成分冲突，可以安心使用')
        .fontSize(16)
        .fontColor('#388e3c')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .lineHeight(24)
    }
    .width('100%')
    .padding(32)
    .backgroundColor('#f1f8e9')
    .borderRadius(20)
    .border({
      width: 1,
      color: 'rgba(76, 175, 80, 0.2)',
      style: BorderStyle.Solid
    })
  }

  @Builder
  ConflictCard(conflict: ConflictItem, index: number) {
    Row() {
      Column() {
        Text('✕')
          .fontSize(20)
          .fontColor('#f44336')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })

      Column() {
        Text(this.formatComponents(conflict.components || []))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text(conflict.description || '')
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .margin({ bottom: 12 })

        Row() {
          Text(`${conflict.severity || '中'}度风险`)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getSeverityColor(conflict.severity || '中'))
            .backgroundColor(this.getSeverityBgColor(conflict.severity || '中'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)

          if (conflict.effects && conflict.effects.length > 0) {
            Text(conflict.effects[0])
              .fontSize(12)
              .fontColor('#f57c00')
              .backgroundColor('rgba(255, 152, 0, 0.1)')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ left: 8 })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#ffebee')
    .borderRadius(16)
    .border({
      width: 1,
      color: 'rgba(244, 67, 54, 0.2)',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }

  @Builder
  SafeComboCard(combo: SafeComboItem, index: number) {
    Row() {
      Column() {
        Text('✓')
          .fontSize(20)
          .fontColor('#4caf50')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })

      Column() {
        Text(this.formatComponents(combo.components || []))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text(combo.description || '')
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#e8f5e9')
    .borderRadius(16)
    .border({
      width: 1,
      color: 'rgba(76, 175, 80, 0.2)',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }

  @Builder
  ImportantReminders() {
    Column() {
      Row() {
        Text('💡')
          .fontSize(18)
          .margin({ right: 8 })
        Text('重要提醒')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#f57c00')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        Text('• 首次使用新产品时，建议先在手腕内侧进行过敏测试')
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .margin({ bottom: 8 })
        Text('• 含有活性成分的产品应避免同时大量使用')
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .margin({ bottom: 8 })
        Text('• 使用含酸类成分的产品时，务必做好防晒工作')
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255, 193, 7, 0.1)')
    .borderRadius(16)
    .border({
      width: 1,
      color: 'rgba(255, 193, 7, 0.2)',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 20 })
  }

  @Builder
  UsageSchedule() {
    Column() {
      Row() {
        Text('🕐')
          .fontSize(18)
          .margin({ right: 8 })
        Text('建议使用方案')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.hasMorningRoutine()) {
        this.RoutineCard('morning', '☀️', '晨间护理', this.recommendations.routines?.morning || [])
      }

      if (this.hasEveningRoutine()) {
        this.RoutineCard('evening', '🌙', '晚间护理', this.recommendations.routines?.evening || [])
      }
    }
    .width('100%')
  }

  @Builder
  RoutineCard(type: string, icon: string, title: string, steps: string[]) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(16)
          .margin({ right: 8 })
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(steps, (step: string, index: number) => {
          Text(`${index + 1}. ${step}`)
            .fontSize(14)
            .fontColor('#666666')
            .lineHeight(20)
            .margin({ bottom: 8 })
            .width('100%')
        })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(12)
      .backgroundColor('#f5f5f5')
      .borderRadius(12)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({
      width: { left: 3 },
      color: type === 'morning' ? '#ff9800' : '#5e35b1',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }

  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#F8BBD0')
        .margin({ bottom: 16 })
      Text('分析产品冲突中...')
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 100 })
  }

  @Builder
  ErrorState() {
    Column() {
      Text('⚠️')
        .fontSize(48)
        .margin({ bottom: 16 })
      Text(this.error || '加载失败')
        .fontSize(16)
        .fontColor('#d32f2f')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(32)
    .margin({ top: 100, left: 14, right: 14 })
    .backgroundColor('#ffebee')
    .borderRadius(20)
  }

  getMinorConflicts(): number {
    return this.conflicts.filter(conflict => 
      conflict.severity === '中' || conflict.severity === '低'
    ).length
  }

  hasRecommendations(): boolean {
    return this.hasCannotUseTogether() || this.hasCanUseTogether() || this.hasRoutines()
  }

  hasCannotUseTogether(): boolean {
    return (this.recommendations.productPairings?.cannotUseTogether?.length || 0) > 0
  }

  hasCanUseTogether(): boolean {
    return (this.recommendations.productPairings?.canUseTogether?.length || 0) > 0
  }

  hasRoutines(): boolean {
    return this.hasMorningRoutine() || this.hasEveningRoutine()
  }

  hasMorningRoutine(): boolean {
    return (this.recommendations.routines?.morning?.length || 0) > 0
  }

  hasEveningRoutine(): boolean {
    return (this.recommendations.routines?.evening?.length || 0) > 0
  }

  formatComponents(components: string[]): string {
    return components.length > 0 ? components.join(' × ') : '未检测到成分'
  }

  getSeverityColor(severity: string): ResourceColor {
    switch (severity) {
      case '高':
        return '#d32f2f'
      case '中':
        return '#f57c00'
      case '低':
        return '#388e3c'
      default:
        return '#f57c00'
    }
  }

  getSeverityBgColor(severity: string): ResourceColor {
    switch (severity) {
      case '高':
        return '#ffebee'
      case '中':
        return '#fff8e1'
      case '低':
        return '#e8f5e9'
      default:
        return '#fff8e1'
    }
  }
}

