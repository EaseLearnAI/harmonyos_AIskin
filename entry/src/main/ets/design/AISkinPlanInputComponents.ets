import { AISkinColor, CardStyle, TextStyle } from './AISkinTheme'
import { AISkinButton, AISkinField, AISkinTag } from './AISkinPrimitives'
import { AISkinIcon } from './AISkinIcon'
import { AISkinSettingsRow } from './AISkinAccountComponents'
import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinButtonVariant, AISkinButtonLayout, AISkinFieldVariant, AISkinTagState, AISkinTagVariant, AISkinMotion } from './Foundation/AISkinTokens'
import { AISkinPlanInputTokens } from './Foundation/AISkinPlanInputTokens'
export interface PlanConcernOption { label: string; value: string }

@Component
export struct AISkinPlanSourceRow {
  @Prop title: string = ''
  @Prop detail: string = ''
  @Prop actionTitle: string = ''
  @Prop isEnabled: boolean = true
  onAction?: () => void
  build() {
    Row({ space: AISkinSpacing.small }) {
      AISkinIcon({ name: 'skin', iconSize: AISkinLayout.iconSize, selected: true })
      Column({ space: AISkinSpacing.xxSmall }) {
        Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.CompactButton))
        Text(this.detail).attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      AISkinButton({ title: this.actionTitle, variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact,
        isEnabled: this.isEnabled, onAction: this.onAction })
    }.width('100%').padding({ left: AISkinSpacing.medium, right: AISkinSpacing.medium, top: AISkinSpacing.xSmall, bottom: AISkinSpacing.xSmall })
      .attributeModifier(new CardStyle())
  }
}
@Component
export struct AISkinPlanGoals {
  @Prop options: PlanConcernOption[] = []
  @Prop selection: string[] = []
  @Prop isEnabled: boolean = true
  onToggle?: (value: string) => void
  build() {
    Column({ space: AISkinSpacing.xSmall }) {
      Row() {
        Text('护肤目标').attributeModifier(new TextStyle(AISkinTextRole.CompactButton))
        Blank()
        Text(`已选 ${this.selection.length}/3 项`).attributeModifier(new TextStyle(AISkinTextRole.CompactCaption, AISkinTone.Secondary))
      }.width('100%')
      Grid() {
        ForEach(this.options, (item: PlanConcernOption) => {
          GridItem() {
            AISkinTag({ title: item.label, tone: AISkinTone.Accent, variant: AISkinTagVariant.SelectionCell,
              state: !this.isEnabled ? AISkinTagState.Disabled : this.selection.includes(item.value) ? AISkinTagState.Selected : AISkinTagState.Normal,
              onAction: () => this.onToggle?.(item.value) }).width('100%')
          }
        }, (item: PlanConcernOption) => item.value)
      }.width('100%').height(AISkinLayout.formFieldHeight * 2 + AISkinPlanInputTokens.goalGridGap)
        .columnsTemplate('1fr 1fr 1fr').rowsTemplate('1fr 1fr')
        .columnsGap(AISkinPlanInputTokens.goalGridGap).rowsGap(AISkinPlanInputTokens.goalGridGap)
    }.width('100%')
  }
}
@Component
export struct AISkinPlanRequirements {
  @Prop value: string = ''
  @Prop isEnabled: boolean = true
  onChange?: (value: string) => void
  build() {
    Column({ space: AISkinSpacing.xSmall }) {
      Row({ space: AISkinSpacing.xSmall }) {
        Text('补充需求').attributeModifier(new TextStyle(AISkinTextRole.CompactButton))
        Text('选填').attributeModifier(new TextStyle(AISkinTextRole.CompactCaption, AISkinTone.Secondary))
      }.width('100%')
      AISkinField({ value: this.value, placeholder: '例如：希望步骤少一点，最近两颊容易干燥。', multiline: true,
        variant: AISkinFieldVariant.Form, isLoading: !this.isEnabled,
        onChange: this.onChange })
        .constraintSize({ minHeight: AISkinPlanInputTokens.noteHeight })
      Text('可以填写产品偏好、使用习惯或希望避开的成分。')
        .attributeModifier(new TextStyle(AISkinTextRole.CompactCaption, AISkinTone.Secondary)).width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
@Component
export struct AISkinPlanPersonalStates {
  @Prop age: number = 0
  @Prop isExpanded: boolean = false
  @Prop isInCycle: boolean = false
  @Prop cycleDay: string = '1'
  @Prop isEnabled: boolean = true
  @State pressed: boolean = false
  onToggleExpanded?: () => void
  onEditAge?: () => void
  onCycleChange?: (value: boolean) => void
  onCycleDayChange?: (value: string) => void
  build() {
    Column({ space: AISkinSpacing.small }) {
      Button() {
        Row() {
          Text('其他个人状态').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary))
          Blank()
          AISkinIcon({ name: 'back', iconSize: AISkinLayout.iconSize }).rotate({ angle: this.isExpanded ? -90 : 180 })
        }.width('100%').constraintSize({ minHeight: AISkinLayout.tap })
      }.width('100%').padding(0).type(ButtonType.Normal).backgroundColor(Color.Transparent)
        .enabled(this.isEnabled).opacity(this.isEnabled ? (this.pressed ? AISkinMotion.pressedOpacity : 1) : AISkinMotion.disabledOpacity)
        .accessibilityText(`其他个人状态，${this.isExpanded ? '已展开' : '已收起'}`)
        .onTouch((event: TouchEvent) => { this.pressed = event.type === TouchType.Down }).onClick(() => this.onToggleExpanded?.())
      if (this.isExpanded) {
        AISkinSettingsRow({ title: '年龄', value: this.age ? `${this.age} 岁` : '未填写', isEnabled: this.isEnabled, onAction: this.onEditAge })
        Row({ space: AISkinSpacing.small }) {
          Text('当前处于生理周期').attributeModifier(new TextStyle(AISkinTextRole.Disclosure, AISkinTone.Secondary)).layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.isInCycle }).selectedColor(AISkinColor.accent)
            .enabled(this.isEnabled).accessibilityText('当前处于生理周期').onChange((value: boolean) => this.onCycleChange?.(value))
        }.width('100%').constraintSize({ minHeight: AISkinLayout.tap })
        if (this.isInCycle) {
          AISkinField({ value: this.cycleDay, leadingText: '周期第几天', trailingText: '天', placeholder: '1–7', inputType: InputType.Number,
            variant: AISkinFieldVariant.Form, isLoading: !this.isEnabled, onChange: this.onCycleDayChange })
        }
      }
    }.width('100%')
  }
}
