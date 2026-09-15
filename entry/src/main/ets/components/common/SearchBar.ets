import { AISkinField } from '../../design/AISkinPrimitives'
@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索护肤品或成分'
  @State searchQuery: string = ''
  onChange?: (value: string) => void
  build() {
    AISkinField({ value: this.searchQuery, placeholder: this.placeholder,
      onChange: (value: string) => { this.searchQuery = value; this.onChange?.(value) } })
  }
}
