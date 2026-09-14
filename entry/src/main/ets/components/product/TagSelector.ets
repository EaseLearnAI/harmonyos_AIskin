import { AISkinColor } from '../../design/AISkinTheme'
import { CategoryItem } from './ProductList'

export interface TagSelectorData {
  name?: string
  tag: string
  openingStatus: string
  openingDate: string
}

@Component
export struct TagSelector {
  @Prop title: string = '保存分析结果'
  @Prop initialName: string = ''
  @State productName: string = ''
  @Prop initialTag: string = ''
  @Prop initialDate: string = ''
  @State selectedTag: string = ''
  @Prop initialOpeningStatus: string = 'unknown'
  @State openingStatus: string = 'unknown'
  @State openingDate: string = ''
  @State selectedDate: Date | null = null
  onCancel?: () => void
  onConfirm?: (data: TagSelectorData) => void

  // Categories from ProductList
  private categories: CategoryItem[] = [
    { id: '洁面', name: '洁面', color: AISkinColor.selected },
    { id: '精华', name: '精华', color: AISkinColor.warning },
    { id: '面膜', name: '面膜', color: AISkinColor.accent },
    { id: '防晒', name: '防晒', color: AISkinColor.danger },
    { id: '面霜', name: '面霜', color: AISkinColor.success },
    { id: '爽肤水', name: '爽肤水', color: '#03a9f4' },
    { id: '乳液', name: '乳液', color: '#8bc34a' },
    { id: '眼霜', name: '眼霜', color: '#673ab7' }
  ]

  aboutToAppear() {
    this.productName = this.initialName
    this.openingStatus = this.initialOpeningStatus || (this.initialDate ? 'opened' : 'unknown')
    this.selectedTag = this.initialTag || ''
    if (this.initialDate) {
      this.openingDate = this.initialDate
      try {
        this.selectedDate = new Date(this.initialDate)
      } catch (e) {
        this.selectedDate = new Date()
      }
    } else {
      const today = new Date()
      this.selectedDate = today
      this.openingDate = this.formatDateForInput(today)
    }
  }

  build() {
    Column() {
      Text(this.title).fontSize(20).fontColor(AISkinColor.text).margin({ bottom: 20 })
      TextInput({ text: this.productName, placeholder: '产品名称' }).fontColor(AISkinColor.text).placeholderColor(AISkinColor.secondary).backgroundColor(AISkinColor.muted).height(48).maxLength(100).onChange((value: string) => { this.productName = value }).margin({ bottom: 20 })
      Row({ space: 8 }) {
        this.statusButton('未记录', 'unknown')
        this.statusButton('未开封', 'unopened')
        this.statusButton('已开封', 'opened')
      }.width('100%').margin({ bottom: 16 })
      // Opening Date Section
      if (this.openingStatus === 'opened') {
      Column() {
        Text('开封日期')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 12 })

        DatePicker({
          start: new Date('1970-01-01'),
          selected: this.selectedDate || new Date(),
          end: new Date()
        })
        .onChange((value: DatePickerResult) => {
          console.log(`===== 📅 日期选择变更 =====`)
          const year = value.year || new Date().getFullYear()
          const month = value.month !== undefined ? value.month : new Date().getMonth()
          const day = value.day || new Date().getDate()
          const selected = new Date(year, month, day)
          this.selectedDate = selected
          this.openingDate = this.formatDateForInput(selected)
          console.log('✅ 日期已更新')
        })
        .width('100%')
        .height(40)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 24 })

      }
      // Tag Section
      Column() {
        Text('选择产品类型')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AISkinColor.text)
          .margin({ bottom: 12 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
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
                    .fontSize(14)
                }
              } else {
                Text(category.name)
                  .fontSize(14)
              }
            }
            .fontSize(14)
            .fontColor(this.selectedTag === category.id ? Color.White : AISkinColor.text)
            .backgroundColor(this.selectedTag === category.id ? AISkinColor.primary : AISkinColor.elevated)
            .border({
              width: 1,
              color: this.selectedTag === category.id ? AISkinColor.accent : AISkinColor.divider,
              style: BorderStyle.Solid
            })
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(9999)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              console.log(`===== 🏷️ 选择标签 =====`)
              this.selectedTag = category.id
              console.log(`✅ 标签已更新`)
            })
          })
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 24 })

      // Action Buttons
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(AISkinColor.surface)
          .fontColor(AISkinColor.text)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .border({
            width: 1,
            color: AISkinColor.divider,
            style: BorderStyle.Solid
          })
          .borderRadius(8)
          .margin({ right: 8 })
          .onClick(() => {
            console.log('===== ❌ 取消保存 =====')
            if (this.onCancel) {
              this.onCancel()
            }
          })

        Button('保存').enabled(this.productName.trim().length > 0)
          .layoutWeight(1)
          .height(44)
          .backgroundColor(AISkinColor.primary)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(8)
          .onClick(() => {
            this.confirmSelection()
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }

  @Builder
  statusButton(label: string, value: string) {
    Button(label).height(44).layoutWeight(1).fontColor(this.openingStatus === value ? Color.White : AISkinColor.text)
      .backgroundColor(this.openingStatus === value ? AISkinColor.primary : AISkinColor.muted).onClick(() => { this.openingStatus = value })
  }

  confirmSelection() {
    console.log('===== ✅ 确认保存 =====')

    if (!this.productName.trim()) { return }
    const data: TagSelectorData = {
      name: this.productName.trim(),
      tag: this.selectedTag,
      openingStatus: this.openingStatus,
      openingDate: this.openingStatus === 'opened' && this.openingDate ? new Date(this.openingDate).toISOString() : ''
    }

    if (this.onConfirm) {
      this.onConfirm(data)
    }
  }

  formatDateForInput(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
