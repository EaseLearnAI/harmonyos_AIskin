@Component
export struct SkinStatusOverview {
  @Prop blackheads: BlackheadsData = { exists: true, severity: '少量', distribution: ['鼻翼', '下巴'] }
  @Prop acne: AcneData = { exists: true, count: '少量', types: ['粉刺'], distribution: ['额头', '下巴'] }
  @Prop pores: PoresData = { enlarged: true, severity: '中度', distribution: ['T区'] }
  @Prop skinToneEvenness: SkinToneData = { score: 7, description: '较为均匀' }
  @Prop redness: RednessData = { exists: true, severity: '轻度', description: '轻微敏感性泛红', distribution: ['鼻翼', '脸颊'] }
  @Prop hyperpigmentation: HyperpigmentationData = { exists: false, severity: '轻度', description: '少量晒斑痘印', types: ['晒斑', '痘印'], distribution: [] }
  @Prop fineLines: FineLinesData = { exists: false, severity: '无', description: '眼周轻微细纹', distribution: [] }
  @Prop sensitivity: SensitivityData = { exists: false, severity: '轻度', description: '轻度敏感肌', signs: [] }

  getOverallAssessment(): string {
    const issues: string[] = []
    if (this.blackheads.exists) {
      issues.push(`黑头情况：${this.getBlackheadsDescription()}`)
    }
    if (this.acne.exists) {
      issues.push(`痘痘情况：${this.getAcneDescription()}`)
    }
    if (this.pores.enlarged) {
      issues.push(`毛孔状态：${this.getPoresDescription()}`)
    }
    if (this.skinToneEvenness.score !== undefined) {
      issues.push(`肤色均匀度：${this.skinToneEvenness.description || '肤色均匀'}`)
    }
    if (this.redness.exists) {
      issues.push(`泛红情况：${this.getRednessDescription()}`)
    }
    if (issues.length === 0) {
      return '皮肤状态良好，无明显问题。'
    }
    return `皮肤状态总体良好，但有${issues.length}个问题需要轻度关注：${issues.join('、')}`
  }

  getBlackheadsDescription(): string {
    if (!this.blackheads.exists) {
      return '无黑头'
    }
    if (this.blackheads.distribution && this.blackheads.distribution.length > 0) {
      return this.blackheads.distribution.join('、')
    }
    return this.blackheads.severity || '少量'
  }

  getAcneDescription(): string {
    if (!this.acne.exists) {
      return '无痘痘'
    }
    if (this.acne.distribution && this.acne.distribution.length > 0) {
      return this.acne.distribution.join('、')
    }
    return this.acne.count || '少量'
  }

  getPoresDescription(): string {
    if (!this.pores.enlarged) {
      return '毛孔正常'
    }
    if (this.pores.distribution && this.pores.distribution.length > 0) {
      return this.pores.distribution.join('、')
    }
    return this.pores.severity || '中度'
  }

  getRednessDescription(): string {
    if (!this.redness.exists) {
      return '无泛红'
    }
    if (this.redness.distribution && this.redness.distribution.length > 0) {
      return this.redness.distribution.join('、')
    }
    return this.redness.severity || '轻度'
  }

  getStatusClass(severity: string): string {
    const classMap: Record<string, string> = {
      '无': 'status-good',
      '轻度': 'status-mild',
      '少量': 'status-mild',
      '正常': 'status-good',
      '中度': 'status-moderate',
      '良好': 'status-good',
      '大量': 'status-severe',
      '严重': 'status-severe'
    }
    return classMap[severity] || 'status-good'
  }

  getSkinToneStatus(): string {
    const score = this.skinToneEvenness.score || 0
    if (score >= 8) return '优秀'
    if (score >= 6) return '良好'
    if (score >= 4) return '一般'
    return '需改善'
  }

  getHyperpigmentationStatus(): string {
    if (!this.hyperpigmentation.exists) {
      return '无'
    }
    return this.hyperpigmentation.severity || '轻度'
  }

  getFineLinesStatus(): string {
    if (!this.fineLines.exists) {
      return '无'
    }
    return this.fineLines.severity || '轻度'
  }

  getSensitivityStatus(): string {
    if (!this.sensitivity.exists) {
      return '无'
    }
    return this.sensitivity.severity || '轻度'
  }

