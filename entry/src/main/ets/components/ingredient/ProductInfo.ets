@Component
export struct ProductInfo {
  @Prop product: ProductData = {
    name: '',
    description: '',
    imageUrl: '',
    label: '',
    openingDate: ''
  }
  @State isFavorite: boolean = false
  onToggleFavorite?: (isFavorite: boolean) => void

  build() {
    Column() {
      Row() {
        // Product Image
        Image(this.product.imageUrl || 'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=200')
          .width(96)
          .height(96)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .alt('产品图片')

        Blank()

        // Product Details
        Column() {
          Text(this.product.name || '未命名产品')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 12 })

          // Product Tags
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            Text('✓ 温和配方')
              .fontSize(12)
              .fontColor('#388e3c')
              .backgroundColor('#e8f5e9')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8, bottom: 8 })

            Text('💧 弱酸性')
              .fontSize(12)
              .fontColor('#1976d2')
              .backgroundColor('#e3f2fd')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8, bottom: 8 })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(255, 182, 193, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }
}

// Data Models
export interface ProductData {
  name?: string
  description?: string
  imageUrl?: string
  label?: string
  openingDate?: string
}

