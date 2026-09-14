import { AISkinColor, CardStyle, PrimaryButtonStyle } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'
@Component
export struct SkinDetectionWelcome {
  onSelectPhoto?: () => void
  onTakePhoto?: () => void
  build() {
    Column({ space: 16 }) {
      Stack() {
        Circle().width(160).height(160).fill(AISkinColor.surface).stroke(AISkinColor.border).strokeWidth(1)
        Circle().width(128).height(128).fill(Color.Transparent).stroke(AISkinColor.selected).strokeWidth(6)
        AISkinIcon({ name: 'skin', iconSize: 64, selected: true })
      }.margin({ top: 14, bottom: 10 })
      Text('了解此刻的肌肤').fontSize(24).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
      Text('拍一张清晰的正面照片\n看看肤质、泛红、毛孔与痘痘情况').fontSize(14).lineHeight(22)
        .fontColor(AISkinColor.secondary).textAlign(TextAlign.Center)
      Button('拍摄面部照片').width('100%').attributeModifier(new PrimaryButtonStyle()).onClick(() => this.onTakePhoto?.())
      Button('从相册选择').width('100%').height(48).fontColor(AISkinColor.accent)
        .backgroundColor(AISkinColor.surface).borderRadius(16).onClick(() => this.onSelectPhoto?.())
      Text('自然光 · 正面无遮挡 · 无美颜\nAI分析仅供日常护肤参考，不构成医疗诊断。')
        .fontSize(12).lineHeight(19).fontColor(AISkinColor.secondary).textAlign(TextAlign.Center)
    }.width('100%').padding(24).attributeModifier(new CardStyle())
  }
}
