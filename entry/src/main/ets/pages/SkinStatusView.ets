import router from '@ohos.router'
import { common } from '@kit.AbilityKit'
import { SkinAnalysisHeader } from '../components/skin-analysis/SkinAnalysisHeader'
import { SkinDetectionWelcome } from '../components/skin-analysis/SkinDetectionWelcome'
import { HealthScoreCard } from '../components/skin-analysis/HealthScoreCard'
import { SkinTypeAnalysis } from '../components/skin-analysis/SkinTypeAnalysis'
import { SkinStatusOverview } from '../components/skin-analysis/SkinStatusOverview'
import { AIRecommendations } from '../components/skin-analysis/AIRecommendations'
import { SkinAnalysisService } from '../services/SkinAnalysisService'
import { SkinAnalysisData } from '../services/SkinAnalysisApiService'

@Component
export struct SkinStatusView {
  @State showResults: boolean = false
  @State isAnalyzing: boolean = false
  @State showHistoryModal: boolean = false
  @State progress: number = 0
  @State analysisStatus: string = '正在上传图片到云端...'
  @State analysisResult: AnalysisResult | null = null
  @State hasHistoryResults: boolean = false
  @State lastAnalysisDate: string = ''
  @State lastAnalysisResult: AnalysisResult | null = null
  @State historyList: AnalysisResult[] = []
  @State errorMessage: string = ''
  onBack?: () => void
  private skinAnalysisService: SkinAnalysisService = SkinAnalysisService.getInstance()

  aboutToAppear() {
    this.loadHistoryData()
  }

  async loadHistoryData() {
    console.log('===== 📚 加载历史数据 =====')
    try {
      const response = await this.skinAnalysisService.getHistory(1, 10)
      
      if (response.success && response.data?.analyses && response.data.analyses.length > 0) {
        this.historyList = response.data.analyses.map((item: SkinAnalysisData) => {
          return this.convertToAnalysisResult(item)
        })
        
        // 获取最新的分析结果
        const latest = this.historyList[0]
        this.lastAnalysisResult = latest
        this.lastAnalysisDate = latest.createdAt || ''
        this.hasHistoryResults = true
        
        console.log(`✅ 历史数据加载成功,共${this.historyList.length}条记录`)
      } else {
        this.hasHistoryResults = false
        console.log('ℹ️ 暂无历史记录')
      }
    } catch (error) {
      console.error('❌ 加载历史数据失败:', JSON.stringify(error))
      this.hasHistoryResults = false
    }
  }

  async startPhotoCapture() {
    console.log('===== 📷 启动拍照功能 =====')
    this.isAnalyzing = true
    this.showResults = false
    this.progress = 0
    this.analysisStatus = '正在启动相机...'
    this.errorMessage = ''
    
    try {
      // 获取应用上下文 - 在ArkUI组件中使用getUIContext().getHostContext()
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      if (!context) {
        this.isAnalyzing = false
        this.errorMessage = '无法获取应用上下文'
        return
      }
      
      const response = await this.skinAnalysisService.analyzeFromCamera(
        context,
        (progress: number, status: string) => {
          this.progress = progress
          this.analysisStatus = status
        }
      )
      
      if (response.success && response.data) {
        this.analysisResult = this.convertToAnalysisResult(response.data)
        this.isAnalyzing = false
        this.showResults = true
        await this.loadHistoryData()
      } else {
        this.isAnalyzing = false
        this.errorMessage = response.message || '分析失败'
      }
    } catch (error) {
      console.error('❌ 拍照分析失败:', JSON.stringify(error))
      this.isAnalyzing = false
      this.errorMessage = `分析失败: ${error}`
    }
  }

