import { TextStyle } from '../../design/AISkinTheme'
import { AISkinSpacing, AISkinTextRole } from '../../design/Foundation/AISkinTokens'
import { Modal, AISkinModalPresentation } from './Modal'
@Component
export struct DocumentModal {
  @Prop show: boolean = false
  @Prop title: string = ''
  @Prop content: string = ''
  onClose?: () => void
  @Builder
  documentBody() {
    Text(this.formatContent(this.content)).attributeModifier(new TextStyle(AISkinTextRole.ReportBody))
      .width('100%').textAlign(TextAlign.Start).padding(AISkinSpacing.cardPadding)
  }
  build() {
    Modal({ show: this.show, title: this.title, presentation: AISkinModalPresentation.Reading, onClose: this.onClose,
      content: () => { this.documentBody() } })
  }
  private formatContent(content: string): string {
    return (content || '内容加载中…').replace(/#{1,3}\s*\*\*(.+?)\*\*/g, '$1')
      .replace(/\*\*(.+?)\*\*/g, '$1').replace(/^#{1,3}\s+/gm, '')
      .replace(/^-\s+/gm, '• ').replace(/^---$/gm, '')
  }
}
