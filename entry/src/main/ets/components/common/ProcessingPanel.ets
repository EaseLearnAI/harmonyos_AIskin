import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinCardRole, AISkinMotion } from '../../design/Foundation/AISkinTokens'
import { AISkinColor, CardStyle, TextStyle } from '../../design/AISkinTheme'
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
    }, AISkinMotion.processingInterval)
  }
  aboutToDisappear() { if (this.timer !== -1) clearInterval(this.timer) }
  build() {
    Column({ space: AISkinSpacing.xLarge }) {
      Stack() {
        Progress({ value: this.percentage, total: 100, type: ProgressType.Ring }).width(AISkinLayout.processingRing).height(AISkinLayout.processingRing).color(AISkinColor.accent).backgroundColor(AISkinColor.selected).style({ strokeWidth: AISkinLayout.progressStroke })
        Column({ space: AISkinSpacing.xxSmall }) {
          Text(`${this.percentage}%`).attributeModifier(new TextStyle(AISkinTextRole.ProcessingPercentage,AISkinTone.Accent))
          Text('预估').attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Secondary))
        }
      }.accessibilityText(`预估进度 ${this.percentage}%`)
      Column({ space: AISkinSpacing.xSmall }) {
        Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.ProcessingTitle)).textAlign(TextAlign.Center)
        Text(this.message).attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Secondary)).textAlign(TextAlign.Center)
      }
    }.width('90%').constraintSize({ maxWidth: AISkinLayout.processingPanelWidth }).padding(AISkinSpacing.xxLarge).attributeModifier(new CardStyle(AISkinCardRole.Overlay))
  }
}
