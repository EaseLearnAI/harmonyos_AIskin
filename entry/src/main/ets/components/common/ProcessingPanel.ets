import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
// Same presentation estimate as iOS AISkinProcessingEstimate. Never completes a request.
@Component
export struct ProcessingPanel {
  @Prop title: string = '正在分析'
  @Prop message: string = '稍等一下，细节也想照顾到'
  @State percentage: number = 0
  private timer: number = -1
  aboutToAppear() {
    const started = Date.now()
    this.timer = setInterval(() => {
      const seconds = (Date.now() - started) / 1000
      this.percentage = Math.min(98, Math.max(0, Math.round(98 - 78 * Math.exp(-seconds / 2.2) - 20 * Math.exp(-seconds / 16))))
    }, 200)
  }
  aboutToDisappear() { if (this.timer !== -1) clearInterval(this.timer) }
  build() {
    Column({ space: 24 }) {
      Stack() {
        Progress({ value: this.percentage, total: 100, type: ProgressType.Ring }).width(83).height(83).color(AISkinColor.accent).backgroundColor(AISkinColor.selected).style({ strokeWidth: 3 })
        Column({ space: 4 }) {
          Text(`${this.percentage}%`).fontSize(22).fontWeight(FontWeight.Medium).fontColor(AISkinColor.accent)
          Text('预估').fontSize(12).fontColor(AISkinColor.secondary)
        }
      }.accessibilityText(`预估进度 ${this.percentage}%`)
      Column({ space: 8 }) {
        Text(this.title).fontSize(20).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).textAlign(TextAlign.Center)
        Text(this.message).fontSize(12).lineHeight(20).fontColor(AISkinColor.secondary).textAlign(TextAlign.Center)
      }
    }.width('90%').constraintSize({ maxWidth: 330 }).padding(32).attributeModifier(new CardStyle()).backgroundColor(AISkinColor.dialog)
  }
}
