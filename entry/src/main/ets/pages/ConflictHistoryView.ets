import { CardStyle } from '../design/AISkinTheme'
import { AISkinButton, AISkinStateView } from '../design/AISkinPrimitives'
import { AISkinReportHeading, AISkinReportTextItem } from '../design/AISkinReportComponents'
import { AISkinCardInset, AISkinCardRole, AISkinCardState, AISkinSpacing, AISkinStateKind } from '../design/Foundation/AISkinTokens'
import { AppHeader } from '../components/common/AppHeader'
import { ConflictApiService, ConflictAnalysisData } from '../components/product/ConflictApiService'
@Component
export struct ConflictHistoryView {
  @State records: ConflictAnalysisData[] = []
  @State loading: boolean = true
  @State error: string = ''
  onOpen: (report: ConflictAnalysisData) => void = () => {}
  onBack: () => void = () => {}
  onStart?: () => void
  aboutToAppear() { this.load() }
  async load() {
    this.loading = true
    const result = await ConflictApiService.getInstance().getHistory()
    this.records = result.data?.conflicts || []
    this.error = result.success ? '' : result.message || '暂时无法获取检测历史'
    this.loading = false
  }
  build() {
    Column({ space: AISkinSpacing.medium }) {
      AppHeader({ title: '冲突检测历史', showBackButton: true, onBack: this.onBack })
      Scroll() {
        Column({ space: AISkinSpacing.medium }) {
          if (this.loading) { AISkinStateView({ title: '正在加载检测记录', kind: AISkinStateKind.Loading }) }
          else if (this.error) { AISkinStateView({ title: '记录加载失败', message: this.error, kind: AISkinStateKind.Error, onRetry: (): void => { this.load() } }) }
          else if (this.records.length === 0) { AISkinStateView({ title: '还没有冲突检测报告', message: '选择至少 2 件护肤品完成检测，报告会保存在这里。', kind: AISkinStateKind.Empty }) }
          else { AISkinReportHeading({ title: '历史报告', detail: `共 ${this.records.length} 份` }) }
          ForEach(this.records, (record: ConflictAnalysisData) => {
            Column({ space: AISkinSpacing.medium }) {
              AISkinReportTextItem({ text: `${(record.createdAt || '').slice(0, 10) || '时间未记录'} · ${record.products?.length || 0} 件产品` })
              AISkinReportTextItem({ title: (record.products || []).map(p => p.name || '未命名产品').join(' ＋ '), text: record.summary || '查看搭配分析' })
            }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular)).onClick((): void => { this.onOpen(record) })
          })
        }.width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.large })
      }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
      if (this.onStart) { AISkinButton({ title: '开始新的检测', onAction: this.onStart }).margin({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.medium }) }
    }.width('100%').height('100%')
  }
}