  async selectPhoto() {
    console.log('===== 🖼️ 启动照片选择功能 =====')
    // 注意: 不要立即设置isAnalyzing=true,等用户真正选择图片后再显示模态框
    this.showResults = false
    this.progress = 0
    this.analysisStatus = '正在打开相册...'
    this.errorMessage = ''
    
    try {
      // 获取应用上下文 - 在ArkUI组件中使用getUIContext().getHostContext()
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      
      // 先选择图片,不显示模态框
      const response = await this.skinAnalysisService.analyzeFromGallery(
        context,
        (progress: number, status: string) => {
          // 只有在用户选择图片后才显示模态框
          if (progress >= 20) {
            this.isAnalyzing = true
          }
          this.progress = progress
          this.analysisStatus = status
        }
      )
      
      if (response.success && response.data) {
        this.analysisResult = this.convertToAnalysisResult(response.data)
        this.isAnalyzing = false
        this.showResults = true
        await this.loadHistoryData()
      } else {
        this.isAnalyzing = false
        this.errorMessage = response.message || '分析失败'
      }
    } catch (error) {
      console.error('❌ 选择照片分析失败:', JSON.stringify(error))
      this.isAnalyzing = false
      this.errorMessage = `分析失败: ${error}`
    }
  }

  /**
   * 将API响应数据转换为页面使用的AnalysisResult格式
   */
  convertToAnalysisResult(data: SkinAnalysisData): AnalysisResult {
    const result = new AnalysisResult()
    
    // Overall Assessment
    if (data.overallAssessment) {
      const overallAssessment = new OverallAssessment()
      overallAssessment.healthScore = data.overallAssessment.healthScore || 0
      overallAssessment.summary = data.overallAssessment.summary || ''
      overallAssessment.recommendations = data.overallAssessment.recommendations || []
      result.overallAssessment = overallAssessment
    }
    
    // Skin Type
    if (data.skinType) {
      const skinType = new SkinTypeInfo()
      skinType.type = data.skinType.type || ''
      skinType.subtype = data.skinType.subtype || ''
      skinType.basis = data.skinType.basis || ''
      result.skinType = skinType
    }
    
    // Oil/Moisture/Pore Levels (从数据中推断或使用默认值)
    result.oilLevel = this.inferOilLevel(data)
    result.moistureLevel = this.inferMoistureLevel(data)
    result.poreLevel = data.pores?.severity || '正常'
    
    // Blackheads
    if (data.blackheads) {
      const blackheads = new BlackheadsInfo()
      blackheads.exists = data.blackheads.exists || false
      blackheads.severity = data.blackheads.severity || '无'
      blackheads.distribution = data.blackheads.distribution || []
      result.blackheads = blackheads
    }
    
    // Acne
    if (data.acne) {
      const acne = new AcneInfo()
      acne.exists = data.acne.exists || false
      acne.count = data.acne.count || '无'
      acne.types = data.acne.types || []
      acne.distribution = data.acne.distribution || []
      result.acne = acne
    }
    
    // Pores
    if (data.pores) {
      const pores = new PoresInfo()
      pores.enlarged = data.pores.enlarged || false
      pores.severity = data.pores.severity || '正常'
      pores.distribution = data.pores.distribution || []
      result.pores = pores
    }
    
    // Other Issues
    const otherIssues = new OtherIssues()
    if (data.otherIssues) {
      if (data.otherIssues.skinToneEvenness) {
        const skinToneEvenness = new SkinToneEvenness()
        skinToneEvenness.score = data.otherIssues.skinToneEvenness.score || 0
        skinToneEvenness.description = data.otherIssues.skinToneEvenness.description || ''
        otherIssues.skinToneEvenness = skinToneEvenness
      }
      
      if (data.otherIssues.redness) {
        const redness = new RednessInfo()
        redness.exists = data.otherIssues.redness.exists || false
        redness.severity = data.otherIssues.redness.severity || '无'
        redness.description = data.otherIssues.redness.description || ''
        redness.distribution = data.otherIssues.redness.distribution || []
        otherIssues.redness = redness
      }
      
      if (data.otherIssues.hyperpigmentation) {
        const hyperpigmentation = new HyperpigmentationInfo()
        hyperpigmentation.exists = data.otherIssues.hyperpigmentation.exists || false
        hyperpigmentation.severity = data.otherIssues.hyperpigmentation.severity || '无'
        hyperpigmentation.description = data.otherIssues.hyperpigmentation.description || ''
        hyperpigmentation.types = data.otherIssues.hyperpigmentation.types || []
        hyperpigmentation.distribution = data.otherIssues.hyperpigmentation.distribution || []
        otherIssues.hyperpigmentation = hyperpigmentation
      }
      
      if (data.otherIssues.fineLines) {
        const fineLines = new FineLinesInfo()
        fineLines.exists = data.otherIssues.fineLines.exists || false
        fineLines.severity = data.otherIssues.fineLines.severity || '无'
        fineLines.description = data.otherIssues.fineLines.description || ''
        fineLines.distribution = data.otherIssues.fineLines.distribution || []
        otherIssues.fineLines = fineLines
      }
      
      if (data.otherIssues.sensitivity) {
        const sensitivity = new SensitivityInfo()
        sensitivity.exists = data.otherIssues.sensitivity.exists || false
        sensitivity.severity = data.otherIssues.sensitivity.severity || '无'
        sensitivity.description = data.otherIssues.sensitivity.description || ''
        sensitivity.signs = data.otherIssues.sensitivity.signs || []
        otherIssues.sensitivity = sensitivity
      }
    }
    result.otherIssues = otherIssues
    
    // Timestamp
    result.createdAt = data.createdAt || ''
    
    return result
  }

