import { AISkinLayout, AISkinRadius, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinTypography, AISkinCardRole, AISkinCardState, AISkinCardInset, AISkinMotion } from './Foundation/AISkinTokens'
// Values verified against ios_aiskin @ 9f69aa9 / AISkinColor.swift.
export class AISkinColor {
  static readonly floatingShadow: ResourceColor = $r('app.color.aiskin_floating_shadow')
  static readonly featureSurface: ResourceColor = $r('app.color.aiskin_featureSurface')
  static readonly routineSurface: ResourceColor = $r('app.color.aiskin_routineSurface')
  static readonly dialog: ResourceColor = $r('app.color.aiskin_dialog')
  static readonly accent: ResourceColor = $r('app.color.aiskin_accent')
  static readonly primary: ResourceColor = $r('app.color.aiskin_primary')
  static readonly text: ResourceColor = $r('app.color.aiskin_text')
  static readonly secondary: ResourceColor = $r('app.color.aiskin_secondary')
  static readonly white: ResourceColor = $r('app.color.aiskin_white')
  static readonly surface: ResourceColor = $r('app.color.aiskin_surface')
  static readonly elevated: ResourceColor = $r('app.color.aiskin_elevated')
  static readonly muted: ResourceColor = $r('app.color.aiskin_muted')
  static readonly selected: ResourceColor = $r('app.color.aiskin_selected')
  static readonly border: ResourceColor = $r('app.color.aiskin_border')
  static readonly divider: ResourceColor = $r('app.color.aiskin_divider')
  static readonly scrim: ResourceColor = $r('app.color.aiskin_scrim')
  static readonly shadow: ResourceColor = $r('app.color.aiskin_shadow')
  static readonly top: ResourceColor = $r('app.color.aiskin_top')
  static readonly middle: ResourceColor = $r('app.color.aiskin_middle')
  static readonly bottom: ResourceColor = $r('app.color.aiskin_bottom')
  static readonly glowLeft: ResourceColor = $r('app.color.aiskin_glowLeft')
  static readonly glowRight: ResourceColor = $r('app.color.aiskin_glowRight')
  static readonly glowMiddle: ResourceColor = $r('app.color.aiskin_glowMiddle')
  static readonly clear: ResourceColor = $r('app.color.aiskin_clear')
  static readonly danger: ResourceColor = $r('app.color.aiskin_danger')
  static readonly dangerSurface: ResourceColor = $r('app.color.aiskin_dangerSurface')
  static readonly warning: ResourceColor = $r('app.color.aiskin_warning')
  static readonly warningSurface: ResourceColor = $r('app.color.aiskin_warningSurface')
  static readonly success: ResourceColor = $r('app.color.aiskin_success')
  static readonly successSurface: ResourceColor = $r('app.color.aiskin_successSurface')
}

export { AISkinLayout } from './Foundation/AISkinTokens'

export function toneColor(tone: AISkinTone): ResourceColor {
  switch (tone) {
    case AISkinTone.Secondary: return AISkinColor.secondary
    case AISkinTone.Accent: return AISkinColor.accent
    case AISkinTone.Success: return AISkinColor.success
    case AISkinTone.Warning: return AISkinColor.warning
    case AISkinTone.Destructive: return AISkinColor.danger
    case AISkinTone.OnAccent: return AISkinColor.white
    default: return AISkinColor.text
  }
}
export class TextStyle implements AttributeModifier<TextAttribute> {
  private role: AISkinTextRole
  private tone: AISkinTone
  constructor(role: AISkinTextRole = AISkinTextRole.Body, tone: AISkinTone = AISkinTone.Primary) { this.role = role; this.tone = tone }
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(AISkinTypography.size(this.role)).fontWeight(AISkinTypography.weight(this.role))
      .fontColor(toneColor(this.tone))
  }
}
export class CardStyle implements AttributeModifier<CommonAttribute> {
  private role: AISkinCardRole
  private state: AISkinCardState
  private inset: AISkinCardInset
  constructor(role: AISkinCardRole = AISkinCardRole.Content, state: AISkinCardState = AISkinCardState.Normal,
    inset: AISkinCardInset = AISkinCardInset.None) { this.role = role; this.state = state; this.inset = inset }
  applyNormalAttribute(instance: CommonAttribute): void {
    const radius = this.role === AISkinCardRole.Feature ? AISkinRadius.featureCard : this.role === AISkinCardRole.Routine ? AISkinRadius.routineCard : this.role === AISkinCardRole.Action ? AISkinRadius.actionCard : AISkinRadius.card
    const surface = this.state === AISkinCardState.Selected ? AISkinColor.selected : this.role === AISkinCardRole.Feature ? AISkinColor.featureSurface : this.role === AISkinCardRole.Routine ? AISkinColor.routineSurface : this.role === AISkinCardRole.Overlay ? AISkinColor.dialog : AISkinColor.surface
    instance.backgroundColor(surface).borderRadius(radius).borderWidth(AISkinLayout.hairline)
      .borderColor(this.state === AISkinCardState.Selected ? AISkinColor.accent : AISkinColor.border)
    if (this.inset === AISkinCardInset.Regular) instance.padding(AISkinSpacing.cardPadding)
  }
}
@Component
export struct AISkinBackground {
  @State screenWidth: number = 400
  @State screenHeight: number = 800
  private radius(x: number, y: number, fade: number): number {
    return Math.sqrt(Math.pow(this.screenWidth * Math.max(x, 1-x), 2) + Math.pow(this.screenHeight * Math.max(y, 1-y), 2)) * fade
  }
  build() {
    Stack() {
      Column().width('100%').height('100%')
        .linearGradient({ angle: 180, colors: [[AISkinColor.top, 0], [AISkinColor.middle, 0.58], [AISkinColor.bottom, 1]] })
      Column().width('100%').height('100%')
        .radialGradient({ center: ['65%', '54%'], radius: this.radius(0.65, 0.54, 0.42), colors: [[AISkinColor.glowMiddle, 0], ['#00EEC6E6', 1]] })
      Column().width('100%').height('100%')
        .radialGradient({ center: ['91%', '13%'], radius: this.radius(0.91, 0.13, 0.34), colors: [[AISkinColor.glowRight, 0], ['#00C2A9EF', 1]] })
      Column().width('100%').height('100%')
        .radialGradient({ center: ['14%', '9%'], radius: this.radius(0.14, 0.09, 0.32), colors: [[AISkinColor.glowLeft, 0], ['#00E9A2DD', 1]] })
    }.width('100%').height('100%').hitTestBehavior(HitTestMode.None)
    .onAreaChange((_old: Area, area: Area) => { this.screenWidth = Number(area.width); this.screenHeight = Number(area.height) })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
