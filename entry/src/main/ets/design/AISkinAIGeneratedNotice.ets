import { TextStyle } from './AISkinTheme'
import { AISkinTextRole, AISkinTone } from './Foundation/AISkinTokens'
@Component
export struct AISkinAIGeneratedNotice {
  build() {
    Text('含 AI 生成的内容').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary)).width('100%')
  }
}
