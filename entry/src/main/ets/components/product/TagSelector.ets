import { TextStyle } from '../../design/AISkinTheme'
import { AISkinButton, AISkinField, AISkinTag } from '../../design/AISkinPrimitives'
import { AISkinButtonVariant, AISkinFieldVariant, AISkinSpacing, AISkinTagState, AISkinTagVariant, AISkinTextRole, AISkinTone } from '../../design/Foundation/AISkinTokens'
import { CategoryItem, PRODUCT_CATEGORIES } from './ProductList'
export interface TagSelectorData { name?: string; tag: string; openingStatus: string; openingDate: string }
@Component
export struct TagSelector {
  @Prop title: string = '保存分析结果'
  @Prop initialName: string = ''
  @Prop initialTag: string = ''
  @Prop initialDate: string = ''
  @Prop initialOpeningStatus: string = 'unknown'
  @State productName: string = ''
  @State selectedTag: string = ''
  @State openingStatus: string = 'unknown'
  @State selectedDate: Date = new Date()
  onCancel?: () => void
  onConfirm?: (data: TagSelectorData) => void
  aboutToAppear() {
    this.productName = this.initialName
    this.selectedTag = this.initialTag
    this.openingStatus = this.initialOpeningStatus || (this.initialDate ? 'opened' : 'unknown')
    const initial = this.initialDate ? new Date(this.initialDate) : new Date()
    this.selectedDate = Number.isNaN(initial.getTime()) ? new Date() : initial
  }
  build() {
    Column({ space: AISkinSpacing.large }) {
      Text(this.title).attributeModifier(new TextStyle(AISkinTextRole.ScreenTitle))
      AISkinField({ value: this.productName, placeholder: '产品名称', variant: AISkinFieldVariant.Form, onChange: (value: string) => { this.productName = value.slice(0, 100) } })
      Row({ space: AISkinSpacing.xSmall }) {
        this.statusButton('未记录', 'unknown')
        this.statusButton('未开封', 'unopened')
        this.statusButton('已开封', 'opened')
      }.width('100%')
      if (this.openingStatus === 'opened') {
        Text('开封日期').attributeModifier(new TextStyle(AISkinTextRole.CardTitle)).width('100%')
        DatePicker({ start: new Date('1970-01-01'), selected: this.selectedDate, end: new Date() })
          .onChange((value: DatePickerResult) => { this.selectedDate = new Date(value.year || this.selectedDate.getFullYear(), value.month ?? this.selectedDate.getMonth(), value.day || this.selectedDate.getDate()) }).width('100%')
      }
      Text('选择产品类型').attributeModifier(new TextStyle(AISkinTextRole.CardTitle)).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(PRODUCT_CATEGORIES, (category: CategoryItem) => {
          AISkinTag({ title: category.name, tone: AISkinTone.Accent, state: this.selectedTag === category.id ? AISkinTagState.Selected : AISkinTagState.Normal, variant: AISkinTagVariant.SelectionPill, onAction: () => { this.selectedTag = category.id } }).margin({ right: AISkinSpacing.xSmall, bottom: AISkinSpacing.xSmall })
        })
      }.width('100%')
      Row({ space: AISkinSpacing.xSmall }) {
        AISkinButton({ title: '取消', variant: AISkinButtonVariant.Secondary, onAction: (): void => { this.onCancel?.() } }).layoutWeight(1)
        AISkinButton({ title: '保存', isEnabled: this.productName.trim().length > 0, onAction: (): void => { this.confirmSelection() } }).layoutWeight(1)
      }.width('100%')
    }.width('100%').padding(AISkinSpacing.screenEdge)
  }
  @Builder
  statusButton(title: string, value: string) {
    AISkinTag({ title, tone: AISkinTone.Accent, state: this.openingStatus === value ? AISkinTagState.Selected : AISkinTagState.Normal, variant: AISkinTagVariant.SelectionCell, onAction: () => { this.openingStatus = value } }).layoutWeight(1)
  }
  confirmSelection() {
    if (!this.productName.trim()) return
    this.onConfirm?.({ name: this.productName.trim(), tag: this.selectedTag, openingStatus: this.openingStatus, openingDate: this.openingStatus === 'opened' ? this.selectedDate.toISOString() : '' })
  }
}
