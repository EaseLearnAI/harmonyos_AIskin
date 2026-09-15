import { AISkinAIGeneratedNotice } from '../../design/AISkinAIGeneratedNotice'
@Component
export struct AIContentNotice {
  @Prop scene: string = '分析'
  build() {
    AISkinAIGeneratedNotice({ onExplanation: () => {
      AlertDialog.show({ title: `${this.scene} · AI生成内容说明`,
        message: '本结果由人工智能依据你主动提交的信息辅助分析生成，可能存在误差，不构成医疗诊断或治疗建议。请结合产品说明和实际使用感受判断。\n\n如发现结果有误，请将问题描述与发生时间发送至 abc1567849@gmail.com，我们会人工复核。',
        primaryButton: { value: '知道了', action: () => {} } })
    } })
  }
}
