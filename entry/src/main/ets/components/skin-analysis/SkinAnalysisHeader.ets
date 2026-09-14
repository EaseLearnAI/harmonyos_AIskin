import { AISkinColor } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'
@Component
export struct SkinAnalysisHeader {
  onShowHistory?: () => void
  onBack?: () => void
  build() {
    Row() {
      Button() { AISkinIcon({ name: 'back' }) }.width(44).height(44).backgroundColor(Color.Transparent).onClick(() => { this.onBack?.() }).accessibilityText('返回')
      Text('肌肤检测').fontSize(20).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).layoutWeight(1).textAlign(TextAlign.Center)
      Button() { AISkinIcon({ name: 'history' }) }.width(44).height(44).backgroundColor(Color.Transparent).onClick(() => { this.onShowHistory?.() }).accessibilityText('检测历史')
    }.width('100%').height(60).padding({ left: 16, right: 16 })
  }
}
