import { AISkinColor } from '../../design/AISkinTheme'
@Component
export struct TwentyOneDayPlanCard {
  build() {
    Column() {
      Text('21天护肤计划')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(AISkinColor.accent)
        .margin({ bottom: 8 })

      Text('点击开启你的21天护肤挑战！')
        .fontSize(14)
        .fontColor(AISkinColor.accent)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffe4ec')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(255, 174, 201, 0.15)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      // Handle navigation to 21-day plan
    })
  }
}

