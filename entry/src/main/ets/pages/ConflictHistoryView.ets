import { AISkinColor, CardStyle } from '../design/AISkinTheme'
import { AppHeader } from '../components/common/AppHeader'
import { ConflictApiService, ConflictAnalysisData } from '../components/product/ConflictApiService'
@Component
export struct ConflictHistoryView {
  @State records: ConflictAnalysisData[] = []
  @State loading: boolean = true
  @State error: string = ''
  onOpen: (report: ConflictAnalysisData) => void = () => {}
  onBack: () => void = () => {}
  aboutToAppear() { this.load() }
  async load() {
    this.loading = true
    const result = await ConflictApiService.getInstance().getHistory()
    this.records = result.data?.conflicts || []
    this.error = result.success ? '' : result.message || '暂时无法获取检测历史'
    this.loading = false
  }
  build() {
    Column() {
      AppHeader({ title: '冲突检测历史', showBackButton: true, onBack: this.onBack })
      Scroll() {
        Column({ space: 12 }) {
          if (this.loading) { LoadingProgress().color(AISkinColor.accent).width(40).height(40) }
          if (this.error) {
            Text(this.error).fontColor(AISkinColor.secondary)
            Button('重试').onClick(() => this.load())
          } else if (!this.loading && this.records.length === 0) {
            Text('暂无冲突检测记录').fontSize(18).fontColor(AISkinColor.text).margin({ top: 60 })
            Text('在护肤柜中选择至少两件产品，检查搭配。').fontSize(14).fontColor(AISkinColor.secondary)
          }
          ForEach(this.records, (record: ConflictAnalysisData) => {
            Button() {
              Column({ space: 12 }) {
                Text((record.products || []).map(p => p.name || '未命名产品').join(' ＋ ')).fontSize(17).fontColor(AISkinColor.text)
                Text(record.summary || '查看搭配分析').fontSize(14).lineHeight(22).fontColor(AISkinColor.secondary)
                Text((record.createdAt || '').slice(0,10)).fontSize(12).fontColor(AISkinColor.secondary)
              }.width('100%').alignItems(HorizontalAlign.Start).padding(20)
            }.type(ButtonType.Normal).width('100%').attributeModifier(new CardStyle()).onClick(() => this.onOpen(record))
          })
        }.width('100%').padding({ left: 20, right: 20, bottom: 90 })
      }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }.width('100%').height('100%')
  }
}
