import { TextStyle } from '../../design/AISkinTheme'
import { AISkinButton } from '../../design/AISkinPrimitives'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinButtonVariant } from '../../design/Foundation/AISkinTokens'
import { Modal } from './Modal'
@Component
export struct DeleteConfirmModal {
  @Prop show: boolean = false
  @Prop productName: string = '产品'
  @Prop title: string = '确认删除'
  @Prop message: string = ''
  @Prop confirmTitle: string = '确认删除'
  @Prop isLoading: boolean = false
  onCancel?: () => void
  onConfirm?: () => void
  @Builder
  messageBody() {
    Text(this.message || `确定要删除“${this.productName}”的分析结果吗？此操作无法撤销。`)
      .attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary))
      .width('100%').padding(AISkinSpacing.cardPadding)
  }
  @Builder
  actions() {
    Row({ space: AISkinSpacing.xSmall }) {
      AISkinButton({ title: '取消', variant: AISkinButtonVariant.Surface, isEnabled: !this.isLoading, onAction: this.onCancel }).layoutWeight(1)
      AISkinButton({ title: this.confirmTitle, variant: AISkinButtonVariant.Destructive, isLoading: this.isLoading, onAction: this.onConfirm }).layoutWeight(1)
    }.width('100%').padding({ left: AISkinSpacing.cardPadding, right: AISkinSpacing.cardPadding })
  }
  build() {
    Modal({ show: this.show, title: this.title, isBusy: this.isLoading, showCloseButton: false, onClose: this.onCancel,
      content: () => { this.messageBody() }, footer: () => { this.actions() } })
  }
}
