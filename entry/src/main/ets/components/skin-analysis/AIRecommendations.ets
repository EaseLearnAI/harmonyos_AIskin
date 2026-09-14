import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct AIRecommendations {
  @Prop recommendations: string[] = []
  build() {
    Column({ space: 16 }) {
      Text('护理建议').fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
      if (!this.recommendations.length) { Text('该次记录暂无护理建议').fontSize(14).fontColor(AISkinColor.secondary) }
      ForEach(this.recommendations, (tip: string, index: number) => {
        Row({ space: 12 }) {
          Text(String(index+1).padStart(2,'0')).fontSize(12).fontColor(AISkinColor.accent).width(24)
          Text(tip).fontSize(14).lineHeight(24).fontColor(AISkinColor.text).layoutWeight(1)
        }.width('100%').alignItems(VerticalAlign.Top)
      })
    }.width('100%').padding(20).alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle())
  }
}