  /**
   * 推断油脂水平
   */
  private inferOilLevel(data: SkinAnalysisData): string {
    if (data.oilLevel) {
      return data.oilLevel
    }
    // 根据皮肤类型推断
    if (data.skinType?.type?.includes('油')) {
      return '偏高'
    } else if (data.skinType?.type?.includes('干')) {
      return '低'
    }
    return '正常'
  }

  /**
   * 推断水分水平
   */
  private inferMoistureLevel(data: SkinAnalysisData): string {
    if (data.moistureLevel) {
      return data.moistureLevel
    }
    // 根据moisture数值推断
    if (data.moisture !== undefined) {
      if (data.moisture >= 80) return '高'
      if (data.moisture >= 60) return '正常'
      if (data.moisture >= 40) return '偏低'
      return '低'
    }
    return '正常'
  }

  resetAnalysis() {
    this.isAnalyzing = false
    this.showResults = false
    this.progress = 0
    this.analysisResult = null
    this.errorMessage = ''
  }


  goBack() {
    if (this.onBack) {
      this.onBack()
    } else {
      console.info('Go back')
    }
  }

  showHistory() {
    this.showHistoryModal = true
  }

  closeHistoryModal() {
    this.showHistoryModal = false
  }

  showHistoryResults() {
    if (this.lastAnalysisResult) {
      this.analysisResult = this.lastAnalysisResult
      this.showResults = true
    }
  }

  loadHistoryResult(history: AnalysisResult) {
    this.analysisResult = history
    this.showResults = true
    this.closeHistoryModal()
  }

  formatDate(dateString: string): string {
    if (!dateString) {
      return ''
    }
    const date = new Date(dateString)
    const now = new Date()
    const diffTime = Math.abs(now.getTime() - date.getTime())
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    if (diffDays === 1) {
      return '今天'
    } else if (diffDays === 2) {
      return '昨天'
    } else if (diffDays <= 7) {
      return `${diffDays - 1}天前`
    } else {
      return date.toLocaleDateString('zh-CN')
    }
  }

