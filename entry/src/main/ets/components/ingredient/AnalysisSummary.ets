import { AISkinReportHeading, AISkinReportTextItem } from '../../design/AISkinReportComponents'
import { AISkinSpacing } from '../../design/Foundation/AISkinTokens'
@Component
export struct AnalysisSummary {
  @Prop analysis: SummaryData = {}
  build() {
    Column({ space: AISkinSpacing.sectionGap }) {
      this.section('01', '功效分析', this.analysis.efficacyAnalysis || [])
      this.section('02', '潜在风险', this.analysis.potentialRisks || [])
      this.section('03', '使用建议', this.analysis.recommendations || [])
    }.width('100%')
  }
  @Builder
  section(number: string, title: string, items: string[]) {
    Column({ space: AISkinSpacing.medium }) {
      AISkinReportHeading({ number, title })
      if (!items.length) { AISkinReportTextItem({ text: '该次分析未提供此项内容' }) }
      ForEach(items, (item: string) => { AISkinReportTextItem({ text: item }) })
    }.width('100%')
  }
}
export interface SummaryData { efficacyAnalysis?: string[]; potentialRisks?: string[]; recommendations?: string[]; overallRating?: number; summary?: string }
