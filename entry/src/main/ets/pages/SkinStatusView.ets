import { AISkinColor, CardStyle } from '../design/AISkinTheme'
import { ProcessingPanel } from '../components/common/ProcessingPanel'
import router from '@ohos.router'
import { common } from '@kit.AbilityKit'
import { SkinAnalysisHeader } from '../components/skin-analysis/SkinAnalysisHeader'
import { SkinDetectionWelcome } from '../components/skin-analysis/SkinDetectionWelcome'
import { HealthScoreCard } from '../components/skin-analysis/HealthScoreCard'
import { SkinTypeAnalysis } from '../components/skin-analysis/SkinTypeAnalysis'
import { SkinStatusOverview } from '../components/skin-analysis/SkinStatusOverview'
import { AIRecommendations } from '../components/skin-analysis/AIRecommendations'
import { SkinAnalysisService } from '../services/SkinAnalysisService'
import { SkinAnalysisData, SkinAnalysisApiService, SkinContext } from '../services/SkinAnalysisApiService'
import { AIContentNotice } from '../components/common/AIContentNotice'

@Component
export struct SkinStatusView {
  @State contextEditing: boolean = false
  @State contextSaving: boolean = false
  @State contextCondition: string = ''
  @State contextLight: string = ''
  @State contextFeelings: string[] = []
  private reportScroller: Scroller = new Scroller()
  @State @Watch('resetReportScroll') showResults: boolean = false
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

  resetReportScroll(): void {
    setTimeout(() => { this.reportScroller.scrollTo({ xOffset: 0, yOffset: 0 }) }, 0)
  }

