import { AISkinActionTile } from '../../design/AISkinJourneyComponents'
import { AISkinSpacing } from '../../design/Foundation/AISkinTokens'
import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { AISkinIcon } from '../../design/AISkinIcon'

@Component
export struct CoreFeatures {
  onNavigate?: (route: string, params?: ProductViewParams) => void
  onShowPersonalizedRoutineModal?: () => void
  build() {
    Column({ space: AISkinSpacing.small }) {
      Row({ space: AISkinSpacing.small }) {
        this.tile('护肤柜', '收纳产品 · 查看成分', 'cabinet', () => this.onNavigate?.('/product'))
        this.tile('冲突检测', '检查多件产品搭配', 'conflict', () => this.onNavigate?.('/product', { autoEnableConflictMode: true }))
      }.alignItems(VerticalAlign.Top)
      Row({ space: AISkinSpacing.small }) {
        this.tile('肌肤检测', '分析当前面部肤况', 'skin', () => this.onNavigate?.('/skinstatus'))
        this.tile('个性化方案', '用护肤柜里的产品\n安排早晚护肤', 'plan', () => this.onShowPersonalizedRoutineModal?.())
      }.alignItems(VerticalAlign.Top)
    }.width('100%')
  }
  @Builder
  tile(title: string, detail: string, icon: string, action: () => void) {
    AISkinActionTile({ title: title, subtitle: detail, icon: icon, onAction: action }).layoutWeight(1)
  }

}
interface ProductViewParams { autoEnableConflictMode?: boolean }
