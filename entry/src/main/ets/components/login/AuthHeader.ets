import { AISkinColor } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'
@Component
export struct AuthHeader {
  @Prop title: string = '欢迎回来'
  @Prop subtitle: string = '开始你的护肤之旅'
  @Prop bgColor: ResourceColor = ''
  @Prop showBackButton: boolean = true
  onBack?: () => void
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 10 }) {
        Text('析肤AI').fontSize(30).fontWeight(FontWeight.Bold).fontColor(AISkinColor.text)
        Text(this.title).fontSize(20).fontColor(AISkinColor.accent)
        Text(this.subtitle).fontSize(13).fontColor(AISkinColor.secondary)
      }.width('100%').padding({ top: 30, bottom: 24, left: 20, right: 20 })
      if (this.showBackButton) {
        Button() { AISkinIcon({ name: 'back' }) }.width(44).height(44)
          .backgroundColor(AISkinColor.surface).margin({ left: 20, top: 24 }).onClick(() => this.onBack?.())
      }
    }.width('100%')
  }
}
