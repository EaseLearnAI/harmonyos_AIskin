import { AISkinColor, toneColor } from './AISkinTheme'
import { AISkinLayout, AISkinTone } from './Foundation/AISkinTokens'
import { AISkinIconTokens as T } from './Foundation/AISkinIconTokens'
@Component
export struct AISkinIcon {
  @Prop name: string = 'home'
  @Prop selected: boolean = false
  @Prop tone: AISkinTone = AISkinTone.Secondary
  @Prop iconSize: number = AISkinLayout.iconSize
  private paint(): ResourceColor {
    // Preserve selected behavior for existing callers; explicit semantic tones win.
    return toneColor(this.selected && this.tone === AISkinTone.Secondary ? AISkinTone.Accent : this.tone)
  }
  build() {
    Stack() {
      Shape() {
        Path().commands(T.path(this.name))
          .fill(T.isFilled(this.name) ? this.paint() : Color.Transparent)
          .stroke(T.isFilled(this.name) ? Color.Transparent : this.paint()).strokeWidth(`${T.stroke}px`)
      }.viewPort({x:0,y:0,width:`${T.viewport}px`,height:`${T.viewport}px`}).width(this.iconSize).height(this.iconSize).strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
      if (T.detailPath(this.name)) {
        // Keep two-tone glyph placement independent of Shape's child layout:
        // each paint layer owns the same viewport and overlays at the same origin.
        Shape() {
          Path().commands(T.detailPath(this.name)).fill(Color.Transparent)
            .stroke(this.name === 'checkCircle' ? AISkinColor.white : AISkinColor.elevated).strokeWidth(`${T.detailStroke}px`)
        }.viewPort({x:0,y:0,width:`${T.viewport}px`,height:`${T.viewport}px`}).width(this.iconSize).height(this.iconSize).strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
      }
    }.width(this.iconSize).height(this.iconSize)
  }
}
