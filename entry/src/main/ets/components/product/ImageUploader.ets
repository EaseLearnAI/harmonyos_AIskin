import { AISkinButton, AISkinStateView } from '../../design/AISkinPrimitives'
import { AISkinButtonVariant, AISkinSpacing, AISkinStateKind } from '../../design/Foundation/AISkinTokens'
import { ProductThumbnail, ProductThumbnailSize } from '../../design/AISkinProductThumbnail'
/** A controlled image input. Only an actual picker result supplies imagePath. */
@Component
export struct ImageUploader {
  @Prop placeholder: string = '选择产品图片'
  @Prop imagePath: string | null = null
  onImageSelected?: (image: string) => void
  onImageRemoved?: () => void
  onSelectImage?: () => void
  build() {
    Column({ space: AISkinSpacing.medium }) {
      if (this.imagePath) {
        ProductThumbnail({ url: this.imagePath, thumbnailSize: ProductThumbnailSize.Report })
        AISkinButton({ title: '移除图片', variant: AISkinButtonVariant.Secondary, onAction: this.onImageRemoved })
      } else {
        AISkinStateView({ title: '添加成分表照片', message: '请选择实际产品的清晰成分表。', kind: AISkinStateKind.Empty })
      }
      AISkinButton({ title: this.placeholder, isEnabled: this.onSelectImage !== undefined, onAction: this.onSelectImage })
    }.width('100%')
  }
}
