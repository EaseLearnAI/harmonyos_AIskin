import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'

@Component
export struct CoreFeatures {
  onNavigate?: (route: string, params?: ProductViewParams) => void
  onShowPersonalizedRoutineModal?: () => void
  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        this.tile('护肤柜', '收纳产品 · 查看成分', 'cabinet', () => this.onNavigate?.('/product'))
        this.tile('冲突检测', '检查多件产品搭配', 'conflict', () => this.onNavigate?.('/product', { autoEnableConflictMode: true }))
      }
      Row({ space: 12 }) {
        this.tile('肌肤检测', '分析当前面部肤况', 'skin', () => this.onNavigate?.('/skinstatus'))
        this.tile('个性化方案', '用护肤柜里的产品\n安排早晚护肤', 'plan', () => this.onShowPersonalizedRoutineModal?.())
      }
    }.width('100%')
  }
  @Builder
  tile(title: string, detail: string, icon: string, action: () => void) {
    Button() {
      Column({ space: 10 }) {
        Row() {
          Stack() {
            Circle().width(40).height(40).fill(AISkinColor.elevated)
            AISkinIcon({ name: icon, selected: true, iconSize: 22 })
          }
          Blank()
          Text('›').fontColor(AISkinColor.secondary).fontSize(20)
        }.width('100%')
        Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
        Text(detail).fontSize(12).lineHeight(18).fontColor(AISkinColor.secondary).textAlign(TextAlign.Start)
      }.width('100%').height(144).padding(20).alignItems(HorizontalAlign.Start)
    }.type(ButtonType.Normal).layoutWeight(1).attributeModifier(new CardStyle()).borderRadius(24).onClick(action)
  }
}
interface ProductViewParams { autoEnableConflictMode?: boolean }
