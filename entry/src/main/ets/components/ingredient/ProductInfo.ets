import { TextStyle } from '../../design/AISkinTheme'
import { AISkinSpacing, AISkinTextRole, AISkinTone } from '../../design/Foundation/AISkinTokens'
import { ProductThumbnail, ProductThumbnailSize } from '../../design/AISkinProductThumbnail'
@Component
export struct ProductInfo {
  @Prop product: ProductData = {}
  build() {
    Row({ space: AISkinSpacing.medium }) {
      ProductThumbnail({ url: this.product.imageUrl || '', thumbnailSize: ProductThumbnailSize.Report })
      Column({ space: AISkinSpacing.xSmall }) {
        Text([this.product.label, '成分报告'].filter(value => !!value).join(' · ')).attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Secondary))
        Text(this.product.name || '未命名产品').attributeModifier(new TextStyle(AISkinTextRole.ScreenTitle)).width('100%')
        Text('分析已完成').attributeModifier(new TextStyle(AISkinTextRole.Caption, AISkinTone.Accent))
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%').padding({ top: AISkinSpacing.small })
  }
}
export interface ProductData { name?: string; description?: string; imageUrl?: string; label?: string; openingDate?: string; openingStatus?: string; ingredients?: string[] }
