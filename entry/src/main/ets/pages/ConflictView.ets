import { AISkinColor, CardStyle } from '../design/AISkinTheme'
import { AppHeader } from '../components/common/AppHeader'
import { AIContentNotice } from '../components/common/AIContentNotice'
import { ConflictAnalysisData, ConflictProductPair, ConflictAdvice, ConflictItem, SafeComboItem, PairingItem } from '../components/product/ConflictApiService'

@Component
export struct ConflictView {
  @Prop conflictData: ConflictAnalysisData | null = null
  @State tab: number = 0
  onBack?: () => void
  private productName(id: string): string {
    return this.conflictData?.products?.find(item => (item.id || item._id) === id)?.name || '已移除产品'
  }
  private pairTitle(pair: ConflictProductPair): string {
    return pair.productIds.map((id: string) => this.productName(id)).join(' ＋ ')
  }
  private statusLabel(status: string): string {
    if (status === 'compatible') return '未发现明确冲突'
    if (status === 'caution') return '叠加需注意'
    if (status === 'avoid') return '不建议同时使用'
    return '暂时无法判断'
  }
  build() {
    Column() {
      AppHeader({ title: '冲突检测报告', showBackButton: true, onBack: this.onBack })
      Row({ space: 8 }) {
        this.tabButton('搭配分析', 0)
        this.tabButton('使用建议', 1)
      }.padding({ left: 20, right: 20, bottom: 12 }).width('100%')
      Scroll() {
        Column({ space: 16 }) {
          AIContentNotice({ scene: '冲突检测' })
          if (this.conflictData) {
            Column({ space: 12 }) {
              Text(this.conflictData.summary || '产品搭配分析').fontSize(20).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
              if (this.conflictData.riskScore !== undefined) {
                Text(`冲突风险 ${this.conflictData.riskScore} / 5`).fontSize(14).fontColor(AISkinColor.accent)
              }
              Text((this.conflictData.products || []).map(p => p.name || '未命名产品').join(' · '))
                .fontSize(13).fontColor(AISkinColor.secondary).lineHeight(21)
            }.width('100%').alignItems(HorizontalAlign.Start).padding(20).attributeModifier(new CardStyle())
            if (this.tab === 0) {
              ForEach(this.conflictData.productPairs || [], (pair: ConflictProductPair) => {
                Column({ space: 12 }) {
                  Text(this.pairTitle(pair)).fontSize(17).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
                  Text(this.statusLabel(pair.status)).fontSize(13).fontColor(pair.status === 'avoid' ? AISkinColor.danger : AISkinColor.accent)
                  Text(pair.explanation).fontSize(14).lineHeight(23).fontColor(AISkinColor.secondary)
                }.width('100%').alignItems(HorizontalAlign.Start).padding(20).attributeModifier(new CardStyle())
              })
              // Older saved reports retain their complete original content.
              ForEach(this.conflictData.conflicts || [], (item: ConflictItem) => {
                Column({ space: 10 }) {
                  Text((item.components || []).join(' ＋ ')).fontSize(17).fontColor(AISkinColor.text)
                  Text(`${item.severity || '未标注'}风险`).fontSize(13).fontColor(AISkinColor.danger)
                  Text(item.description || '').fontSize(14).lineHeight(23).fontColor(AISkinColor.secondary)
                  ForEach(item.effects || [], (effect: string) => {
                    Text('· ' + effect).fontSize(14).lineHeight(23).fontColor(AISkinColor.secondary).width('100%')
                  })
                }.width('100%').alignItems(HorizontalAlign.Start).padding(20).attributeModifier(new CardStyle())
              })
              ForEach(this.conflictData.safeCombo || [], (item: SafeComboItem) => {
                Column({ space: 10 }) {
                  Text((item.components || []).join(' ＋ ')).fontSize(17).fontColor(AISkinColor.text)
                  Text(item.description || '').fontSize(14).lineHeight(23).fontColor(AISkinColor.secondary)
                }.width('100%').alignItems(HorizontalAlign.Start).padding(20).attributeModifier(new CardStyle())
              })
              if (!(this.conflictData.productPairs?.length) && !(this.conflictData.conflicts?.length) && !(this.conflictData.safeCombo?.length)) {
                Text('这份记录没有提供搭配明细，不能据此判断产品是否适合混用。').fontColor(AISkinColor.secondary).lineHeight(23)
              }
            } else {
              ForEach(this.conflictData.recommendations?.advice || [], (advice: ConflictAdvice) => {
                Column({ space: 12 }) {
                  Text(advice.title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
                  Text(advice.detail).fontSize(14).lineHeight(23).fontColor(AISkinColor.secondary)
                }.width('100%').alignItems(HorizontalAlign.Start).padding(20).attributeModifier(new CardStyle())
              })
              ForEach(this.conflictData.recommendations?.productPairings?.cannotUseTogether || [], (pair: PairingItem) => {
                this.legacyAdvice('不建议同用', pair)
              })
              ForEach(this.conflictData.recommendations?.productPairings?.canUseTogether || [], (pair: PairingItem) => {
                this.legacyAdvice('搭配建议', pair)
              })
              ForEach(this.conflictData.recommendations?.routines?.morning || [], (step: string) => {
                Text('早间 · ' + step).fontSize(14).lineHeight(23).fontColor(AISkinColor.text).width('100%').padding(20).attributeModifier(new CardStyle())
              })
              ForEach(this.conflictData.recommendations?.routines?.evening || [], (step: string) => {
                Text('晚间 · ' + step).fontSize(14).lineHeight(23).fontColor(AISkinColor.text).width('100%').padding(20).attributeModifier(new CardStyle())
              })
              if (!this.conflictData.recommendations?.advice?.length && !this.conflictData.recommendations?.routines && !this.conflictData.recommendations?.productPairings) {
                Text('这份记录未提供使用建议。').fontColor(AISkinColor.secondary).padding(20)
              }
            }
          } else {
            Text('未找到报告，请返回后重新打开。').fontColor(AISkinColor.secondary)
          }
        }.width('100%').constraintSize({ maxWidth: 600 }).padding({ left: 20, right: 20, bottom: 32 })
      }.width('100%').layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }.width('100%').height('100%')
  }
  @Builder
  legacyAdvice(title: string, pair: PairingItem) {
    Column({ space: 12 }) {
      Text(title).fontSize(17).fontColor(AISkinColor.text)
      Text((pair.products || []).join(' ＋ ')).fontSize(14).fontColor(AISkinColor.accent)
      Text(pair.reason || '该次记录未提供说明').fontSize(14).lineHeight(23).fontColor(AISkinColor.secondary)
    }.width('100%').padding(20).alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle())
  }
  @Builder
  tabButton(title: string, index: number) {
    Button(title).layoutWeight(1).height(44).borderRadius(16)
      .backgroundColor(this.tab === index ? AISkinColor.primary : AISkinColor.surface)
      .fontColor(this.tab === index ? AISkinColor.white : AISkinColor.secondary).onClick(() => { this.tab = index })
  }
}
