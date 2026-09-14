import { AISkinColor } from '../../design/AISkinTheme'
@Component
export struct ProductList {
  @Prop products: ProductItem[] = []
  @Prop selectionMode: boolean = false
  @Prop selectedProductIds: string[] = []
  @Prop categories: CategoryItem[] = [
    { id: 'all', name: '全部产品' },
    { id: '洁面', name: '洁面', color: AISkinColor.selected },
    { id: '精华', name: '精华', color: AISkinColor.warning },
    { id: '面膜', name: '面膜', color: AISkinColor.accent },
    { id: '防晒', name: '防晒', color: AISkinColor.danger },
    { id: '面霜', name: '面霜', color: AISkinColor.success },
    { id: '爽肤水', name: '爽肤水', color: '#03a9f4' },
    { id: '乳液', name: '乳液', color: '#8bc34a' },
    { id: '眼霜', name: '眼霜', color: '#673ab7' }
  ]
  @State selectedCategory: string = 'all'
  onSelectProduct?: (product: ProductItem) => void
  onToggleSelection?: (productId: string) => void
  onDeleteProduct?: (productId: string) => void

  build() {
    Column() {
      // Category Filters
      Scroll() {
        Row() {
          ForEach(this.categories, (category: CategoryItem) => {
            Button(category.name) {
              if (category.color) {
                Row() {
                  Column() {
                    Text('●')
                      .fontSize(8)
                      .fontColor(category.color)
                  }
                  .width(8)
                  .height(8)
                  .margin({ right: 4 })
                  .justifyContent(FlexAlign.Center)

                  Text(category.name)
                    .fontSize(12)
                }
              } else {
                Text(category.name)
                  .fontSize(12)
              }
            }
            .fontSize(12)
            .fontColor(this.selectedCategory === category.id ? Color.White : AISkinColor.secondary)
            .backgroundColor(this.selectedCategory === category.id ? AISkinColor.primary : AISkinColor.elevated)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(9999)
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedCategory = category.id
            })
          })
        }
        .padding({ left: 16, right: 16, top: 0, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 12 })

      // Product List
      if (this.getFilteredProducts().length === 0) {
        this.EmptyState()
      } else {
        List() {
          ForEach(this.getFilteredProducts(), (product: ProductItem) => {
            ListItem() {
              this.ProductCard(product)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: AISkinColor.muted, startMargin: 16, endMargin: 16 })
        .padding({ left: 24, right: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: 80 })
  }

  getFilteredProducts(): ProductItem[] {
    if (this.selectedCategory === 'all') {
      return this.products
    }
    return this.products.filter(product => product.label === this.selectedCategory)
  }

  @Builder
  ProductCard(product: ProductItem) {
    Row() {
      if (this.selectionMode) {
        Checkbox()
          .select(this.selectedProductIds.includes(product.id || ''))
          .onChange((checked: boolean) => {
            if (this.onToggleSelection && product.id) {
              this.onToggleSelection(product.id)
            }
          })
          .margin({ right: 12 })
      }

      Image(product.imageUrl || $r('app.media.product_capture'))
        .width(64)
        .height(64)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .alt('产品图片')

      Blank()

      Column() {
        Row() {
          Text(product.name || '未命名产品')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(AISkinColor.text)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (product.safetyScore) {
            Text(`${product.safetyScore}`)
              .fontSize(12)
              .fontColor(this.getSafetyColor(product.safetyScore))
              .backgroundColor(this.getSafetyBgColor(product.safetyScore))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 8 })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(product.description || '暂无描述')
          .fontSize(13)
          .fontColor(AISkinColor.secondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4, bottom: 8 })

        Row() {
          if (product.label) {
            Text(product.label)
              .fontSize(11)
              .fontColor(AISkinColor.accent)
              .backgroundColor(AISkinColor.selected)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 8 })
          }

          if (product.efficacyScore) {
            Text(`功效 ${product.efficacyScore}`)
              .fontSize(11)
              .fontColor(AISkinColor.warning)
              .backgroundColor(AISkinColor.warningSurface)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 8 })
          }

          if (product.openingStatus === 'unopened') { Text('未开封').fontSize(11).fontColor(AISkinColor.secondary) }
          if (product.openingDate) {
            Text(this.formatDate(product.openingDate))
              .fontSize(11)
              .fontColor(AISkinColor.secondary)
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .margin({ bottom: 12 }).borderRadius(24)
    .backgroundColor(AISkinColor.surface)
    .onClick(() => {
      if (!this.selectionMode && this.onSelectProduct) {
        this.onSelectProduct(product)
      }
    })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('📦')
        .fontSize(48)
        .margin({ bottom: 16 })

      Text('暂无产品')
        .fontSize(16)
        .fontColor(AISkinColor.secondary)
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  getSafetyColor(score: number): ResourceColor {
    if (score >= 90) return AISkinColor.success
    if (score >= 70) return AISkinColor.warning
    return AISkinColor.danger
  }

  getSafetyBgColor(score: number): ResourceColor {
    if (score >= 90) return AISkinColor.successSurface
    if (score >= 70) return AISkinColor.warningSurface
    return AISkinColor.dangerSurface
  }

  formatDate(dateString: string): string {
    try {
      const date = new Date(dateString)
      return `${date.getMonth() + 1}-${date.getDate()}`
    } catch (e) {
      return dateString
    }
  }
}

// Data Models
export interface ProductItem {
  id?: string
  name?: string
  description?: string
  imageUrl?: string
  label?: string
  safetyScore?: number
  efficacyScore?: number
  overallRating?: number
  openingStatus?: string
  openingDate?: string
}

export interface CategoryItem {
  id: string
  name: string
  color?: ResourceColor
}
