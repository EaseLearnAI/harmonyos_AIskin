import { AppHeader } from '../common/AppHeader'
@Component
export struct SkinAnalysisHeader {
  onShowHistory?: () => void
  onBack?: () => void
  build() {
    AppHeader({ title: '肌肤检测', showBackButton: true, onBack: this.onBack,
      rightIcon: 'history', rightLabel: '检测历史', onRight: this.onShowHistory })
  }
}
