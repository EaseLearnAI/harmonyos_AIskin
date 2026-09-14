import { AISkinColor } from '../../design/AISkinTheme'
@Component
export struct AIContentNotice {
  @Prop scene: string = '分析'
  build() {
    Row({ space: 10 }) {
      Text('AI生成').fontSize(12).fontWeight(FontWeight.Medium).fontColor(AISkinColor.accent)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 }).backgroundColor(AISkinColor.selected).borderRadius(12)
      Text('仅供日常护肤参考').fontSize(12).fontColor(AISkinColor.secondary).layoutWeight(1)
      Button('说明').height(44).fontSize(12).fontColor(AISkinColor.accent).backgroundColor(Color.Transparent)
        .onClick(() => {
          AlertDialog.show({ title: `${this.scene} · AI生成内容说明`,
            message: '本结果由人工智能依据你主动提交的信息辅助分析生成，可能存在误差，不构成医疗诊断或治疗建议。请结合产品说明和实际使用感受判断。\n\n如发现结果有误，请将问题描述与发生时间发送至 abc1567849@gmail.com，我们会人工复核。',
            primaryButton: { value: '知道了', action: () => {} } })
        })
    }.width('100%').height(44)
  }
}
