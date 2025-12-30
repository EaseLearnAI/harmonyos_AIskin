@Component
export struct ProductList {
  @Prop products: ProductItem[] = []
  @Prop selectionMode: boolean = false
  @Prop selectedProductIds: string[] = []
  @Prop categories: CategoryItem[] = [
    { id: 'all', name: '全部产品' },
    { id: '洁面', name: '洁面', color: '#2196f3' },
    { id: '精华', name: '精华', color: '#ff9800' },
    { id: '面膜', name: '面膜', color: '#9c27b0' },
    { id: '防晒', name: '防晒', color: '#f44336' },
    { id: '面霜', name: '面霜', color: '#4caf50' },
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
            .fontColor(this.selectedCategory === category.id ? Color.White : '#616161')
            .backgroundColor(this.selectedCategory === category.id ? '#F8BBD0' : Color.White)
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
        .divider({ strokeWidth: 1, color: '#f0f0f0', startMargin: 16, endMargin: 16 })
        .padding({ right: 20 })
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

      Image(product.imageUrl || 'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=200')
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
            .fontColor('#333333')
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
          .fontColor('#757575')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4, bottom: 8 })

        Row() {
          if (product.label) {
            Text(product.label)
              .fontSize(11)
              .fontColor('#1976d2')
              .backgroundColor('#e3f2fd')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 8 })
          }

          if (product.efficacyScore) {
            Text(`功效 ${product.efficacyScore}`)
              .fontSize(11)
              .fontColor('#e65100')
              .backgroundColor('#fff3e0')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 8 })
          }

          if (product.openingDate) {
            Text(this.formatDate(product.openingDate))
              .fontSize(11)
              .fontColor('#9e9e9e')
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
    .padding({ left: 16, top: 16, bottom: 16, right: 20 })
    .margin({ right: 20 })
    .backgroundColor(Color.White)
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
        .fontColor('#757575')
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  getSafetyColor(score: number): ResourceColor {
    if (score >= 90) return '#2e7d32'
    if (score >= 70) return '#ff8f00'
    return '#c62828'
  }

  getSafetyBgColor(score: number): ResourceColor {
    if (score >= 90) return '#c8e6c9'
    if (score >= 70) return '#fff9c4'
    return '#ffcdd2'
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
  openingDate?: string
}

export interface CategoryItem {
  id: string
  name: string
  color?: string
}

