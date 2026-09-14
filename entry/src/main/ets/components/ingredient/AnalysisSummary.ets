import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct AnalysisSummary {
  @Prop analysis: SummaryData = {}
  build() {
    Column({ space: 16 }) {
      this.section('01', '功效分析', this.analysis.efficacyAnalysis || [])
      this.section('02', '潜在风险', this.analysis.potentialRisks || [])
      this.section('03', '使用建议', this.analysis.recommendations || [])
      if (this.analysis.summary) { this.section('04', '分析小结', [this.analysis.summary]) }
    }.width('100%')
  }
  @Builder
  section(number: string, title: string, items: string[]) {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Text(number).fontSize(12).fontColor(AISkinColor.accent)
        Text(title).fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
      }
      if (!items.length) { Text('该次分析未提供此项内容').fontSize(14).fontColor(AISkinColor.secondary) }
      ForEach(items, (item: string) => { Text(item).fontSize(14).lineHeight(24).fontColor(AISkinColor.text).width('100%') })
    }.width('100%').padding(20).alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle())
  }
}
export interface SummaryData { efficacyAnalysis?: string[]; potentialRisks?: string[]; recommendations?: string[]; overallRating?: number; summary?: string }
