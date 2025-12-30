@Component
export struct AIRecommendations {
  @Prop recommendations: string[] = []

  getRecommendationCards(): RecommendationCard[] {
    if (this.recommendations && this.recommendations.length > 0) {
      return this.recommendations.map((rec: string, index: number): RecommendationCard => {
        const card: RecommendationCard = {
          title: `建议 ${index + 1}`,
          description: rec,
          tags: [],
          info: '基于您的肌肤状况',
          icon: '💡',
          bgClass: 'blue-bg',
          tagClass: 'blue-tag',
          infoClass: 'blue-info'
        }
        return card
      })
    }

    const defaultCards: RecommendationCard[] = [
      {
        title: '清洁护理方案',
        description: '建议使用温和的氨基酸洁面乳，早晚各一次，避免过度清洁导致水油失衡。',
        tags: ['氨基酸洁面', '温和清洁', 'pH平衡'],
        info: '建议使用频率：早晚各1次',
        icon: '💧',
        bgClass: 'blue-bg',
        tagClass: 'blue-tag',
        infoClass: 'blue-info'
      },
      {
        title: '保湿护理方案',
        description: '选择适合您肤质的保湿产品，保持肌肤水润平衡。',
        tags: ['保湿', '补水', '锁水'],
        info: '建议使用频率：每日2次',
        icon: '🌿',
        bgClass: 'emerald-bg',
        tagClass: 'emerald-tag',
        infoClass: 'emerald-info'
      },
      {
        title: '防晒护理方案',
        description: '每日使用SPF30+广谱防晒霜，保护肌肤免受紫外线伤害。',
        tags: ['防晒', '紫外线防护', 'SPF30+'],
        info: '建议使用频率：每日1次',
        icon: '☀️',
        bgClass: 'yellow-bg',
        tagClass: 'yellow-tag',
        infoClass: 'yellow-info'
      }
    ]
    return defaultCards
  }

  build() {
    Column() {
      // Header
      Row() {
        Row() {
          Text('🧠')
            .fontSize(18)
            .margin({ right: 12 })
          Text('AI智能护肤建议')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#374151')
        }
        .layoutWeight(1)

        Column() {
          Text('个性化定制')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#667eea')
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .backgroundColor('#DBEAFE')
            .borderRadius(20)
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Recommendations List
      Column() {
        ForEach(this.getRecommendationCards(), (card: RecommendationCard, index: number) => {
          this.RecommendationCard(card, index)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .margin({ bottom: 16 })
  }

  @Builder
  RecommendationCard(card: RecommendationCard, index: number) {
    Stack() {
      Column() {
        Row() {
          Column() {
            Text(card.icon)
              .fontSize(20)
          }
          .width(32)
          .height(32)
          .backgroundColor(this.getIconBgColor(card.bgClass))
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .margin({ right: 12 })

          Text(card.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#374151')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 12 })

        Text(card.description)
          .fontSize(14)
          .fontColor('#374151')
          .lineHeight(20)
          .margin({ bottom: 12 })

        // Tags
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(card.tags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getTagTextColor(card.tagClass))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.getTagBgColor(card.tagClass))
              .borderRadius(20)
              .border({
                width: 1,
                color: this.getTagBorderColor(card.tagClass),
                style: BorderStyle.Solid
              })
              .margin({ right: 8, bottom: 8 })
          })
        }
        .width('100%')
        .margin({ bottom: 12 })

        // Info
        Row() {
          Text('🤖')
            .fontSize(12)
            .margin({ right: 8 })
          Text(card.info)
            .fontSize(12)
            .fontColor(this.getInfoColor(card.infoClass))
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(20)
      .zIndex(10)
    }
    .width('100%')
    .backgroundColor(this.getCardBgColor(card.bgClass))
    .borderRadius(16)
    .border({
      width: 1,
      color: this.getCardBorderColor(card.bgClass),
      style: BorderStyle.Solid
    })
    .margin({ bottom: 20 })
  }

  getCardBgColor(bgClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-bg': '#EFF6FF',
      'emerald-bg': '#ECFDF5',
      'yellow-bg': '#FFFBEB',
      'purple-bg': '#F3F4F6'
    }
    return colorMap[bgClass] || '#FFFFFF'
  }

  getCardBorderColor(bgClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-bg': '#BFDBFE',
      'emerald-bg': '#A7F3D0',
      'yellow-bg': '#FDE68A',
      'purple-bg': '#DDD6FE'
    }
    return colorMap[bgClass] || '#F3F4F6'
  }

  getIconBgColor(bgClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-bg': '#3B82F6',
      'emerald-bg': '#10B981',
      'yellow-bg': '#F59E0B',
      'purple-bg': '#8B5CF6'
    }
    return colorMap[bgClass] || '#3B82F6'
  }

  getTagBgColor(tagClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-tag': '#DBEAFE',
      'emerald-tag': '#D1FAE5',
      'yellow-tag': '#FDE68A',
      'purple-tag': '#E9D5FF'
    }
    return colorMap[tagClass] || '#DBEAFE'
  }

  getTagTextColor(tagClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-tag': '#1D4ED8',
      'emerald-tag': '#047857',
      'yellow-tag': '#92400E',
      'purple-tag': '#7C3AED'
    }
    return colorMap[tagClass] || '#1D4ED8'
  }

  getTagBorderColor(tagClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-tag': '#BFDBFE',
      'emerald-tag': '#A7F3D0',
      'yellow-tag': '#F59E0B',
      'purple-tag': '#C4B5FD'
    }
    return colorMap[tagClass] || '#BFDBFE'
  }

  getInfoColor(infoClass: string): string {
    const colorMap: Record<string, string> = {
      'blue-info': '#1E40AF',
      'emerald-info': '#047857',
      'yellow-info': '#92400E',
      'purple-info': '#7C3AED'
    }
    return colorMap[infoClass] || '#1E40AF'
  }
}

// Data Models
interface RecommendationCard {
  title: string
  description: string
  tags: string[]
  info: string
  icon: string
  bgClass: string
  tagClass: string
  infoClass: string
}

