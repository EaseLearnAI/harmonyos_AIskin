@Component
export struct SkinTypeAnalysis {
  @Prop skinType: SkinTypeData = { type: '混合偏油性皮肤', subtype: '混油性', basis: 'T区偏油，U区正常偏干' }
  @Prop oilLevel: string = '偏高'
  @Prop moistureLevel: string = '正常'
  @Prop poreLevel: string = '中等'

  getSkinTypeEmoji(): string {
    const emojis: Record<string, string> = {
      '混合偏油性皮肤': '🧴',
      '混合偏干性皮肤': '💧',
      '油性皮肤': '🔥',
      '干性皮肤': '🌟',
      '中性皮肤': '🌈',
      '敏感性皮肤': '🤧',
      '混合性皮肤': '🌐'
    }
    const skinType = this.skinType.type
    if (skinType) {
      return emojis[skinType] || '👁️'
    }
    return '👁️'
  }

  getOilPercentage(): number {
    const levels: Record<string, number> = { '低': 30, '正常': 50, '偏高': 75, '高': 90 }
    return levels[this.oilLevel] || 60
  }

  getMoisturePercentage(): number {
    const levels: Record<string, number> = { '低': 30, '正常': 60, '偏高': 80, '高': 95 }
    return levels[this.moistureLevel] || 60
  }

  getPorePercentage(): number {
    const levels: Record<string, number> = { '细': 25, '正常': 45, '中等': 55, '粗大': 75 }
    return levels[this.poreLevel] || 55
  }

  getOilSuggestion(): string {
    return this.oilLevel === '偏高' ? '建议使用控油洁面产品' : '建议使用温和洁面产品'
  }

  getMoistureSuggestion(): string {
    return this.moistureLevel === '偏高' ? '建议使用轻薄保湿产品' : '建议使用滋润保湿产品'
  }

  getPoreSuggestion(): string {
    return this.poreLevel === '粗大' ? '建议使用收缩毛孔产品' : '建议使用保湿产品'
  }

  build() {
    Column() {
      // Header
      Row() {
        Row() {
          Text('🔬')
            .fontSize(18)
            .margin({ right: 12 })
          Text('皮肤类型分析')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#374151')
        }
        .layoutWeight(1)

        Column() {
          Text('AI识别')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#E1BEE7')
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(20)
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Skin Type Summary
      Row() {
        Column() {
          Text(this.skinType.type)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#374151')
            .margin({ bottom: 8 })

          Text(this.skinType.subtype)
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ bottom: 12 })

          Row() {
            Column()
              .width(6)
              .height(6)
              .backgroundColor('#FFBBD0')
              .borderRadius(3)
              .margin({ right: 8 })

            Text('基于面部油脂分布分析')
              .fontSize(12)
              .fontColor('#6B7280')
          }
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)

        Text(this.getSkinTypeEmoji())
          .fontSize(40)
          .opacity(0.8)
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FEF7F0')
      .borderRadius(16)
      .border({
        width: 1,
        color: '#FFF9FB',
        style: BorderStyle.Solid
      })
      .margin({ bottom: 20 })

      // Analysis Metrics
      Column() {
        // Oil Level
        this.MetricItem('🛢️', 'T区油脂分泌', this.oilLevel, this.getOilPercentage(), '#F59E0B', this.getOilSuggestion())

        // Moisture Level
        this.MetricItem('💧', 'U区水分含量', this.moistureLevel, this.getMoisturePercentage(), '#3B82F6', this.getMoistureSuggestion())

        // Pore Level
        this.MetricItem('⭕', '毛孔粗细度', this.poreLevel, this.getPorePercentage(), '#8B5CF6', this.getPoreSuggestion())
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .margin({ bottom: 16 })
  }

  @Builder
  MetricItem(icon: string, label: string, status: string, percentage: number, color: string, suggestion: string) {
    Column() {
      Row() {
        Row() {
          Text(icon)
            .fontSize(14)
            .margin({ right: 8 })
          Text(label)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
        }
        .layoutWeight(1)

        Text(status)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(color)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getStatusBgColor(color))
          .borderRadius(20)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // Progress Bar
      Stack() {
        Column()
          .width('100%')
          .height(8)
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .borderRadius(4)

        Column()
          .width(percentage + '%')
          .height(8)
          .backgroundColor(color)
          .borderRadius(4)
      }
      .width('100%')
      .height(8)
      .margin({ bottom: 8 })
      .align(Alignment.Start)

      Text(suggestion)
        .fontSize(12)
        .fontColor('#6B7280')
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255, 255, 255, 0.5)')
    .borderRadius(12)
    .border({
      width: 1,
      color: '#F3F4F6',
      style: BorderStyle.Solid
    })
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  getStatusBgColor(color: string): string {
    const colorMap: Record<string, string> = {
      '#F59E0B': '#FEF3C7',
      '#3B82F6': '#DBEAFE',
      '#8B5CF6': '#EDE9FE'
    }
    return colorMap[color] || '#F3F4F6'
  }
}

// Data Models
interface SkinTypeData {
  type?: string
  subtype?: string
  basis?: string
}

