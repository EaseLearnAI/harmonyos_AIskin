import { AISkinColor, CardStyle, TextStyle, toneColor } from './AISkinTheme'
import { AISkinIcon } from './AISkinIcon'
import { AISkinLayout, AISkinRadius, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinTypography, AISkinCardRole, AISkinCardState, AISkinCardInset, AISkinMotion, AISkinButtonVariant, AISkinButtonLayout, AISkinFieldVariant, AISkinFieldState, AISkinTagState, AISkinTagVariant, AISkinTabVariant, AISkinStateKind } from './Foundation/AISkinTokens'

@Component
export struct AISkinCard {
  @Prop role: AISkinCardRole = AISkinCardRole.Content
  @Prop state: AISkinCardState = AISkinCardState.Normal
  @Prop inset: AISkinCardInset = AISkinCardInset.Regular
  @BuilderParam content: () => void
  build() { Column() { this.content() }.width('100%').alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle(this.role, this.state, this.inset)) }
}
@Component
export struct AISkinButton {
  @Prop title: string = ''
  @Prop textRole: AISkinTextRole = AISkinTextRole.Button
  @Prop tone: AISkinTone = AISkinTone.Accent
  @Prop icon: string = ''
  @Prop variant: AISkinButtonVariant = AISkinButtonVariant.Primary
  @Prop layout: AISkinButtonLayout = AISkinButtonLayout.FullWidth
  @Prop isLoading: boolean = false
  @Prop isEnabled: boolean = true
  @State pressed: boolean = false
  onAction?: () => void
  private foreground(): ResourceColor { return this.variant === AISkinButtonVariant.Primary ? AISkinColor.white : this.variant === AISkinButtonVariant.Destructive ? AISkinColor.danger : this.variant === AISkinButtonVariant.Surface ? AISkinColor.text : toneColor(this.tone) }
  private surface(): ResourceColor { return this.variant === AISkinButtonVariant.Primary ? AISkinColor.primary : this.variant === AISkinButtonVariant.Plain ? Color.Transparent : this.pressed ? AISkinColor.selected : this.variant === AISkinButtonVariant.Surface ? AISkinColor.elevated : AISkinColor.selected }
  build() {
    Button() {
      Stack() {
        Row({ space: AISkinSpacing.xSmall }) {
          if (this.icon) { AISkinIcon({ name: this.icon, selected: this.tone === AISkinTone.Accent, iconSize: AISkinLayout.iconSize }) }
          Text(this.title).fontSize(AISkinTypography.size(this.textRole === AISkinTextRole.Button && this.layout === AISkinButtonLayout.Compact ? AISkinTextRole.CompactButton : this.textRole))
            .fontWeight(AISkinTypography.weight(this.textRole)).fontColor(this.foreground()).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }.opacity(this.isLoading ? 0 : 1)
        if (this.isLoading) { LoadingProgress().width(AISkinLayout.iconSize).height(AISkinLayout.iconSize).color(this.foreground()) }
      }.constraintSize({ minHeight: AISkinLayout.tap }).padding({ left: this.variant === AISkinButtonVariant.Plain ? 0 : AISkinSpacing.medium, right: this.variant === AISkinButtonVariant.Plain ? 0 : AISkinSpacing.medium })
    }.padding(0).type(ButtonType.Normal).width(this.layout === AISkinButtonLayout.FullWidth ? '100%' : 'auto')
      .constraintSize({ minWidth: AISkinLayout.tap, minHeight: AISkinLayout.tap }).borderRadius(AISkinRadius.control)
      .backgroundColor(this.surface()).border({ width: this.variant === AISkinButtonVariant.Surface ? AISkinLayout.hairline : 0, color: AISkinColor.border, radius: AISkinRadius.control })
      .opacity(!this.isEnabled || this.isLoading ? AISkinMotion.disabledOpacity : this.pressed ? AISkinMotion.pressedOpacity : 1)
      .enabled(this.isEnabled && !this.isLoading).accessibilityText(this.isLoading ? `${this.title}，正在处理` : this.title)
      .onTouch((event: TouchEvent) => { this.pressed = event.type === TouchType.Down })
      .onClick(() => this.onAction?.())
  }
}
@Component
export struct AISkinField {
  @Prop value: string = ''
  @Prop placeholder: string = ''
  @Prop leadingText: string = ''
  @Prop trailingText: string = ''
  @Prop inputType: InputType = InputType.Normal
  @Prop isPassword: boolean = false
  @Prop multiline: boolean = false
  @Prop error: string = ''
  @Prop isLoading: boolean = false
  @Prop variant: AISkinFieldVariant = AISkinFieldVariant.Standard
  @State focused: boolean = false
  @State reveal: boolean = false
  onChange?: (value: string) => void
  private fieldBorderColor(): ResourceColor { return this.error ? AISkinColor.danger : this.focused ? AISkinColor.accent : AISkinColor.border }
  build() {
    Column({ space: AISkinSpacing.xxSmall }) {
      Row({ space: AISkinSpacing.xSmall }) {
        if (this.leadingText) { Text(this.leadingText).attributeModifier(new TextStyle(AISkinTextRole.ReportBody)) }
        if (this.multiline) {
          TextArea({ text: this.value, placeholder: this.placeholder }).layoutWeight(1).constraintSize({ minHeight: AISkinLayout.noteHeight })
            .fontSize(AISkinTypography.size(AISkinTextRole.ReportBody)).fontColor(AISkinColor.text).placeholderColor(AISkinColor.secondary)
            .backgroundColor(Color.Transparent).padding({ top: AISkinSpacing.xSmall, bottom: AISkinSpacing.xSmall, left: 0, right: 0 }).onFocus(() => { this.focused = true }).onBlur(() => { this.focused = false })
            .onChange((value: string) => this.onChange?.(value))
        } else {
          TextInput({ text: this.value, placeholder: this.placeholder }).type(this.isPassword && !this.reveal ? InputType.Password : this.inputType).showPasswordIcon(false)
            .layoutWeight(1).height(this.variant === AISkinFieldVariant.Form ? AISkinLayout.formFieldHeight : AISkinLayout.fieldHeight)
            .fontSize(AISkinTypography.size(AISkinTextRole.ReportBody)).fontColor(AISkinColor.text).placeholderColor(AISkinColor.secondary)
            .backgroundColor(Color.Transparent).padding(0).onFocus(() => { this.focused = true }).onBlur(() => { this.focused = false })
            .onChange((value: string) => this.onChange?.(value))
        }
        if (this.trailingText) { Text(this.trailingText).attributeModifier(new TextStyle(AISkinTextRole.ReportBody,AISkinTone.Secondary)) }
        if (this.isPassword) {
          AISkinButton({ title: this.reveal ? '隐藏' : '显示', variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact, onAction: () => { this.reveal = !this.reveal } })
        }
        if (this.isLoading) { LoadingProgress().width(AISkinLayout.iconSize).height(AISkinLayout.iconSize).color(AISkinColor.accent) }
      }.width('100%').padding({ left: AISkinSpacing.medium, right: AISkinSpacing.medium }).backgroundColor(AISkinColor.surface)
        .borderRadius(this.variant === AISkinFieldVariant.Form ? AISkinRadius.medium : AISkinRadius.control)
        .border({ width: this.focused || !!this.error ? AISkinLayout.emphasisLine : AISkinLayout.hairline, color: this.fieldBorderColor() })
        .enabled(!this.isLoading)
      if (this.error) { Text(this.error).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Destructive)).width('100%') }
    }.width('100%')
  }
}
@Component
export struct AISkinTag {
  @Prop title: string = ''
  @Prop tone: AISkinTone = AISkinTone.Secondary
  @Prop state: AISkinTagState = AISkinTagState.Normal
  @Prop variant: AISkinTagVariant = AISkinTagVariant.Badge
  onAction?: () => void
  build() {
    Button() {
      Row({ space: AISkinSpacing.xxSmall }) {
        Text(this.title).attributeModifier(new TextStyle(this.variant === AISkinTagVariant.Badge ? AISkinTextRole.Caption : this.variant === AISkinTagVariant.SelectionCell ? AISkinTextRole.ReportBody : AISkinTextRole.Callout, this.state === AISkinTagState.Selected ? AISkinTone.Accent : this.variant === AISkinTagVariant.SelectionCell ? AISkinTone.Primary : this.tone)).maxLines(1)
        if (this.variant === AISkinTagVariant.SelectionCell && this.state === AISkinTagState.Selected) { Text('✓').attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Accent)) }
      }.padding({ left: AISkinSpacing.small, right: AISkinSpacing.small })
    }.padding(0).type(ButtonType.Normal).width(this.variant === AISkinTagVariant.SelectionCell ? '100%' : 'auto').constraintSize({ minHeight: this.variant === AISkinTagVariant.SelectionCell ? AISkinLayout.formFieldHeight : this.onAction ? AISkinLayout.tap : AISkinLayout.tagHeight, minWidth: this.onAction ? AISkinLayout.tap : 0 })
      .borderRadius(this.variant === AISkinTagVariant.SelectionCell ? AISkinRadius.medium : (this.onAction ? AISkinLayout.tap : AISkinLayout.tagHeight) / 2)
      .backgroundColor(this.state === AISkinTagState.Selected ? (this.variant === AISkinTagVariant.SelectionCell ? AISkinColor.elevated : AISkinColor.selected) : AISkinColor.surface)
      .border({ width: AISkinLayout.hairline, color: this.state === AISkinTagState.Selected ? AISkinColor.accent : AISkinColor.border, radius: this.variant === AISkinTagVariant.SelectionCell ? AISkinRadius.medium : (this.onAction ? AISkinLayout.tap : AISkinLayout.tagHeight) / 2 })
      .opacity(this.state === AISkinTagState.Disabled ? AISkinMotion.disabledOpacity : 1)
      .enabled(this.state !== AISkinTagState.Disabled).accessibilityText(`${this.title}${this.state === AISkinTagState.Selected ? '，已选中' : ''}`)
      .onClick(() => this.onAction?.())
  }
}
@Component
export struct AISkinTabs {
  @Prop items: string[] = []
  @Prop icons: string[] = []
  @Prop selection: number = 0
  @Prop variant: AISkinTabVariant = AISkinTabVariant.Underline
  @Prop regular: boolean = false
  onSelect?: (index: number) => void
  build() {
    Row({ space: this.variant === AISkinTabVariant.Segmented ? AISkinSpacing.xxSmall : 0 }) {
      ForEach(this.items, (title: string, index: number) => {
        Button() {
          Column({ space: AISkinSpacing.xxSmall }) {
            Row({ space: AISkinSpacing.xSmall }) {
              if (this.icons[index]) { AISkinIcon({ name: this.icons[index], iconSize: AISkinLayout.iconSize, selected: false }) }
              Text(title).attributeModifier(new TextStyle(this.variant === AISkinTabVariant.Segmented ? AISkinTextRole.SegmentedLabel : this.regular ? AISkinTextRole.Callout : AISkinTextRole.ReportTab, this.selection === index ? AISkinTone.Primary : AISkinTone.Secondary)).maxLines(1)
            }
            if (this.variant === AISkinTabVariant.Underline) {
              Rect().width(AISkinLayout.tabIndicatorWidth).height(AISkinLayout.tabIndicatorHeight).radius(AISkinRadius.capsule).fill(this.selection === index ? AISkinColor.accent : Color.Transparent)
            }
          }.width('100%').constraintSize({ minHeight: this.regular ? AISkinLayout.regularUnderlineHeight : AISkinLayout.tap }).justifyContent(FlexAlign.Center)
        }.padding(0).type(ButtonType.Normal).layoutWeight(1).borderRadius(AISkinRadius.capsule)
          .backgroundColor(this.variant === AISkinTabVariant.Segmented && this.selection === index ? AISkinColor.elevated : Color.Transparent)
          .accessibilityText(`${title}${this.selection === index ? '，已选中' : ''}`).onClick(() => this.onSelect?.(index))
      })
    }.width('100%').padding(this.variant === AISkinTabVariant.Segmented ? AISkinSpacing.xxxSmall : 0)
      .backgroundColor(this.variant === AISkinTabVariant.Segmented ? AISkinColor.selected : Color.Transparent).borderRadius(AISkinRadius.capsule)
  }
}
@Component
export struct AISkinStateView {
  @Prop title: string = ''
  @Prop message: string = ''
  @Prop kind: AISkinStateKind = AISkinStateKind.Empty
  onRetry?: () => void
  build() {
    Column({ space: AISkinSpacing.small }) {
      if (this.kind === AISkinStateKind.Loading) { LoadingProgress().width(AISkinLayout.tap).height(AISkinLayout.tap).color(AISkinColor.accent) }
      Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.CardTitle, this.kind === AISkinStateKind.Error ? AISkinTone.Destructive : AISkinTone.Primary)).textAlign(TextAlign.Center)
      if (this.message) { Text(this.message).attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary)).textAlign(TextAlign.Center) }
      if (this.onRetry) { AISkinButton({ title: '重试', variant: AISkinButtonVariant.Secondary, layout: AISkinButtonLayout.Compact, onAction: this.onRetry }) }
    }.width('100%').padding(AISkinSpacing.cardPadding)
  }
}
@Component
export struct AISkinIconButton {
  @Prop name: string = 'back'
  @Prop label: string = '返回'
  @Prop tone: AISkinTone = AISkinTone.Accent
  @Prop iconSize: number = AISkinLayout.iconSize
  @Prop variant: AISkinButtonVariant = AISkinButtonVariant.Surface
  @Prop isEnabled: boolean = true
  @Prop menuItems: MenuElement[] = []
  @State menuVisible: boolean = false
  onAction?: () => void
  build() {
    Button() { AISkinIcon({ name: this.name, iconSize: this.iconSize, tone: this.tone, selected: this.tone === AISkinTone.Accent }) }
      .padding(0).type(ButtonType.Circle).width(AISkinLayout.tap).height(AISkinLayout.tap)
      .backgroundColor(this.variant === AISkinButtonVariant.Plain ? Color.Transparent : AISkinColor.elevated)
      .enabled(this.isEnabled).opacity(this.isEnabled ? 1 : AISkinMotion.disabledOpacity).accessibilityText(this.label).bindMenu(this.menuVisible, this.menuItems, { onDisappear: () => { this.menuVisible = false } })
      .onClick(() => { if (this.menuItems.length) this.menuVisible = true; else this.onAction?.() })
  }
}
export enum AISkinHeaderLayout { Centered, LeadingTitleSubtitle }
@Component
export struct AISkinHeader {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop layout: AISkinHeaderLayout = AISkinHeaderLayout.Centered
  @Prop leftIcon: string = ''
  @Prop leftLabel: string = '返回'
  @Prop rightIcon: string = ''
  @Prop rightLabel: string = ''
  onLeft?: () => void
  onRight?: () => void
  @Builder
  titleContent() {
    Column({ space: AISkinSpacing.xxSmall }) {
      Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.ScreenTitle)).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.subtitle) { Text(this.subtitle).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary)).maxLines(1) }
    }.alignItems(this.layout === AISkinHeaderLayout.LeadingTitleSubtitle ? HorizontalAlign.Start : HorizontalAlign.Center)
  }
  build() {
    if (this.layout === AISkinHeaderLayout.LeadingTitleSubtitle) {
      Row({ space: AISkinSpacing.small }) {
        if (this.leftIcon) { AISkinIconButton({ name: this.leftIcon, label: this.leftLabel, variant: AISkinButtonVariant.Plain, onAction: this.onLeft }) }
        Column() { this.titleContent() }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        if (this.rightIcon) { AISkinIconButton({ name: this.rightIcon, label: this.rightLabel, onAction: this.onRight }) }
      }.width('100%').constraintSize({ minHeight: AISkinLayout.headerHeight })
        .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge })
    } else {
      Stack() {
        Column() { this.titleContent() }.padding({ left: AISkinLayout.headerHeight, right: AISkinLayout.headerHeight })
        Row() {
          if (this.leftIcon) { AISkinIconButton({ name: this.leftIcon, label: this.leftLabel, onAction: this.onLeft }) }
          Blank()
          if (this.rightIcon) { AISkinIconButton({ name: this.rightIcon, label: this.rightLabel, onAction: this.onRight }) }
        }.width('100%')
      }.width('100%').constraintSize({ minHeight: AISkinLayout.headerHeight })
        .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge })
    }
  }
}
