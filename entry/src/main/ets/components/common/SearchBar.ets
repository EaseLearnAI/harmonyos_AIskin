import { AISkinColor } from '../../design/AISkinTheme'
@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索护肤品或成分'
  @State searchQuery: string = ''

  build() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .fontColor(AISkinColor.secondary)
        .margin({ left: 16 })

      TextInput({ placeholder: this.placeholder, text: this.searchQuery })
        .layoutWeight(1)
        .height(44)
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .borderRadius(22)
        .padding({ left: 12, right: 16 })
        .fontSize(14)
        .fontColor(AISkinColor.text)
        .placeholderColor(AISkinColor.secondary)
        .onChange((value: string) => {
          this.searchQuery = value
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 0, right: 16, top: 8, bottom: 8 })
  }
}
