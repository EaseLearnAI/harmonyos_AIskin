import { AISkinColor, CardStyle, TextStyle } from './AISkinTheme'
import { AISkinCardInset, AISkinCardRole, AISkinCardState, AISkinSpacing, AISkinTextRole, AISkinTone } from './Foundation/AISkinTokens'
import { AISkinReportTokens } from './Foundation/AISkinReportTokens'
export enum AISkinReportTextStyle { Standard, Reading }
export enum AISkinReportScoreLayout { ScoreFirst, SummaryFirst }
// One report shell owns the fixed header, optional anchors, scrolling viewport and footer.
// Callers retain their List/Scroll controller inside content for native section navigation.
@Component
export struct AISkinReportScreen {
  @BuilderParam header: () => void
  @BuilderParam content: () => void
  @BuilderParam anchor: () => void = this.emptySlot
  @BuilderParam footer: () => void = this.emptySlot
  @Builder emptySlot() { Column() {} }
  build() {
    Column() {
      this.header()
      this.anchor()
      Column() { this.content() }.width('100%').layoutWeight(1)
      this.footer()
    }.width('100%').height('100%')
  }
}
@Component
export struct AISkinReportFooter {
  @BuilderParam content: () => void
  build() {
    Column() { this.content() }.width('100%')
      .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, top: AISkinSpacing.xSmall, bottom: AISkinSpacing.xSmall })
      .backgroundColor(AISkinColor.elevated).backgroundBlurStyle(BlurStyle.Thin)
  }
}
@Component
export struct AISkinReportHeading {
  @Prop number: string = ''
  @Prop title: string = ''
  @Prop detail: string = ''
  build() {
    Row({ space: AISkinSpacing.xSmall }) {
      if (this.number) { Text(this.number).fontSize(AISkinReportTokens.captionSize).fontColor(AISkinColor.secondary) }
      Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.CardTitle)).layoutWeight(1)
      if (this.detail) { Text(this.detail).attributeModifier(new TextStyle(AISkinTextRole.CompactCaption, AISkinTone.Secondary)) }
    }.width('100%')
  }
}
@Component
export struct AISkinReportTextItem {
  @Prop title: string = ''
  @Prop text: string = ''
  @Prop style: AISkinReportTextStyle = AISkinReportTextStyle.Standard
  build() {
    Column({ space: AISkinSpacing.xxSmall }) {
      if (this.title) { Text(this.title).fontSize(this.style === AISkinReportTextStyle.Reading ? AISkinReportTokens.readingTitleSize : AISkinReportTokens.titleSize).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).width('100%') }
      if (this.text) { Text(this.text).fontSize(this.style === AISkinReportTextStyle.Reading ? AISkinReportTokens.readingBodySize : AISkinReportTokens.bodySize).fontColor(AISkinColor.secondary)
        .lineHeight(this.style === AISkinReportTextStyle.Reading ? AISkinReportTokens.readingBodySize + AISkinReportTokens.readingLineSpacing : AISkinReportTokens.bodySize + AISkinReportTokens.bodyLineSpacing).width('100%') }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
@Component
export struct AISkinReportScore {
  @Prop label: string = ''
  @Prop score: number = -1
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop hint: string = ''
  @Prop layout: AISkinReportScoreLayout = AISkinReportScoreLayout.ScoreFirst
  build() {
    Column({ space: AISkinSpacing.small }) {
      if (this.layout === AISkinReportScoreLayout.SummaryFirst) {
        Text(this.title || '产品总结').attributeModifier(new TextStyle(AISkinTextRole.CardTitle)).width('100%')
        Text(this.summary).fontSize(AISkinReportTokens.readingSummarySize).fontColor(AISkinColor.secondary).lineHeight(AISkinReportTokens.readingSummarySize + AISkinReportTokens.readingLineSpacing).width('100%')
        Divider().color(AISkinColor.divider)
        Row({ space: AISkinSpacing.medium }) {
          Text(this.label).attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary)).layoutWeight(1)
          Text(this.score < 0 ? '—' : this.score.toFixed(1)).fontSize(AISkinReportTokens.compactScoreSize).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
          Text('/ 5.0').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
        }.width('100%')
      } else {
        Text(this.label).attributeModifier(new TextStyle(AISkinTextRole.Caption)).width('100%')
        Row({ space: AISkinSpacing.xSmall }) {
          Text(this.score < 0 ? '—' : this.score.toFixed(1)).fontSize(AISkinReportTokens.scoreSize).fontWeight(FontWeight.Medium).letterSpacing(AISkinReportTokens.scoreTracking).fontColor(AISkinColor.text)
          Text('/ 5.0').attributeModifier(new TextStyle(AISkinTextRole.FeatureSubtitle, AISkinTone.Secondary))
          Blank()
          if (this.score >= 0) {
            Row({ space: AISkinSpacing.xxSmall }) {
              ForEach([0, 1, 2, 3, 4], (index: number) => { Circle().width(AISkinReportTokens.dotDiameter).height(AISkinReportTokens.dotDiameter).fill(index < Math.floor(this.score) ? AISkinColor.accent : AISkinColor.divider) })
            }.accessibilityLevel('no')
          }
        }.width('100%').padding({ top: AISkinSpacing.xxSmall, bottom: AISkinSpacing.xxSmall })
        if (this.hint) { Text(this.hint).fontSize(AISkinReportTokens.captionSize).fontColor(AISkinColor.secondary).width('100%') }
        if (this.title || this.summary) { AISkinReportTextItem({ title: this.title, text: this.summary }) }
      }
    }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
  }
}
