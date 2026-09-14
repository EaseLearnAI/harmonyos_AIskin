import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct HealthScoreCard {
  @Prop score: number = -1
  build() {
    Row({ space: 20 }) {
      Stack() {
        Progress({ value: Math.max(0, this.score), total: 100, type: ProgressType.Ring }).width(100).height(100).color(AISkinColor.accent).backgroundColor(AISkinColor.selected)
        Column({ space: 2 }) {
          Text(this.score < 0 ? '—' : `${this.score}`).fontSize(32).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
          Text('肤况评分').fontSize(11).fontColor(AISkinColor.secondary)
        }
      }
      Column({ space: 10 }) {
        Text('本次肌肤状态').fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
        Text('评分用于比较不同时间的护肤记录，不代表医学检查结果。').fontSize(13).lineHeight(21).fontColor(AISkinColor.secondary)
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%').padding(20).attributeModifier(new CardStyle())
  }
}
