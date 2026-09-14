// Values verified against ios_aiskin @ 9f69aa9 / AISkinColor.swift.
export class AISkinColor {
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

export class AISkinLayout {
  static readonly edge: number = 24
  static readonly gap: number = 12
  static readonly radius: number = 24
  static readonly controlRadius: number = 16
  static readonly tap: number = 48
  static readonly maxWidth: number = 600
}

export class CardStyle implements AttributeModifier<CommonAttribute> {
  applyNormalAttribute(instance: CommonAttribute): void {
    instance.backgroundColor(AISkinColor.surface)
      .borderRadius(AISkinLayout.radius)
      .border({ width: 1, color: AISkinColor.border })
      .shadow({ radius: 12, color: AISkinColor.shadow, offsetY: 4 })
  }
}

export class PrimaryButtonStyle implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.height(AISkinLayout.tap).borderRadius(AISkinLayout.controlRadius)
      .backgroundColor(AISkinColor.primary).fontColor(AISkinColor.white).fontSize(16)
  }
  applyPressedAttribute(instance: ButtonAttribute): void { instance.opacity(0.78) }
  applyDisabledAttribute(instance: ButtonAttribute): void { instance.opacity(0.45) }
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
