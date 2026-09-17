import { AISkinSkinEmptyGuide } from '../../design/AISkinSkinEmptyGuide'
@Component
export struct SkinDetectionWelcome {
  onSelectPhoto?: () => void
  onTakePhoto?: () => void
  build() { AISkinSkinEmptyGuide({ onCapture: this.onTakePhoto, onLibrary: this.onSelectPhoto }) }
}
