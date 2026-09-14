import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct SkinTypeAnalysis {
  @Prop skinType: SkinTypeData = {}
  @Prop oilLevel: string = '未记录'
  @Prop moistureLevel: string = '未记录'
  @Prop poreLevel: string = '未记录'
  build() {
    Column({ space: 16 }) {
      Text('肤质分析').fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
      Text(this.skinType.type || '未记录肤质').fontSize(24).fontColor(AISkinColor.accent)
      if (this.skinType.subtype) { Text(this.skinType.subtype).fontSize(14).fontColor(AISkinColor.secondary) }
      Text(this.skinType.basis || '该次记录暂无判断依据').fontSize(14).lineHeight(23).fontColor(AISkinColor.text)
      Divider().color(AISkinColor.divider)
      this.metric('油脂状态', this.oilLevel)
      this.metric('水分状态', this.moistureLevel)
      this.metric('毛孔状态', this.poreLevel)
    }.alignItems(HorizontalAlign.Start).width('100%').padding(20).attributeModifier(new CardStyle())
  }
  @Builder
  metric(label: string, value: string) {
    Row() { Text(label).fontSize(14).fontColor(AISkinColor.secondary).layoutWeight(1); Text(value).fontSize(14).fontColor(AISkinColor.text) }.width('100%')
  }
}
export interface SkinTypeData { type?: string; subtype?: string; basis?: string }
