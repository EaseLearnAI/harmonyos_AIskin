import { AISkinColor, CardStyle, TextStyle } from './AISkinTheme'
import { AISkinTag, AISkinStateView } from './AISkinPrimitives'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinCardState, AISkinCardRole, AISkinCardInset, AISkinTagState, AISkinRadius } from './Foundation/AISkinTokens'
import { AISkinSkinTokens as T } from './Foundation/AISkinSkinTokens'
import { SkinAnalysisData } from '../services/SkinAnalysisApiService'
import { SkinObservation, skinObservations } from './SkinReportPresentation'
@Component
export struct AISkinSkinSummaryCard {
  @Prop data: SkinAnalysisData = {}
  private level(status: string): number { return status === '轻微' ? 1 : ['轻度','少量'].includes(status) ? 2 : ['中度','较明显'].includes(status) ? 3 : status === '明显' ? 4 : ['重度','严重'].includes(status) ? 5 : 0 }
  build() {
    Column({ space: AISkinSpacing.small }) {
      Row() {
        Text(this.data.skinType?.type || '未记录肤质').attributeModifier(new TextStyle(AISkinTextRole.CompactButton)).layoutWeight(1)
        AISkinTag({ title: this.data.context?.condition || '未记录状态' })
      }.width('100%')
      Row({ space: AISkinSpacing.sectionGap }) {
        Stack() {
          Progress({ value: Math.max(0, this.data.overallAssessment?.healthScore || 0), total: 100, type: ProgressType.Ring }).width(T.ringDiameter).height(T.ringDiameter).color(AISkinColor.accent).backgroundColor(AISkinColor.selected).style({ strokeWidth: T.ringStroke })
          Column({ space: AISkinSpacing.xSmall }) {
            Text(this.data.overallAssessment?.healthScore === undefined ? '—' : String(this.data.overallAssessment.healthScore)).fontSize(T.score).fontColor(AISkinColor.text)
            Text('综合评分').fontSize(T.footnote).fontColor(AISkinColor.secondary)
          }
        }
        Column({ space: AISkinSpacing.small }) {
          ForEach(skinObservations(this.data).slice(0,3), (row: SkinObservation) => {
            Column({ space: AISkinSpacing.xxSmall }) {
              Row() { Text(row.title).fontSize(T.label).fontColor(AISkinColor.text).layoutWeight(1); Text(row.status).fontSize(T.small).fontColor(AISkinColor.accent) }.width('100%')
              Row({ space: T.metricGap }) { ForEach([1,2,3,4,5], (level: number) => { Rect().layoutWeight(1).height(T.metricHeight).radius(AISkinRadius.capsule).fill(level <= this.level(row.status) ? AISkinColor.accent : AISkinColor.selected) }) }.width('100%')
            }
          })
          if (skinObservations(this.data).length === 0) { Text('该次记录未保存问题明细').fontSize(T.small).fontColor(AISkinColor.secondary) }
        }.layoutWeight(1)
      }.width('100%')
      Divider().color(AISkinColor.divider)
      Text('本次结论').fontSize(T.small).fontColor(AISkinColor.accent).width('100%')
      Text(this.data.overallAssessment?.summary || '该次记录暂无结论').fontSize(T.body).fontColor(AISkinColor.secondary).width('100%')
    }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content,AISkinCardState.Normal,AISkinCardInset.Regular))
  }
}
@Component
export struct AISkinSkinPhotoMap {
  @Prop observations: SkinObservation[] = []
  @Prop imageUrl: string = ''
  @State selected: number = 0
  private detailsScroller: Scroller = new Scroller()
  private select(index: number): void { this.selected = index; this.detailsScroller.scrollToIndex(index, true) }
  build() {
    Column({ space: AISkinSpacing.small }) {
      Stack() {
        if (this.imageUrl) { Image(this.imageUrl).width(T.photoDiameter).height(T.photoDiameter).objectFit(ImageFit.Cover).borderRadius(AISkinRadius.capsule).accessibilityText('本次检测照片') }
        else { Text('未保存检测照片').attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Secondary)) }
        Row() {
          Column({ space: AISkinSpacing.xSmall }) {
            ForEach(this.observations.slice(0,3), (row: SkinObservation, index: number) => { this.pin(row,index) })
          }
          Blank()
          Column({ space: AISkinSpacing.xSmall }) {
            ForEach(this.observations.slice(3,6), (row: SkinObservation, index: number) => { this.pin(row,index+3) })
          }
        }.width('100%')
      }.width('100%').height(T.photoMapHeight)
      List({ scroller: this.detailsScroller, space: AISkinSpacing.xSmall }) {
        ForEach(this.observations, (row: SkinObservation, index: number) => {
          ListItem() {
            Column({ space: AISkinSpacing.xSmall }) {
              Text(`${row.title} · ${row.status}`).attributeModifier(new TextStyle(AISkinTextRole.CompactButton,row.isConcern ? AISkinTone.Destructive : AISkinTone.Primary))
              Text(row.details).attributeModifier(new TextStyle(AISkinTextRole.FeatureSubtitle,AISkinTone.Secondary)).width('100%')
            }.width('100%').alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle(AISkinCardRole.Content, this.selected === index ? AISkinCardState.Selected : AISkinCardState.Normal, AISkinCardInset.Regular))
              .onClick(() => { this.selected = index })
          }
        })
      }.width('100%').height(T.observationsMaximumHeight).scrollBar(BarState.Off)
      if (!this.observations.length) { AISkinStateView({ title: '该次记录未保存问题明细' }) }
    }.width('100%')
  }
  @Builder
  pin(row: SkinObservation,index: number) {
    AISkinTag({ title: `${row.title} · ${row.status}`, tone: row.isConcern ? AISkinTone.Destructive : AISkinTone.Secondary,
      state: this.selected === index ? AISkinTagState.Selected : AISkinTagState.Normal, onAction: () => this.select(index) }).width(T.pinWidth)
  }
}