  requestAnalysisConsent(source: string) {
    AlertDialog.show({
      title: '确认AI图片处理',
      message: '你选择的面部照片会加密上传至阿里云私有对象存储，并通过短期签名链接交由通义千问视觉模型分析。照片和报告保存在你的账号中，供回看检测记录；删除记录或注销账号时会一并删除。不用于身份识别、广告或模型训练。结果仅供日常护肤参考，不构成医疗诊断。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '同意并继续',
        fontColor: AISkinColor.accent,
        action: () => {
          if (source === 'gallery') { this.selectPhoto() } else { this.startPhotoCapture() }
        }
      },
      cancel: () => {}
    })
  }

  aboutToAppear() {
    this.loadHistoryData()
  }

  async loadHistoryData() {
    console.log('===== 📚 加载历史数据 =====')
    try {
      const response = await this.skinAnalysisService.getHistory(1, 50)
      if (!response.success) { this.errorMessage = response.message || '检测历史加载失败'; return }
      
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
      console.error('❌ 加载历史数据失败')
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
        this.errorMessage = response.message?.includes('取消') || response.message === '未选择图片' ? '' : response.message || '分析失败'
      }
    } catch (error) {
      console.error('❌ 拍照分析失败')
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
        this.errorMessage = response.message?.includes('取消') || response.message === '未选择图片' ? '' : response.message || '分析失败'
      }
    } catch (error) {
      console.error('❌ 选择照片分析失败')
      this.isAnalyzing = false
      this.errorMessage = `分析失败: ${error}`
    }
  }

  /**
   * 将API响应数据转换为页面使用的AnalysisResult格式
   */
  convertToAnalysisResult(data: SkinAnalysisData): AnalysisResult {
    const result = new AnalysisResult()
    result.imageUrl = data.imageUrl || ''
    result.context = data.context || {}
    result.id = data._id || data.analysisId || ''
    
    // Overall Assessment
    if (data.overallAssessment) {
      const overallAssessment = new OverallAssessment()
      overallAssessment.healthScore = data.overallAssessment.healthScore ?? -1
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
    result.oilLevel = data.oilLevel || '未记录'
    result.moistureLevel = data.moistureLevel || '未记录'
    result.poreLevel = data.pores?.severity || '未记录'
    
    // Blackheads
    if (data.blackheads) {
      const blackheads = new BlackheadsInfo()
      blackheads.exists = data.blackheads.exists
      blackheads.severity = data.blackheads.severity || '无'
      blackheads.description = data.blackheads.description || ''
      blackheads.distribution = data.blackheads.distribution || []
      result.blackheads = blackheads
    }
    
    // Acne
    if (data.acne) {
      const acne = new AcneInfo()
      acne.exists = data.acne.exists
      acne.count = data.acne.count || '无'
      acne.types = data.acne.types || []
      acne.description = data.acne.description || ''
      acne.distribution = data.acne.distribution || []
      result.acne = acne
    }
    
    // Pores
    if (data.pores) {
      const pores = new PoresInfo()
      pores.enlarged = data.pores.enlarged
      pores.severity = data.pores.severity || '正常'
      pores.description = data.pores.description || ''
      pores.distribution = data.pores.distribution || []
      result.pores = pores
    }
    
    // Other Issues
    const otherIssues = new OtherIssues()
    if (data.otherIssues) {
      if (data.otherIssues.skinToneEvenness) {
        const skinToneEvenness = new SkinToneEvenness()
        skinToneEvenness.score = data.otherIssues.skinToneEvenness.score
        skinToneEvenness.description = data.otherIssues.skinToneEvenness.description || ''
        otherIssues.skinToneEvenness = skinToneEvenness
      }
      
      if (data.otherIssues.redness) {
        const redness = new RednessInfo()
        redness.exists = data.otherIssues.redness.exists
        redness.severity = data.otherIssues.redness.severity || '无'
        redness.description = data.otherIssues.redness.description || ''
        redness.distribution = data.otherIssues.redness.distribution || []
        otherIssues.redness = redness
      }
      
      if (data.otherIssues.hyperpigmentation) {
        const hyperpigmentation = new HyperpigmentationInfo()
        hyperpigmentation.exists = data.otherIssues.hyperpigmentation.exists
        hyperpigmentation.severity = data.otherIssues.hyperpigmentation.severity || '无'
        hyperpigmentation.description = data.otherIssues.hyperpigmentation.description || ''
        hyperpigmentation.types = data.otherIssues.hyperpigmentation.types || []
        hyperpigmentation.distribution = data.otherIssues.hyperpigmentation.distribution || []
        otherIssues.hyperpigmentation = hyperpigmentation
      }
      
      if (data.otherIssues.fineLines) {
        const fineLines = new FineLinesInfo()
        fineLines.exists = data.otherIssues.fineLines.exists
        fineLines.severity = data.otherIssues.fineLines.severity || '无'
        fineLines.description = data.otherIssues.fineLines.description || ''
        fineLines.distribution = data.otherIssues.fineLines.distribution || []
        otherIssues.fineLines = fineLines
      }
      
      if (data.otherIssues.sensitivity) {
        const sensitivity = new SensitivityInfo()
        sensitivity.exists = data.otherIssues.sensitivity.exists
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
    return '未记录'
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
    return '未记录'
  }

  deleteCurrentAnalysis(): void {
    const analysisId = this.analysisResult?.id
    if (!analysisId) return
    AlertDialog.show({ title: '删除检测记录', message: '将删除本次检测照片和报告，无法恢复。',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '删除', fontColor: AISkinColor.danger, action: () => { this.removeAnalysis(analysisId) } } })
  }
  async removeAnalysis(id: string): Promise<void> {
    const response = await this.skinAnalysisService.deleteAnalysis(id)
    if (!response.success) { this.errorMessage = response.message || '删除失败，请重试'; return }
    this.resetAnalysis()
    await this.loadHistoryData()
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
    if (!dateString) return '未记录时间'
    const date = new Date(dateString)
    return Number.isNaN(date.getTime()) ? '未记录时间' : date.toLocaleDateString('zh-CN')
  }
  comparisonText(): string {
    const index = this.historyList.findIndex(item => item.id === this.analysisResult?.id)
    const previous = index >= 0 ? this.historyList[index + 1] : undefined
    if (!previous) return '这是该时间点的首次记录，后续可在历史中比较变化。'
    const before = previous.overallAssessment?.healthScore
    const current = this.analysisResult?.overallAssessment?.healthScore
    if (before === undefined || current === undefined || before < 0 || current < 0) return '两次记录的评分信息不完整。'
    return `上次 ${this.formatDate(previous.createdAt)}：${before} 分 · 本次：${current} 分。拍摄光线与状态可能影响结果。`
  }

  getHistorySummary(): string {
    if (!this.lastAnalysisResult) {
      return ''
    }
    return this.lastAnalysisResult.overallAssessment?.summary ||
      '该次记录暂无结论'
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

        if (this.errorMessage) { Text(this.errorMessage).fontColor(AISkinColor.danger).fontSize(14).lineHeight(22).padding(20) }
        // Main Content
        Scroll(this.reportScroller) {
          Column() {
            // Welcome/Detection State
            if (!this.showResults) {
              SkinDetectionWelcome({
                onTakePhoto: () => { this.requestAnalysisConsent('camera') },
                onSelectPhoto: (): void => {
                  this.requestAnalysisConsent('gallery')
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
                        .fontColor(AISkinColor.text)
                    }
                    .layoutWeight(1)

                    Text(this.formatDate(this.lastAnalysisDate))
                      .fontSize(12)
                      .fontColor(AISkinColor.secondary)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor(AISkinColor.muted)
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
                    .backgroundColor(AISkinColor.primary)
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
                        .fontColor(AISkinColor.text)
                        .lineHeight(20)
                        .margin({ bottom: 12 })

                      Button('查看详情')
                        .type(ButtonType.Normal)
                        .fontSize(12)
                        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                        .backgroundColor(AISkinColor.muted)
                        .fontColor(AISkinColor.text)
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
                  .attributeModifier(new CardStyle())
                  .margin({ bottom: 16 })
                }
                .width('100%')
                .padding(16)
                .attributeModifier(new CardStyle())
                .margin({ left: 16, right: 16, bottom: 16 })
              }
            }

            // Results State
            if (this.showResults && this.analysisResult) {
              Column() {
                AIContentNotice({ scene: '肌肤检测' })
                  .margin({ top: 20, left: 16, right: 16, bottom: 16 })


                if (this.analysisResult.imageUrl) {
                  Image(this.analysisResult.imageUrl).width('88%').height(200).objectFit(ImageFit.Contain).borderRadius(20).margin({ bottom: 20 }).accessibilityText('本次检测照片')
                }
                Text(this.analysisResult.overallAssessment?.summary || '该次记录暂无结论').fontSize(14).lineHeight(24).fontColor(AISkinColor.text).width('90%').padding(20).attributeModifier(new CardStyle()).margin({ bottom: 20 })
                HealthScoreCard({ score: this.analysisResult.overallAssessment?.healthScore ?? -1 })
                  .margin({ left: 16, right: 16, bottom: 20 })

                SkinTypeAnalysis({
                  skinType: this.analysisResult.skinType || new SkinTypeInfo(),
                  oilLevel: this.analysisResult.oilLevel || '未记录',
                  moistureLevel: this.analysisResult.moistureLevel || '未记录',
                  poreLevel: this.analysisResult.poreLevel || '未记录'
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

                this.ContextCard()
                AIRecommendations({
                  recommendations: this.analysisResult.overallAssessment?.recommendations || []
                })
                .margin({ left: 16, right: 16, bottom: 0 })
                Button('重新检测').height(48).width('90%').backgroundColor(AISkinColor.primary).fontColor(Color.White).margin({ top: 20 }).onClick(() => { this.resetAnalysis() })
                Button('删除检测记录').height(48).fontColor(AISkinColor.danger).backgroundColor(Color.Transparent).onClick(() => { this.deleteCurrentAnalysis() })
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding({ bottom: 90 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off).align(Alignment.Top)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.None)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)

      if (this.contextEditing) { this.ContextEditor() }
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

  async saveContext(): Promise<void> {
    const id = this.analysisResult?.id
    if (!id || this.contextSaving) return
    this.contextSaving = true
    const result = await SkinAnalysisApiService.getInstance().updateContext(id, { condition: this.contextCondition, light: this.contextLight, feelings: this.contextFeelings })
    this.contextSaving = false
    if (!result.success) { AlertDialog.show({ title: '保存失败', message: result.message || '请稍后重试', primaryButton: { value: '知道了', action: () => {} } }); return }
    if (result.data?.analysis) this.analysisResult = this.convertToAnalysisResult(result.data.analysis)
    this.contextEditing = false
    await this.loadHistoryData()
  }
  @Builder
  ContextCard() {
    Column({ space: 12 }) {
      Text('本次记录信息').fontSize(18).fontColor(AISkinColor.text)
      Text(this.comparisonText()).fontSize(13).lineHeight(22).fontColor(AISkinColor.secondary)
      Text([this.analysisResult?.context.condition || '未记录拍摄状态', this.analysisResult?.context.light || '未记录光线', (this.analysisResult?.context.feelings || []).join('、')].filter(value => value.length > 0).join(' · ')).fontSize(13).lineHeight(22).fontColor(AISkinColor.secondary)
      Button('补充拍摄状态').height(44).fontColor(AISkinColor.accent).backgroundColor(Color.Transparent).onClick(() => {
        this.contextCondition = this.analysisResult?.context.condition || ''
        this.contextLight = this.analysisResult?.context.light || ''
        this.contextFeelings = this.analysisResult?.context.feelings || []
        this.contextEditing = true
      })
    }.width('90%').padding(20).margin({ bottom: 20 }).attributeModifier(new CardStyle())
  }
  @Builder
  ContextEditor() {
    Stack() {
      Column({ space: 16 }) {
        Text('拍摄时的状态').fontSize(20).fontColor(AISkinColor.text)
        Text('帮助理解两次检测结果的差异，不会改变AI原始评分。').fontSize(13).lineHeight(22).fontColor(AISkinColor.secondary)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(['未记录', '洁面前', '洁面后', '护肤后', '上妆后'], (value: string) => {
            Button(value).height(44).margin(4).fontColor(AISkinColor.text).backgroundColor(this.contextCondition === value ? AISkinColor.selected : AISkinColor.muted).onClick(() => { this.contextCondition = value === '未记录' ? '' : value })
          })
        }
        Row({ space: 8 }) {
          ForEach(['自然光','室内光','不确定'], (value: string) => { Button(value).height(44).layoutWeight(1).fontColor(AISkinColor.text).backgroundColor(this.contextLight === value ? AISkinColor.selected : AISkinColor.muted).onClick(() => { this.contextLight = value }) })
        }
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(['紧绷','出油','刺痛','泛红','无不适'], (value: string) => { Button(value).height(44).margin(4).fontColor(AISkinColor.text).backgroundColor(this.contextFeelings.includes(value) ? AISkinColor.selected : AISkinColor.muted).onClick(() => { this.contextFeelings = this.contextFeelings.includes(value) ? this.contextFeelings.filter(item => item !== value) : this.contextFeelings.concat([value]) }) })
        }
        Button(this.contextSaving ? '保存中…' : '保存拍摄状态').height(48).width('100%').enabled(!this.contextSaving).backgroundColor(AISkinColor.primary).fontColor(Color.White).onClick(() => { this.saveContext() })
        Button('取消').height(44).enabled(!this.contextSaving).fontColor(AISkinColor.secondary).backgroundColor(Color.Transparent).onClick(() => { this.contextEditing = false })
      }.width('90%').constraintSize({ maxWidth: 480 }).padding(24).borderRadius(24).backgroundColor(AISkinColor.dialog)
    }.width('100%').height('100%').backgroundColor(AISkinColor.scrim)
  }

  @Builder
  AnalysisBasisCard() {
    Column() {
      Text('检测依据与结果说明')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AISkinColor.text)
        .width('100%')
        .margin({ bottom: 10 })
      Text(this.analysisResult?.skinType?.basis || '依据用户主动选择的面部照片，对肤质、油脂、水分、毛孔及可见肌肤问题进行分析。')
        .fontSize(13)
        .fontColor(AISkinColor.text)
        .lineHeight(20)
        .width('100%')
      Text('可在右上角查看历史记录，对比不同检测时间的结果变化。')
        .fontSize(13)
        .fontColor(AISkinColor.text)
        .lineHeight(20)
        .width('100%')
        .margin({ top: 6 })
    }
    .width('auto')
    .padding(14)
    .backgroundColor(AISkinColor.white)
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  AnalyzingModal() {
    Stack() { ProcessingPanel({ title: '肌肤检测', message: this.analysisStatus }) }
      .width('100%').height('100%').backgroundColor(AISkinColor.scrim)
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
            .fontColor(AISkinColor.text)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(24)
              .fontColor(AISkinColor.secondary)
          }
          .type(ButtonType.Normal)
          .width(36)
          .height(36)
          .backgroundColor(AISkinColor.muted)
          .borderRadius(18)
          .onClick(() => {
            this.closeHistoryModal()
          })
        }
        .width('100%')
        .padding({ bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: AISkinColor.divider,
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
              .fontColor(AISkinColor.secondary)
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
      .attributeModifier(new CardStyle())
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AISkinColor.scrim)
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
        .fontColor(AISkinColor.accent)
        .margin({ right: 16 })

      Column() {
        Text(this.formatDate(history.createdAt || ''))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 4 })

        Text(history.overallAssessment?.summary || '无摘要')
          .fontSize(12)
          .fontColor(AISkinColor.secondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('›')
        .fontSize(20)
        .fontColor(AISkinColor.secondary)
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      this.loadHistoryResult(history)
    })
    .border({
      width: { bottom: index < this.historyList.length - 1 ? 1 : 0 },
      color: AISkinColor.muted,
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
  description: string = ''
  exists?: boolean = undefined
  severity: string = ''
  distribution: string[] = []
}

class AcneInfo {
  description: string = ''
  exists?: boolean = undefined
  count: string = ''
  types: string[] = []
  distribution: string[] = []
}

class PoresInfo {
  description: string = ''
  enlarged?: boolean = undefined
  severity: string = ''
  distribution: string[] = []
}

class SkinToneEvenness {
  score?: number = undefined
  description: string = ''
}

class RednessInfo {
  exists?: boolean = undefined
  severity: string = ''
  description: string = ''
  distribution: string[] = []
}

class HyperpigmentationInfo {
  exists?: boolean = undefined
  severity: string = ''
  description: string = ''
  types: string[] = []
  distribution: string[] = []
}

class FineLinesInfo {
  exists?: boolean = undefined
  severity: string = ''
  description: string = ''
  distribution: string[] = []
}

class SensitivityInfo {
  exists?: boolean = undefined
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
  id: string = ''
  imageUrl: string = ''
  context: SkinContext = {}
}
