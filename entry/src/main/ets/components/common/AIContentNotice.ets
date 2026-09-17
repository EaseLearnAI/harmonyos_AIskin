import { AISkinAIGeneratedNotice } from '../../design/AISkinAIGeneratedNotice'
@Component
export struct AIContentNotice {
  @Prop scene: string = '分析'
  build() {
    AISkinAIGeneratedNotice()
  }
}
