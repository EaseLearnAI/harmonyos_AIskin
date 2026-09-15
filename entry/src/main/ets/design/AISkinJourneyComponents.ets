import { AISkinColor, CardStyle, TextStyle } from './AISkinTheme'
import { AISkinIcon } from './AISkinIcon'
import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinCardRole, AISkinCardState, AISkinCardInset, AISkinMotion, AISkinTypography } from './Foundation/AISkinTokens'
@Component
export struct AISkinActionTile {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop icon: string = 'plan'
  @State pressed: boolean = false
  onAction?: () => void
  build() {
    Button() {
      Column({ space: AISkinSpacing.small }) {
        Row() {
          Stack() {
            Circle().width(AISkinLayout.actionIconDiameter).height(AISkinLayout.actionIconDiameter).fill(AISkinColor.elevated)
            AISkinIcon({ name: this.icon, selected: true, iconSize: AISkinSpacing.xLarge })
          }
          Blank()
          Text('›').attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary))
        }.width('100%')
        Column({ space: AISkinSpacing.xxSmall }) {
          Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.FeatureTitle))
          Text(this.subtitle).attributeModifier(new TextStyle(AISkinTextRole.FeatureSubtitle, AISkinTone.Secondary))
            .minFontSize(AISkinTypography.size(AISkinTextRole.Caption)).maxFontSize(AISkinTypography.size(AISkinTextRole.FeatureSubtitle)).maxLines(this.subtitle.includes('\n') ? 2 : 1).heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
        }.alignItems(HorizontalAlign.Start)
      }.width('100%').constraintSize({ minHeight: AISkinLayout.actionTileHeight }).alignItems(HorizontalAlign.Start)
        .attributeModifier(new CardStyle(AISkinCardRole.Feature, AISkinCardState.Normal, AISkinCardInset.Regular))
    }.padding(0).type(ButtonType.Normal).width('100%').backgroundColor(Color.Transparent).opacity(this.pressed ? AISkinMotion.pressedOpacity : 1)
      .onTouch((event: TouchEvent) => { this.pressed = event.type === TouchType.Down }).onClick(() => this.onAction?.())
  }
}
@Component
export struct AISkinChecklistRow {
  @Prop title: string = ''
  @Prop message: string = ''
  @Prop number: number = 1
  @Prop isCompleted: boolean = false
  @Prop isEnabled: boolean = true
  onAction?: () => void
  build() {
    Button() {
      Row({ space: AISkinSpacing.small }) {
        AISkinIcon({ name: this.isCompleted ? 'checkCircle' : 'circle', selected: this.isCompleted, iconSize: AISkinLayout.routineCheckDiameter })
        Column({ space: AISkinSpacing.xxSmall }) {
          Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.RoutineTitle, this.isCompleted ? AISkinTone.Secondary : AISkinTone.Primary)).decoration({ type: this.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None, color: AISkinColor.secondary }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.message) { Text(this.message).attributeModifier(new TextStyle(AISkinTextRole.FeatureSubtitle, AISkinTone.Secondary)).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }) }
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text(String(this.number).padStart(2,'0')).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary))
      }.width('100%').constraintSize({ minHeight: AISkinLayout.routineRowHeight }).padding({ top: AISkinSpacing.routineRowPadding, bottom: AISkinSpacing.routineRowPadding })
    }.padding(0).type(ButtonType.Normal).width('100%').backgroundColor(Color.Transparent).enabled(this.isEnabled)
      .accessibilityText(`${this.title}，${this.isCompleted ? '已完成' : '未完成'}`).onClick(() => this.onAction?.())
  }
}
