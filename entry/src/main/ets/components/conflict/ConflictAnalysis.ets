import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct ConflictAnalysis {
  @Prop conflicts: ConflictItem[] = []
  @Prop safeCombo: SafeComboItem[] = []
  @Prop recommendations: RecommendationData = {
    productPairings: {
      cannotUseTogether: [],
      canUseTogether: []
    },
    routines: {
      morning: [],
      evening: []
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('🔍')
          .fontSize(18)
          .margin({ right: 8 })
        Text('检测结果')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
          .layoutWeight(1)

        Row() {
          Text('🕐')
            .fontSize(12)
            .margin({ right: 4 })
          Text('刚刚更新')
            .fontSize(12)
            .fontColor(AISkinColor.secondary)
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // No Conflicts Banner
      if (!this.hasConflicts() && this.safeCombo.length === 0) {
        this.NoConflictsBanner()
      }

      // Conflicts Section
      if (this.hasConflicts()) {
        this.ConflictsSection()
      }

      // Safe Combinations
      if (this.safeCombo.length > 0) {
        this.SafeCombinationsSection()
      }

      // Recommendations
      if (this.hasRecommendations()) {
        this.RecommendationsSection()
      }
    }
    .width('100%')
    .padding(20)
    .attributeModifier(new CardStyle())
    .margin({ bottom: 16 })
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 10
    })
  }

  @Builder
  NoConflictsBanner() {
    Column() {
      Text('😊')
        .fontSize(48)
        .margin({ bottom: 16 })

      Text('太棒了！这些产品没有发现成分冲突，可以安心使用')
        .fontSize(16)
        .fontColor(AISkinColor.success)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .lineHeight(24)
    }
    .width('100%')
    .padding(32)
    .backgroundColor(AISkinColor.successSurface)
    .borderRadius(20)
    .border({
      width: 1,
      color: 'rgba(76, 175, 80, 0.2)',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 20 })
  }

  @Builder
  ConflictsSection() {
    Column() {
      Row() {
        Stack() {
          Text('●')
            .fontSize(12)
            .fontColor(AISkinColor.danger)
        }
        .width(10)
        .height(10)
        .margin({ right: 12 })

        Text('这些成分会打架哦！')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AISkinColor.danger)
      }
      .width('100%')
      .margin({ bottom: 16 })

      ForEach(this.conflicts, (conflict: ConflictItem, index: number) => {
        this.ConflictCard(conflict, index)
      })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  ConflictCard(conflict: ConflictItem, index: number) {
    Row() {
      Stack() {
        Text('🐾')
          .fontSize(20)
          .fontColor(AISkinColor.danger)
      }
      .width(48)
      .height(48)
      .backgroundColor(AISkinColor.surface)
      .borderRadius(15)
      .alignContent(Alignment.Center)
      .margin({ right: 16 })

      Column() {
        Text(this.formatComponents(conflict.components || []))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 8 })

        Text(conflict.description || '')
          .fontSize(14)
          .fontColor(AISkinColor.secondary)
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
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(AISkinColor.dangerSurface)
    .borderRadius(16)
    .border({
      width: 1,
      color: 'rgba(244, 67, 54, 0.2)',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }

  @Builder
  SafeCombinationsSection() {
    Column() {
      Row() {
        Stack() {
          Text('●')
            .fontSize(12)
            .fontColor(AISkinColor.success)
        }
        .width(10)
        .height(10)
        .margin({ right: 12 })

        Text('这些组合很和谐')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AISkinColor.success)
      }
      .width('100%')
      .margin({ bottom: 16 })

      ForEach(this.safeCombo, (combo: SafeComboItem, index: number) => {
        this.SafeComboCard(combo, index)
      })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  SafeComboCard(combo: SafeComboItem, index: number) {
    Row() {
      Stack() {
        Text('✓')
          .fontSize(20)
          .fontColor(AISkinColor.success)
      }
      .width(48)
      .height(48)
      .backgroundColor(AISkinColor.surface)
      .borderRadius(15)
      .alignContent(Alignment.Center)
      .margin({ right: 16 })

      Column() {
        Text(this.formatComponents(combo.components || []))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 8 })

        Text(combo.description || '')
          .fontSize(14)
          .fontColor(AISkinColor.secondary)
          .lineHeight(20)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(AISkinColor.successSurface)
    .borderRadius(16)
    .border({
      width: 1,
      color: 'rgba(76, 175, 80, 0.2)',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }

  @Builder
  RecommendationsSection() {
    Column() {
      Row() {
        Text('💡')
          .fontSize(18)
          .margin({ right: 8 })
        Text('猫咪护肤建议')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Product Pairings
      if (this.hasCannotUseTogether() || this.hasCanUseTogether()) {
        Column() {
          Text('产品搭配:')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 12 })

          if (this.hasCannotUseTogether()) {
            this.CannotUseTogether()
          }

          if (this.hasCanUseTogether()) {
            this.CanUseTogether()
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(AISkinColor.muted)
        .borderRadius(16)
        .margin({ bottom: 16 })
      }

      // Routines
      if (this.hasRoutines()) {
        Column() {
          Text('护肤步骤:')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 12 })

          if (this.hasMorningRoutine()) {
            this.MorningRoutine()
          }

          if (this.hasEveningRoutine()) {
            this.EveningRoutine()
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(AISkinColor.muted)
        .borderRadius(16)
      }
    }
    .width('100%')
    .margin({ top: 20 })
    .padding({ top: 20 })
    .border({
      width: { top: 1 },
      color: AISkinColor.divider,
      style: BorderStyle.Solid
    })
  }

  @Builder
  CannotUseTogether() {
    Column() {
      Row() {
        Text('🚫')
          .fontSize(14)
          .margin({ right: 8 })
        Text('不能一起使用:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.danger)
      }
      .width('100%')
      .margin({ bottom: 12 })

      ForEach(this.recommendations.productPairings?.cannotUseTogether || [], (item: PairingItem, index: number) => {
        Column() {
          Text(this.formatProductPair(item.products || []))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 4 })

          Text(`原因：${item.reason || ''}`)
            .fontSize(13)
            .fontColor(AISkinColor.secondary)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(AISkinColor.surface)
        .borderRadius(12)
        .margin({ bottom: 8 })
        .alignItems(HorizontalAlign.Start)
      })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  CanUseTogether() {
    Column() {
      Row() {
        Text('✓')
          .fontSize(14)
          .margin({ right: 8 })
        Text('可以一起使用:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.success)
      }
      .width('100%')
      .margin({ bottom: 12 })

      ForEach(this.recommendations.productPairings?.canUseTogether || [], (item: PairingItem, index: number) => {
        Column() {
          Text(this.formatProductPair(item.products || []))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 4 })

          Text(`原因：${item.reason || ''}`)
            .fontSize(13)
            .fontColor(AISkinColor.secondary)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(AISkinColor.surface)
        .borderRadius(12)
        .margin({ bottom: 8 })
        .alignItems(HorizontalAlign.Start)
      })
    }
    .width('100%')
  }

  @Builder
  MorningRoutine() {
    Column() {
      Row() {
        Text('☀️')
          .fontSize(14)
          .margin({ right: 8 })
        Text('早晨')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(this.recommendations.routines?.morning || [], (step: string, index: number) => {
          Text(`${index + 1}. ${step}`)
            .fontSize(14)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(AISkinColor.muted)
      .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  EveningRoutine() {
    Column() {
      Row() {
        Text('🌙')
          .fontSize(14)
          .margin({ right: 8 })
        Text('晚上')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(this.recommendations.routines?.evening || [], (step: string, index: number) => {
          Text(`${index + 1}. ${step}`)
            .fontSize(14)
            .fontColor(AISkinColor.text)
            .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(AISkinColor.muted)
      .borderRadius(8)
    }
    .width('100%')
  }

  hasConflicts(): boolean {
    return this.conflicts.length > 0
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
    return components.length > 0 ? components.join(' + ') : '未检测到成分'
  }

  formatProductPair(products: string[]): string {
    return products.length > 0 ? products.join(' + ') : '未指定产品'
  }

  getSeverityColor(severity: string): ResourceColor {
    switch (severity) {
      case '高':
        return AISkinColor.danger
      case '中':
        return AISkinColor.warning
      case '低':
        return AISkinColor.success
      default:
        return AISkinColor.warning
    }
  }

  getSeverityBgColor(severity: string): ResourceColor {
    switch (severity) {
      case '高':
        return AISkinColor.dangerSurface
      case '中':
        return AISkinColor.warningSurface
      case '低':
        return AISkinColor.successSurface
      default:
        return AISkinColor.warningSurface
    }
  }
}

// Data Models
export interface ConflictItem {
  components?: string[]
  description?: string
  severity?: string
  effects?: string[]
}

export interface SafeComboItem {
  components?: string[]
  description?: string
}

export interface PairingItem {
  products?: string[]
  reason?: string
}

export interface ProductPairings {
  cannotUseTogether?: PairingItem[]
  canUseTogether?: PairingItem[]
}

export interface Routines {
  morning?: string[]
  evening?: string[]
}

export interface RecommendationData {
  productPairings?: ProductPairings
  routines?: Routines
}
