import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct ProductInfo {
  @Prop product: ProductData = {}
  build() {
    Row({ space: 16 }) {
      if (this.product.imageUrl) {
        Image(this.product.imageUrl).width(84).height(100).objectFit(ImageFit.Contain).borderRadius(16)
      } else {
        Image($r('app.media.product_capture')).width(84).height(100).objectFit(ImageFit.Contain).opacity(0.7)
      }
      Column({ space: 10 }) {
        Text(this.product.name || '未命名产品').fontSize(20).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
        if (this.product.label) { Text(this.product.label).fontSize(12).fontColor(AISkinColor.accent).padding(8).backgroundColor(AISkinColor.selected).borderRadius(12) }
        Text(this.product.openingStatus === 'unopened' ? '未开封' : this.product.openingDate ? `开封于 ${new Date(this.product.openingDate).toLocaleDateString()}` : '未记录开封日期').fontSize(12).fontColor(AISkinColor.secondary)
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%').padding(20).attributeModifier(new CardStyle()).margin({ bottom: 16 })
  }
}
export interface ProductData { name?: string; description?: string; imageUrl?: string; label?: string; openingDate?: string; openingStatus?: string; ingredients?: string[] }
