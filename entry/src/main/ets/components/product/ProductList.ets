import { AISkinColor, CardStyle, TextStyle } from '../../design/AISkinTheme'
import { AISkinButton, AISkinIconButton, AISkinStateView, AISkinTabs } from '../../design/AISkinPrimitives'
import { AISkinButtonLayout, AISkinButtonVariant, AISkinCardInset, AISkinCardRole, AISkinCardState, AISkinLayout, AISkinSpacing, AISkinStateKind, AISkinTabVariant, AISkinTextRole, AISkinTone } from '../../design/Foundation/AISkinTokens'
import { AISkinProductTokens } from '../../design/Foundation/AISkinProductTokens'
import { AISkinProductRow } from '../../design/AISkinProductRow'
import { AIContentNotice } from '../common/AIContentNotice'
export const PRODUCT_CATEGORIES: CategoryItem[] = [
  { id: '洁面', name: '洁面' }, { id: '精华', name: '精华' }, { id: '面膜', name: '面膜' }, { id: '防晒', name: '防晒' },
  { id: '面霜', name: '面霜' }, { id: '爽肤水', name: '爽肤水' }, { id: '乳液', name: '乳液' }, { id: '眼霜', name: '眼霜' }, { id: '其他', name: '其他' }
]
const CABINET_CATEGORIES: CategoryItem[] = [
  { id: 'all', name: '全部' }, { id: '精华', name: '精华' }, { id: '面霜', name: '面霜' }, { id: '防晒', name: '防晒' }, { id: '洁面', name: '洁面' }
]
@Component
export struct ProductList {
  @Prop products: ProductItem[] = []
  @Prop selectionMode: boolean = false
  @Prop selectedProductIds: string[] = []
  @Prop categories: CategoryItem[] = CABINET_CATEGORIES
  @State selectedCategoryIndex: number = 0
  onSelectProduct?: (product: ProductItem) => void
  onToggleSelection?: (productId: string) => void
  onDeleteProduct?: (productId: string) => void
  onEditProduct?: (product: ProductItem) => void
  onBeginConflict?: (productId?: string) => void
  onCancelConflict?: () => void
  onAddProduct?: () => void
  build() {
    Scroll() {
      Column({ space: AISkinSpacing.xxSmall }) {
        AISkinTabs({ items: this.categories.map((category: CategoryItem) => category.name), selection: this.selectedCategoryIndex,
          variant: AISkinTabVariant.Underline, regular: true, onSelect: (index: number): void => { this.selectedCategoryIndex = index } })
        Divider().color(AISkinColor.divider)
        Row() {
          Text(this.selectionMode ? `已选 ${this.selectedProductIds.length} 件` : `共 ${this.getFilteredProducts().length} 件`)
            .attributeModifier(new TextStyle(AISkinTextRole.Callout, AISkinTone.Secondary)).layoutWeight(1)
          AISkinButton({ title: this.selectionMode ? '取消检测' : '冲突检测', icon: 'layers', textRole: AISkinTextRole.Callout,
            tone: AISkinTone.Secondary, variant: AISkinButtonVariant.Plain, layout: AISkinButtonLayout.Compact,
            onAction: (): void => { if (this.selectionMode) this.onCancelConflict?.(); else this.onBeginConflict?.() } })
        }.width('100%').constraintSize({ minHeight: AISkinLayout.regularUnderlineHeight }).padding({ bottom: AISkinSpacing.xSmall })
        if (this.getFilteredProducts().length === 0) {
          Column() {
            AISkinStateView({ title: this.categoryId() === 'all' ? '还没有护肤产品' : `还没有${this.categoryId()}产品`,
              message: `添加你的${this.categoryId() === 'all' ? '护肤' : this.categoryId()}产品，查看成分分析与搭配建议。`, kind: AISkinStateKind.Empty })
            AISkinButton({ title: this.categoryId() === 'all' ? '添加产品' : `添加${this.categoryId()}产品`, onAction: this.onAddProduct })
          }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content, AISkinCardState.Normal, AISkinCardInset.Regular))
        } else {
          Column({ space: AISkinSpacing.small }) {
            ForEach(this.getFilteredProducts(), (product: ProductItem) => { this.ProductCard(product) })
            AIContentNotice({ scene: '产品分析摘要' })
          }.width('100%')
        }
      }.width('100%').padding({ left: AISkinSpacing.screenEdge, right: AISkinSpacing.screenEdge, top: AISkinSpacing.xxSmall, bottom: AISkinSpacing.xxLarge })
    }.width('100%').height('100%').scrollBar(BarState.Off).align(Alignment.Top)
  }
  private categoryId(): string { return this.categories[this.selectedCategoryIndex]?.id || 'all' }
  getFilteredProducts(): ProductItem[] { return this.categoryId() === 'all' ? this.products : this.products.filter(product => product.label === this.categoryId()) }
  private select(product: ProductItem): void {
    if (this.selectionMode && product.id) this.onToggleSelection?.(product.id)
    else this.onSelectProduct?.(product)
  }
  @Builder
  ProductCard(product: ProductItem) {
    Column() {
      AISkinProductRow({ title: product.name || '未命名产品', summary: product.description || '', category: product.label || '', imageUrl: product.imageUrl || '',
        accessibilityValue: this.selectionMode ? this.selectedProductIds.includes(product.id || '') ? '已选择' : '未选择' : '查看成分分析',
        onSelect: (): void => { this.select(product) }, accessory: () => { this.ProductAccessory(product) } })
    }.width('100%').attributeModifier(new CardStyle(AISkinCardRole.Content,
      this.selectionMode && this.selectedProductIds.includes(product.id || '') ? AISkinCardState.Selected : AISkinCardState.Normal, AISkinCardInset.None))
  }
  @Builder
  ProductAccessory(product: ProductItem) {
    if (this.selectionMode) {
      AISkinIconButton({ name: this.selectedProductIds.includes(product.id || '') ? 'checkCircle' : 'circle',
        label: `${this.selectedProductIds.includes(product.id || '') ? '取消选择' : '选择'}${product.name || '产品'}`,
        tone: this.selectedProductIds.includes(product.id || '') ? AISkinTone.Accent : AISkinTone.Secondary,
        variant: AISkinButtonVariant.Plain, onAction: (): void => { this.select(product) } })
    } else {
      AISkinIconButton({ name: 'ellipsis', label: `更多产品操作，${product.name || '产品'}`, tone: AISkinTone.Secondary,
        iconSize: AISkinProductTokens.menuIconSize, variant: AISkinButtonVariant.Plain, menuItems: [
          { value: '编辑产品', action: (): void => { this.onEditProduct?.(product) } },
          { value: '冲突检测', action: (): void => { this.onBeginConflict?.(product.id) } },
          { value: '删除产品', action: (): void => { if (product.id) this.onDeleteProduct?.(product.id) } }
        ] })
    }
  }
}
export interface ProductItem { id?: string; name?: string; description?: string; imageUrl?: string; label?: string; safetyScore?: number; efficacyScore?: number; overallRating?: number; openingStatus?: string; openingDate?: string }
export interface CategoryItem { id: string; name: string }
