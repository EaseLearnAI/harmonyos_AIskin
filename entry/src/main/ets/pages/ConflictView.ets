import { AISkinReportTokens } from '../design/Foundation/AISkinReportTokens'
import { AISkinHeaderLayout } from '../design/AISkinPrimitives'
import { CardStyle } from '../design/AISkinTheme'
import { AISkinReportHeading, AISkinReportScore, AISkinReportTextItem, AISkinReportScreen } from '../design/AISkinReportComponents'
import { AISkinStateView } from '../design/AISkinPrimitives'
import { AISkinCardInset, AISkinCardRole, AISkinCardState, AISkinSpacing, AISkinStateKind } from '../design/Foundation/AISkinTokens'
import { AppHeader } from '../components/common/AppHeader'
import { AIContentNotice } from '../components/common/AIContentNotice'
import { ConflictAnalysisData, ConflictProductPair, ConflictAdvice, ConflictItem, SafeComboItem, PairingItem, ConflictProductInfo } from '../components/product/ConflictApiService'
@Component
export struct ConflictView {
  @Prop conflictData: ConflictAnalysisData | null = null
  onBack?: () => void
  private productName(id: string): string { return this.conflictData?.products?.find(item => (item.id || item._id) === id)?.name || '已移除产品' }
  private statusLabel(status: string): string {
    if (status === 'compatible') return '未发现明确冲突'
    if (status === 'caution') return '叠加需注意'
    if (status === 'avoid') return '不建议同时使用'
    return '暂时无法判断'
  }
  build() {
    AISkinReportScreen({ header: () => { this.ReportHeader() }, content: () => { this.ReportContent() } })
  }
  @Builder
  ReportHeader() { AppHeader({ title: '冲突检测报告', layout: AISkinHeaderLayout.LeadingTitleSubtitle, subtitle: `${this.conflictData?.products?.length || 0} 件产品 · 分析完成`, showBackButton: true, onBack: this.onBack }) }
  @Builder
  ReportContent() {
      Scroll() {
        Column({ space: AISkinReportTokens.sectionGap }) {
          if (this.conflictData) {
            AISkinReportScore({ label: '搭配风险评分', score: this.conflictData.riskScore ?? -1,
              summary: this.conflictData.summary || '该次记录未提供总结', hint: '0–5 分，越高越需谨慎 · 基于成分标签的模型估计' })
            AISkinReportHeading({ number: '01', title: '本次检测产品', detail: `${this.conflictData.products?.length || 0} 件` })
            Column({ space: AISkinSpacing.small }) {
              ForEach(this.conflictData.products || [], (product: ConflictProductInfo, index: number) => {
                AISkinReportTextItem({ title: `${index + 1}  ${product.name || '未命名产品'}` })
              })
            }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
            AISkinReportHeading({ number: '02', title: '产品搭配结论', detail: `${this.conflictData.productPairs?.length || 0} 组` })
            ForEach(this.conflictData.productPairs || [], (pair: ConflictProductPair) => {
              Column({ space: AISkinSpacing.small }) {
                AISkinReportTextItem({ title: pair.productIds.map((id: string) => this.productName(id)).join(' ＋ ') })
                AISkinReportTextItem({ title: this.statusLabel(pair.status), text: pair.explanation })
              }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
            })
            ForEach(this.conflictData.conflicts || [], (item: ConflictItem) => {
              Column({ space: AISkinSpacing.small }) {
                AISkinReportTextItem({ title: (item.components || []).join(' ＋ '), text: `${item.severity || '未标注'}风险\n${item.description || ''}` })
                ForEach(item.effects || [], (effect: string) => { AISkinReportTextItem({ text: effect }) })
              }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
            })
            ForEach(this.conflictData.safeCombo || [], (item: SafeComboItem) => {
              Column() { AISkinReportTextItem({ title: (item.components || []).join(' ＋ '), text: item.description || '' }) }
                .width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
            })
            if (!this.conflictData.productPairs?.length && !this.conflictData.conflicts?.length && !this.conflictData.safeCombo?.length) {
              AISkinReportTextItem({ text: '这份记录没有提供搭配明细，不能据此判断产品是否适合混用。' })
            }
            AISkinReportHeading({ number: '03', title: '护肤建议' })
            Column({ space: AISkinSpacing.large }) {
              ForEach(this.conflictData.recommendations?.advice || [], (advice: ConflictAdvice) => {
                AISkinReportTextItem({ title: advice.title, text: advice.detail })
                if ((this.conflictData?.products?.length || 0) > 2 && advice.productIds.length > 0) { AISkinReportTextItem({ text: '适用：' + advice.productIds.map((id: string) => this.productName(id)).join('、') }) }
              })
              ForEach(this.conflictData.recommendations?.productPairings?.cannotUseTogether || [], (pair: PairingItem) => { this.legacyAdvice('不建议同用', pair) })
              ForEach(this.conflictData.recommendations?.productPairings?.canUseTogether || [], (pair: PairingItem) => { this.legacyAdvice('搭配建议', pair) })
              ForEach(this.conflictData.recommendations?.routines?.morning || [], (step: string) => { AISkinReportTextItem({ title: '早间', text: step }) })
              ForEach(this.conflictData.recommendations?.routines?.evening || [], (step: string) => { AISkinReportTextItem({ title: '晚间', text: step }) })
              if (!this.conflictData.recommendations?.advice?.length && !this.conflictData.recommendations?.routines && !this.conflictData.recommendations?.productPairings) { AISkinReportTextItem({ text: '这份记录未提供使用建议。' }) }
            }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
            AIContentNotice({ scene: '冲突检测' })
          } else {
            AISkinStateView({ title: '未找到报告', message: '请返回后重新打开。', kind: AISkinStateKind.Error })
          }
        }.width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, top: AISkinSpacing.medium, bottom: AISkinSpacing.xxLarge })
      }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
  }
  @Builder
  legacyAdvice(title: string, pair: PairingItem) { AISkinReportTextItem({ title: `${title} · ${(pair.products || []).join(' ＋ ')}`, text: pair.reason || '该次记录未提供说明' }) }
}
