import { AISkinReportTokens } from './Foundation/AISkinReportTokens'
import { AISkinColor } from './AISkinTheme'
import { AISkinIcon } from './AISkinIcon'
import { AISkinLayout, AISkinRadius } from './Foundation/AISkinTokens'
export enum ProductThumbnailSize { Cabinet, Report }
@Component
export struct ProductThumbnail {
  @Prop @Watch('resetImageState') url: string = ''
  @Prop thumbnailSize: ProductThumbnailSize = ProductThumbnailSize.Cabinet
  @State imageFailed: boolean = false
  @State imageLoading: boolean = false
  aboutToAppear(): void { this.resetImageState() }
  resetImageState(): void { this.imageFailed = false; this.imageLoading = this.url.length > 0 }
  build() {
    Stack() {
      if (this.url && !this.imageFailed) {
        Image(this.url).width('100%').height('100%').objectFit(ImageFit.Cover)
          .onComplete((): void => { this.imageLoading = false })
          .onError((): void => { this.imageFailed = true; this.imageLoading = false })
      } else {
        AISkinIcon({ name: this.thumbnailSize === ProductThumbnailSize.Report ? 'drop' : 'cabinet', iconSize: AISkinLayout.iconSize, selected: true })
      }
      if (this.imageLoading) { LoadingProgress().width(AISkinLayout.iconSize).height(AISkinLayout.iconSize).color(AISkinColor.accent) }
    }.width(this.thumbnailSize === ProductThumbnailSize.Cabinet ? AISkinLayout.productThumbnailCabinet : AISkinReportTokens.thumbnailWidth)
      .height(this.thumbnailSize === ProductThumbnailSize.Cabinet ? AISkinLayout.productThumbnailCabinet : AISkinReportTokens.thumbnailHeight)
      .borderRadius(this.thumbnailSize === ProductThumbnailSize.Cabinet ? AISkinRadius.medium : AISkinReportTokens.thumbnailRadius).clip(true)
      .backgroundColor(this.thumbnailSize === ProductThumbnailSize.Report ? AISkinColor.surface : AISkinColor.muted)
      .border({ width: this.thumbnailSize === ProductThumbnailSize.Report ? AISkinLayout.hairline : 0, color: AISkinColor.border })
      .accessibilityText('产品图片').accessibilityLevel(this.thumbnailSize === ProductThumbnailSize.Report ? 'yes' : 'no')
  }
}
