import { AISkinColor, TextStyle } from './AISkinTheme'
import { AISkinButton } from './AISkinPrimitives'
import { AISkinButtonLayout, AISkinButtonVariant, AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone } from './Foundation/AISkinTokens'
import { AISkinOnboardingTokens } from './Foundation/AISkinOnboardingTokens'
@Component
export struct AISkinOnboardingSlide {
  @Prop number: string = ''
  @Prop title: string = ''
  @Prop accentTitle: string = ''
  @Prop detail: string = ''
  @Prop artwork: Resource = $r('app.media.onboarding_skin')
  @Prop imageDescription: string = ''
  @Prop animationsEnabled: boolean = true
  @StorageProp('aiskinDark') dark: boolean = false
  @State viewportHeight: number = AISkinOnboardingTokens.compactHeight
  @State viewportWidth: number = AISkinOnboardingTokens.contentMaxWidth
  @State appeared: boolean = false
  aboutToAppear() { this.getUIContext().animateTo({ duration: this.animationsEnabled ? AISkinOnboardingTokens.entranceDuration : 0, curve: Curve.EaseOut }, () => { this.appeared = true }) }
  private artworkSize(): number { return Math.min(AISkinOnboardingTokens.artworkMaxSize, this.viewportWidth - AISkinOnboardingTokens.artworkInset * 2, Math.max(AISkinOnboardingTokens.artworkMinimumSize, this.viewportHeight - AISkinOnboardingTokens.headingHeight)) }
  build() {
    Scroll() {
      Column() {
        Column() {
          Text(this.number).fontSize(AISkinOnboardingTokens.numberSize).letterSpacing(AISkinOnboardingTokens.numberTracking).fontColor(AISkinColor.accent).opacity(AISkinOnboardingTokens.numberOpacity).margin({ bottom: AISkinSpacing.medium })
          Column({ space: AISkinOnboardingTokens.titleSpacing }) {
            Text(this.title).fontColor(AISkinColor.text).fontSize(this.viewportHeight < AISkinOnboardingTokens.compactHeight ? AISkinOnboardingTokens.compactTitleSize : AISkinOnboardingTokens.titleSize).fontWeight(FontWeight.Medium).letterSpacing(AISkinOnboardingTokens.titleTracking).textAlign(TextAlign.Center)
            Text(this.accentTitle).fontColor(AISkinColor.accent).fontSize(this.viewportHeight < AISkinOnboardingTokens.compactHeight ? AISkinOnboardingTokens.compactTitleSize : AISkinOnboardingTokens.titleSize).fontWeight(FontWeight.Medium).letterSpacing(AISkinOnboardingTokens.titleTracking).textAlign(TextAlign.Center)
          }
          Text(this.detail).fontSize(AISkinOnboardingTokens.bodySize).lineHeight(AISkinOnboardingTokens.bodySize + AISkinOnboardingTokens.copyLineSpacing).fontColor(AISkinColor.secondary).textAlign(TextAlign.Center).margin({ top: AISkinSpacing.small })
        }.width('100%').padding({ left: AISkinSpacing.large, right: AISkinSpacing.large, top: this.viewportHeight < AISkinOnboardingTokens.compactHeight ? AISkinOnboardingTokens.compactTopInset : AISkinOnboardingTokens.topInset })
        Stack() {
          Image(this.artwork).objectFit(ImageFit.Contain).width('100%').height('100%').accessibilityText(this.imageDescription)
          Column().width('100%').height('100%').linearGradient({ angle: 180, colors: [[AISkinColor.clear, 0], [AISkinColor.text, AISkinOnboardingTokens.maskStart], [AISkinColor.text, AISkinOnboardingTokens.verticalMaskEnd], [AISkinColor.clear, 1]] }).blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
          Column().width('100%').height('100%').linearGradient({ angle: 90, colors: [[AISkinColor.clear, 0], [AISkinColor.text, AISkinOnboardingTokens.maskStart], [AISkinColor.text, AISkinOnboardingTokens.horizontalMaskEnd], [AISkinColor.clear, 1]] }).blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
        }.width(this.artworkSize()).height(this.artworkSize()).blendMode(this.dark ? BlendMode.SRC_OVER : BlendMode.MULTIPLY).renderGroup(true)
      }.width('100%').constraintSize({ minHeight: this.viewportHeight })
    }.width('100%').height('100%').scrollBar(BarState.Off).align(Alignment.Top)
      .onAreaChange((_old: Area, area: Area) => { this.viewportHeight = Number(area.height); this.viewportWidth = Number(area.width) })
      .opacity(this.appeared || !this.animationsEnabled ? 1 : 0).translate({ y: this.appeared || !this.animationsEnabled ? 0 : AISkinOnboardingTokens.entranceOffset })
  }
}
@Component
export struct AISkinPageControl {
  @Prop labels: string[] = []
  @Prop selection: number = 0
  onSelect?: (index: number) => void
  build() {
    Row() {
      ForEach(this.labels, (label: string, index: number) => {
        Button() { Circle().width(AISkinOnboardingTokens.dotSize).height(AISkinOnboardingTokens.dotSize).fill(AISkinColor.accent).opacity(this.selection === index ? 1 : AISkinOnboardingTokens.inactiveDotOpacity) }
          .width(AISkinLayout.tap).height(AISkinLayout.tap).backgroundColor(Color.Transparent)
          .accessibilityText(`第 ${index + 1} 页：${label}${this.selection === index ? '，已选中' : ''}`).onClick(() => this.onSelect?.(index))
      })
    }
  }
}
@Component
export struct AISkinAuthFooter {
  @Prop actionTitle: string = '登录 / 注册'
  onContinue?: () => void
  onLegalDocument?: (title: string) => void
  build() {
    Column() {
      AISkinButton({ title: this.actionTitle, onAction: this.onContinue })
      Row({ space: AISkinSpacing.xSmall }) {
        this.legalLink('使用条款')
        Text('·').attributeModifier(new TextStyle(AISkinTextRole.CompactCaption, AISkinTone.Secondary))
        this.legalLink('隐私政策')
      }
    }.width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinOnboardingTokens.footerBottom })
  }
  @Builder
  legalLink(title: string) {
    Button() { Text(title).attributeModifier(new TextStyle(AISkinTextRole.CompactCaption, AISkinTone.Secondary)).decoration({ type: TextDecorationType.Underline }) }
      .height(AISkinLayout.tap).backgroundColor(Color.Transparent).onClick(() => this.onLegalDocument?.(title))
  }
}
