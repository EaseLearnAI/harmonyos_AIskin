import { AISkinColor, TextStyle } from './AISkinTheme'
import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone } from './Foundation/AISkinTokens'
import { AISkinProductTokens } from './Foundation/AISkinProductTokens'
import { ProductThumbnail } from './AISkinProductThumbnail'

@Component
export struct AISkinProductRow {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = ''
  @Prop imageUrl: string = ''
  @Prop accessibilityLabel: string = ''
  @Prop accessibilityValue: string = '查看成分分析'
  @BuilderParam accessory: () => void
  onSelect?: () => void
  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Button() {
        Row({ space: AISkinSpacing.small }) {
          Column({ space: AISkinSpacing.xxSmall }) {
            ProductThumbnail({ url: this.imageUrl })
            if (this.category) { Text(this.category).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary)).maxLines(1) }
          }.width(AISkinLayout.productThumbnailCabinet)
          Column({ space: AISkinProductTokens.textGap }) {
            Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.ProductTitle)).maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%').constraintSize({ minHeight: AISkinProductTokens.titleLineHeight })
            if (this.summary) { Text(this.summary).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary))
              .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%') }
          }.layoutWeight(1).alignItems(HorizontalAlign.Start).padding({ right: AISkinLayout.tap + AISkinSpacing.xSmall })
        }.width('100%').alignItems(VerticalAlign.Top)
      }.type(ButtonType.Normal).backgroundColor(AISkinColor.clear).padding(AISkinSpacing.medium)
        .width('100%').constraintSize({ minHeight: AISkinProductTokens.cardMinimumHeight })
        .accessibilityText(`${this.accessibilityLabel || this.title}，${this.accessibilityValue}`).onClick((): void => { this.onSelect?.() })
      // Sibling hit region: opening the menu never dispatches the report button.
      Column() { this.accessory() }.position({ right: AISkinSpacing.medium,
        top: AISkinSpacing.medium + (AISkinProductTokens.titleLineHeight - AISkinLayout.tap) / 2 })
    }.width('100%')
  }
}
