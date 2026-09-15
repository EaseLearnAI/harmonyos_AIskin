import { AISkinColor, CardStyle, TextStyle } from './AISkinTheme'
import { AISkinIcon } from './AISkinIcon'
import { AISkinSpacing, AISkinTextRole, AISkinTone, AISkinMotion } from './Foundation/AISkinTokens'
import { AISkinAccountTokens, AISkinAccountTextRole } from './Foundation/AISkinAccountTokens'

export class AccountTextStyle implements AttributeModifier<TextAttribute> {
  private role: AISkinAccountTextRole
  constructor(role: AISkinAccountTextRole) { this.role = role }
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(this.role === AISkinAccountTextRole.Name ? AISkinAccountTokens.profileNameSize : this.role === AISkinAccountTextRole.RowTitle ? AISkinAccountTokens.settingsTitleSize : AISkinAccountTokens.sectionLabelSize)
      .fontWeight(this.role === AISkinAccountTextRole.RowTitle ? FontWeight.Normal : FontWeight.Medium)
      .fontColor(this.role === AISkinAccountTextRole.SectionLabel ? AISkinColor.secondary : AISkinColor.text)
  }
}
@Component
export struct AISkinProfilePanel {
  @Prop minimumHeight: number = 0
  @BuilderParam content: () => void
  build() {
    Column() {
      Blank().height(AISkinAccountTokens.profileCoverHeight)
      Column() { this.content() }.width('100%').alignItems(HorizontalAlign.Start)
        .padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, bottom: AISkinSpacing.xxLarge })
        .constraintSize({ minHeight: Math.max(0, this.minimumHeight - AISkinAccountTokens.profileCoverHeight) })
        .backgroundColor(AISkinColor.surface)
        .borderRadius({ topLeft: AISkinAccountTokens.profilePanelRadius, topRight: AISkinAccountTokens.profilePanelRadius })
    }.width('100%')
  }
}
@Component
export struct AISkinProfileIdentity {
  @Prop name: string = '析肤用户'
  @Prop avatarURL: string = ''
  build() {
    Column({ space: AISkinSpacing.medium }) {
      Stack() {
        if (this.avatarURL) {
          Image(this.avatarURL).width('100%').height('100%').objectFit(ImageFit.Cover)
        } else {
          AISkinIcon({ name: 'profile', iconSize: AISkinAccountTokens.avatarIconSize, selected: true })
        }
      }.width(AISkinAccountTokens.avatarSize).height(AISkinAccountTokens.avatarSize)
        .backgroundColor(AISkinColor.elevated).borderRadius(AISkinAccountTokens.avatarRadius).clip(true)
        .border({ width: AISkinAccountTokens.avatarBorder, color: AISkinColor.surface })
        .accessibilityText('头像')
      Column({ space: AISkinSpacing.xSmall }) {
        Text(this.name).attributeModifier(new AccountTextStyle(AISkinAccountTextRole.Name)).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('每一次护肤，都有迹可循').attributeModifier(new TextStyle(AISkinTextRole.ReportBody, AISkinTone.Secondary))
      }.width('100%').alignItems(HorizontalAlign.Start)
    }.width('100%').alignItems(HorizontalAlign.Start).margin({ top: -AISkinAccountTokens.avatarOverlap })
  }
}
@Component
export struct AISkinSettingsRow {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop icon: string = ''
  @Prop isDestructive: boolean = false
  @Prop showsChevron: boolean = true
  @Prop isEnabled: boolean = true
  @State pressed: boolean = false
  onAction?: () => void
  @Builder
  rowContent() {
    Row({ space: AISkinSpacing.small }) {
      if (this.icon) { AISkinIcon({ name: this.icon, iconSize: AISkinAccountTokens.settingsIconWidth }) }
      Text(this.title).attributeModifier(new AccountTextStyle(AISkinAccountTextRole.RowTitle))
        .fontColor(this.isDestructive ? AISkinColor.danger : AISkinColor.text)
      Blank().constraintSize({ minWidth: AISkinSpacing.small })
      if (this.value) { Text(this.value).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary)) }
      if (this.showsChevron) { Text('›').attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary)) }
    }.width('100%').constraintSize({ minHeight: AISkinAccountTokens.settingsHeight })
      .padding({ left: AISkinSpacing.medium, right: AISkinSpacing.medium })
  }
  build() {
    if (this.onAction) {
      Button() { this.rowContent() }.type(ButtonType.Normal).width('100%').backgroundColor(Color.Transparent)
        .enabled(this.isEnabled).opacity(this.isEnabled ? (this.pressed ? AISkinMotion.pressedOpacity : 1) : AISkinMotion.disabledOpacity)
        .accessibilityText(`${this.title}${this.value ? '，' + this.value : ''}`)
        .onTouch((event: TouchEvent) => { this.pressed = event.type === TouchType.Down })
        .onClick(() => this.onAction?.())
    } else { this.rowContent() }
  }
}

export interface AISkinSettingsItem {
  id: string
  title: string
  value?: string
  icon?: string
  isDestructive?: boolean
  showsChevron?: boolean
  isAction?: boolean
}
@Component
export struct AISkinSettingsGroup {
  @Prop items: AISkinSettingsItem[] = []
  @Prop isEnabled: boolean = true
  onSelect?: (id: string) => void
  build() {
    Column() {
      ForEach(this.items, (item: AISkinSettingsItem, index: number) => {
        if (index > 0) { Divider().color(AISkinColor.divider) }
        AISkinSettingsRow({ title: item.title, value: item.value || '', icon: item.icon || '',
          isDestructive: item.isDestructive || false, showsChevron: item.showsChevron !== false,
          isEnabled: this.isEnabled,
          onAction: item.isAction ? () => this.onSelect?.(item.id) : undefined })
      }, (item: AISkinSettingsItem) => item.id)
    }.width('100%').attributeModifier(new CardStyle())
  }
}