  build() {
    Column() {
      // Card Header
      Row() {
        Row() {
          Text('📊')
            .fontSize(20)
            .margin({ right: 12 })
          Text('皮肤状态总览')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Overall Assessment
      Row() {
        Text('✨')
          .fontSize(18)
          .margin({ right: 12 })
        Text(this.getOverallAssessment())
          .fontSize(14)
          .fontColor('#374151')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .padding(20)
      .backgroundColor('#f9fafb')
      .borderRadius(16)
      .border({
        width: 1,
        color: '#f3f4f6',
        style: BorderStyle.Solid
      })
      .margin({ bottom: 20 })

      // Issues List
      Column() {
        if (this.blackheads.exists) {
          this.IssueItem('⚫', '黑头情况', this.getBlackheadsDescription(), this.blackheads.severity || '正常')
        }
        if (this.acne.exists) {
          this.IssueItem('🔴', '痘痘情况', this.getAcneDescription(), this.acne.count || '正常')
        }
        if (this.pores.enlarged) {
          this.IssueItem('⬜', '毛孔状态', this.getPoresDescription(), this.pores.severity || '正常')
        }
        if (this.skinToneEvenness.score !== undefined) {
          this.IssueItem('🎨', '肤色均匀度', this.skinToneEvenness.description || '肤色均匀', this.getSkinToneStatus())
        }
        if (this.redness.exists) {
          this.IssueItem('❤️', '泛红情况', this.getRednessDescription(), this.redness.severity || '正常')
        }
        this.IssueItem('🟤', '色素沉着', this.hyperpigmentation.exists ? (this.hyperpigmentation.description || '轻微色素沉着') : '无明显色素沉着', this.getHyperpigmentationStatus())
        this.IssueItem('〰️', '细纹状况', this.fineLines.exists ? (this.fineLines.description || '轻微细纹') : '无明显细纹', this.getFineLinesStatus())
        this.IssueItem('🛡️', '敏感程度', this.sensitivity.exists ? (this.sensitivity.description || '轻度敏感肌') : '肌肤不敏感', this.getSensitivityStatus(), true)
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
  IssueItem(icon: string, title: string, description: string, status: string, isLast: boolean = false) {
    Row() {
      Row() {
        Column() {
          Text(icon)
            .fontSize(16)
        }
        .width(40)
        .height(40)
        .backgroundColor('#f3f4f6')
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        Column() {
          Text(title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1f2937')
            .margin({ bottom: 4 })

          Text(description)
            .fontSize(12)
            .fontColor('#6b7280')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .layoutWeight(1)

      Row() {
        Column()
          .width(6)
          .height(6)
          .backgroundColor(this.getStatusDotColor(status))
          .borderRadius(3)
          .margin({ right: 6 })

        Text(status)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusTextColor(status))
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.getStatusBgColor(status))
      .borderRadius(20)
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .border({
      width: { bottom: isLast ? 0 : 1 },
      color: '#f3f4f6',
      style: BorderStyle.Solid
    })
  }

  getStatusDotColor(severity: string): string {
    const classMap: Record<string, string> = {
      'status-good': '#10b981',
      'status-mild': '#f59e0b',
      'status-moderate': '#ef4444',
      'status-severe': '#dc2626'
    }
    return classMap[this.getStatusClass(severity)] || '#10b981'
  }

  getStatusTextColor(severity: string): string {
    const classMap: Record<string, string> = {
      'status-good': '#065f46',
      'status-mild': '#92400e',
      'status-moderate': '#991b1b',
      'status-severe': '#7f1d1d'
    }
    return classMap[this.getStatusClass(severity)] || '#065f46'
  }

  getStatusBgColor(severity: string): string {
    const classMap: Record<string, string> = {
      'status-good': '#ecfdf5',
      'status-mild': '#fffbeb',
      'status-moderate': '#fef2f2',
      'status-severe': '#fef2f2'
    }
    return classMap[this.getStatusClass(severity)] || '#ecfdf5'
  }
}

// Data Models
interface BlackheadsData {
  exists?: boolean
  severity?: string
  distribution?: string[]
}

interface AcneData {
  exists?: boolean
  count?: string
  types?: string[]
  distribution?: string[]
}

interface PoresData {
  enlarged?: boolean
  severity?: string
  distribution?: string[]
}

interface SkinToneData {
  score?: number
  description?: string
}

interface RednessData {
  exists?: boolean
  severity?: string
  description?: string
  distribution?: string[]
}

interface HyperpigmentationData {
  exists?: boolean
  severity?: string
  description?: string
  types?: string[]
  distribution?: string[]
}

interface FineLinesData {
  exists?: boolean
  severity?: string
  description?: string
  distribution?: string[]
}

interface SensitivityData {
  exists?: boolean
  severity?: string
  description?: string
  signs?: string[]
}






