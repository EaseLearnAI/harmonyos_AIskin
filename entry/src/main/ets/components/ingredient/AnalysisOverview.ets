import { AISkinReportScore, AISkinReportScoreLayout } from '../../design/AISkinReportComponents'
@Component
export struct AnalysisOverview {
  @Prop analysis: AnalysisData = {}
  build() {
    AISkinReportScore({ label: 'AI 综合评分', layout: AISkinReportScoreLayout.SummaryFirst, score: this.analysis.overallRating ?? -1, title: '产品总结', summary: this.analysis.summary || '该次记录暂无产品总结' })
  }
}
export interface RiskData { level?: string; percentage?: number }
export interface AnalysisData { overallRating?: number; summary?: string; safetyIndex?: number; efficacyScore?: number; activeIngredients?: number; acneRisk?: RiskData; irritationRisk?: RiskData; allergyRisk?: RiskData }