  getHistorySummary(): string {
    if (!this.lastAnalysisResult) {
      return ''
    }
    return this.lastAnalysisResult.overallAssessment?.summary ||
      `${this.lastAnalysisResult.skinType?.type}，肌肤状态良好`
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // Header
        SkinAnalysisHeader({
          onBack: (): void => {
            if (this.onBack) {
              this.onBack()
            }
          },
          onShowHistory: (): void => {
            this.showHistory()
          }
        })
        .width('100%')

        // Main Content
        Scroll() {
          Column() {
            // Welcome/Detection State
            if (!this.showResults) {
              SkinDetectionWelcome({
                onTakePhoto: (): void => {
                  this.startPhotoCapture()
                },
                onSelectPhoto: (): void => {
                  this.selectPhoto()
                }
              })
              .margin({ top: 16, left: 16, right: 16, bottom: 16 })

              // History Section
              if (this.hasHistoryResults) {
                Column() {
                  Row() {
                    Row() {
                      Text('🕐')
                        .fontSize(16)
                        .margin({ right: 8 })
                      Text('上次检测结果')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#374151')
                    }
                    .layoutWeight(1)

                    Text(this.formatDate(this.lastAnalysisDate))
                      .fontSize(12)
                      .fontColor('#6B7280')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor('#F3F4F6')
                      .borderRadius(8)
                  }
                  .width('100%')
                  .margin({ bottom: 16 })

                  Row() {
                    Column() {
                      Text((this.lastAnalysisResult?.overallAssessment?.healthScore || 0).toString())
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Color.White)
                      Text('健康分')
                        .fontSize(12)
                        .fontColor(Color.White)
                        .opacity(0.9)
                    }
                    .width(80)
                    .height(80)
                    .backgroundColor('#667eea')
                    .borderRadius(16)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .margin({ right: 16 })
                    .onClick(() => {
                      this.showHistoryResults()
                    })

                    Column() {
                      Text(this.getHistorySummary())
                        .fontSize(14)
                        .fontColor('#374151')
                        .lineHeight(20)
                        .margin({ bottom: 12 })

                      Button('查看详情')
                        .type(ButtonType.Normal)
                        .fontSize(12)
                        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                        .backgroundColor('#F3F4F6')
                        .fontColor('#374151')
                        .borderRadius(8)
                        .onClick(() => {
                          this.showHistoryResults()
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .margin({ bottom: 16 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .margin({ left: 16, right: 16, bottom: 16 })
              }
            }

            // Results State
            if (this.showResults && this.analysisResult) {
              Column() {
                HealthScoreCard({ score: this.analysisResult.overallAssessment?.healthScore || 0 })
                  .margin({ top: 20, left: 16, right: 16, bottom: 20 })

                SkinTypeAnalysis({
                  skinType: this.analysisResult.skinType || new SkinTypeInfo(),
                  oilLevel: this.analysisResult.oilLevel || '正常',
                  moistureLevel: this.analysisResult.moistureLevel || '正常',
                  poreLevel: this.analysisResult.poreLevel || '正常'
                })
                .margin({ left: 16, right: 16, bottom: 20 })

                SkinStatusOverview({
                  blackheads: this.analysisResult.blackheads || new BlackheadsInfo(),
                  acne: this.analysisResult.acne || new AcneInfo(),
                  pores: this.analysisResult.pores || new PoresInfo(),
                  skinToneEvenness: this.analysisResult.otherIssues?.skinToneEvenness || new SkinToneEvenness(),
                  redness: this.analysisResult.otherIssues?.redness || new RednessInfo(),
                  hyperpigmentation: this.analysisResult.otherIssues?.hyperpigmentation || new HyperpigmentationInfo(),
                  fineLines: this.analysisResult.otherIssues?.fineLines || new FineLinesInfo(),
                  sensitivity: this.analysisResult.otherIssues?.sensitivity || new SensitivityInfo()
                })
                .margin({ left: 16, right: 16, bottom: 20 })

                AIRecommendations({
                  recommendations: this.analysisResult.overallAssessment?.recommendations || []
                })
                .margin({ left: 16, right: 16, bottom: 0 })
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding({ bottom: 90 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.None)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#fff9fb')

      // Analyzing Modal
      if (this.isAnalyzing) {
        this.AnalyzingModal()
      }

      // History Modal
      if (this.showHistoryModal) {
        this.HistoryModal()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AnalyzingModal() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        LoadingProgress()
          .width(64)
          .height(64)
          .color('#F8BBD0')
          .margin({ bottom: 24 })

        Text('AI正在分析中...')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#374151')
          .margin({ bottom: 8 })

        Text(this.analysisStatus)
          .fontSize(14)
          .fontColor('#6B7280')
          .margin({ bottom: 24 })

        // Progress Bar
        Column() {
          Stack() {
            Column()
              .width('100%')
              .height(8)
              .backgroundColor('rgba(0, 0, 0, 0.05)')
              .borderRadius(4)

            Column()
              .width(this.progress + '%')
              .height(8)
              .backgroundColor('#F8BBD0')
              .borderRadius(4)
          }
          .width('100%')
          .height(8)
          .margin({ bottom: 8 })

          Text(Math.round(this.progress) + '%')
            .fontSize(12)
            .fontColor('#6B7280')
        }
        .width('100%')
        .margin({ bottom: 16 })

        Text('请稍候，通常需要10-30秒完成分析')
          .fontSize(12)
          .fontColor('#9CA3AF')
          .fontStyle(FontStyle.Italic)
      }
      .width('90%')
      .padding(40)
      .backgroundColor(Color.White)
      .borderRadius(24)
      .shadow({
        radius: 20,
        color: 'rgba(0, 0, 0, 0.2)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.7)')
    .onClick(() => {
      // Prevent closing on background click during analysis
    })
  }

  @Builder
  HistoryModal() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // Header
        Row() {
          Text('检测历史')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(24)
              .fontColor('#6B7280')
          }
          .type(ButtonType.Normal)
          .width(36)
          .height(36)
          .backgroundColor('#F3F4F6')
          .borderRadius(18)
          .onClick(() => {
            this.closeHistoryModal()
          })
        }
        .width('100%')
        .padding({ bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#E5E7EB',
          style: BorderStyle.Solid
        })

        // Content
        if (this.historyList.length === 0) {
          Column() {
            Text('🔍')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('暂无检测历史')
              .fontSize(14)
              .fontColor('#6B7280')
          }
          .width('100%')
          .padding(40)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              ForEach(this.historyList, (history: AnalysisResult, index: number) => {
                this.HistoryItem(history, index)
              })
            }
            .width('100%')
          }
          .layoutWeight(1)
        }
      }
      .width('90%')
      .height('80%')
      .padding(24)
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
      this.closeHistoryModal()
    })
  }

  @Builder
  HistoryItem(history: AnalysisResult, index: number) {
    Row() {
      Text((history.overallAssessment?.healthScore || 0).toString())
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#6366F1')
        .margin({ right: 16 })

      Column() {
        Text(this.formatDate(history.createdAt || ''))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#374151')
          .margin({ bottom: 4 })

        Text(history.overallAssessment?.summary || '无摘要')
          .fontSize(12)
          .fontColor('#6B7280')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('›')
        .fontSize(20)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      this.loadHistoryResult(history)
    })
    .border({
      width: { bottom: index < this.historyList.length - 1 ? 1 : 0 },
      color: '#F3F4F6',
      style: BorderStyle.Solid
    })
  }
}

// Data Models
class OverallAssessment {
  healthScore: number = 0
  summary: string = ''
  recommendations: string[] = []
}

class SkinTypeInfo {
  type: string = ''
  subtype: string = ''
  basis: string = ''
}

class BlackheadsInfo {
  exists: boolean = false
  severity: string = ''
  distribution: string[] = []
}

class AcneInfo {
  exists: boolean = false
  count: string = ''
  types: string[] = []
  distribution: string[] = []
}

class PoresInfo {
  enlarged: boolean = false
  severity: string = ''
  distribution: string[] = []
}

class SkinToneEvenness {
  score: number = 0
  description: string = ''
}

class RednessInfo {
  exists: boolean = false
  severity: string = ''
  description: string = ''
  distribution: string[] = []
}

class HyperpigmentationInfo {
  exists: boolean = false
  severity: string = ''
  description: string = ''
  types: string[] = []
  distribution: string[] = []
}

class FineLinesInfo {
  exists: boolean = false
  severity: string = ''
  description: string = ''
  distribution: string[] = []
}

class SensitivityInfo {
  exists: boolean = false
  severity: string = ''
  description: string = ''
  signs: string[] = []
}

class OtherIssues {
  skinToneEvenness: SkinToneEvenness | null = null
  redness: RednessInfo | null = null
  hyperpigmentation: HyperpigmentationInfo | null = null
  fineLines: FineLinesInfo | null = null
  sensitivity: SensitivityInfo | null = null
}

class AnalysisResult {
  overallAssessment: OverallAssessment | null = null
  skinType: SkinTypeInfo | null = null
  oilLevel: string = ''
  moistureLevel: string = ''
  poreLevel: string = ''
  blackheads: BlackheadsInfo | null = null
  acne: AcneInfo | null = null
  pores: PoresInfo | null = null
  otherIssues: OtherIssues | null = null
  createdAt: string = ''
}

