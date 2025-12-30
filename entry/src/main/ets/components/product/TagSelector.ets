import { CategoryItem } from './ProductList'

export interface TagSelectorData {
  tag: string
  openingDate: string
}

@Component
export struct TagSelector {
  @Prop title: string = '保存分析结果'
  @Prop initialTag: string = ''
  @Prop initialDate: string = ''
  @State selectedTag: string = ''
  @State openingDate: string = ''
  @State selectedDate: Date | null = null
  onCancel?: () => void
  onConfirm?: (data: TagSelectorData) => void

  // Categories from ProductList
  private categories: CategoryItem[] = [
    { id: '洁面', name: '洁面', color: '#2196f3' },
    { id: '精华', name: '精华', color: '#ff9800' },
    { id: '面膜', name: '面膜', color: '#9c27b0' },
    { id: '防晒', name: '防晒', color: '#f44336' },
    { id: '面霜', name: '面霜', color: '#4caf50' },
    { id: '爽肤水', name: '爽肤水', color: '#03a9f4' },
    { id: '乳液', name: '乳液', color: '#8bc34a' },
    { id: '眼霜', name: '眼霜', color: '#673ab7' }
  ]

  aboutToAppear() {
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
      // Opening Date Section
      Column() {
        Text('开封日期')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
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
          console.log(`📋 选择的日期: ${year}-${month + 1}-${day}`)
          const selected = new Date(year, month, day)
          this.selectedDate = selected
          this.openingDate = this.formatDateForInput(selected)
          console.log(`✅ 日期已更新: ${this.openingDate}`)
        })
        .width('100%')
        .height(40)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 24 })

      // Tag Section
      Column() {
        Text('选择产品类型')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
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
            .fontColor(this.selectedTag === category.id ? Color.White : '#424242')
            .backgroundColor(this.selectedTag === category.id ? '#E1BEE7' : Color.White)
            .border({
              width: 1,
              color: this.selectedTag === category.id ? '#CE93D8' : '#e0e0e0',
              style: BorderStyle.Solid
            })
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(9999)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              console.log(`===== 🏷️ 选择标签 =====`)
              console.log(`📋 选择的标签: ${category.id}`)
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
          .backgroundColor(Color.White)
          .fontColor('#424242')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .border({
            width: 1,
            color: '#e0e0e0',
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

        Button('确认')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F48FB1')
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

  confirmSelection() {
    console.log('===== ✅ 确认保存 =====')
    console.log(`📋 选择的标签: ${this.selectedTag}`)
    console.log(`📋 选择的日期: ${this.openingDate}`)

    const data: TagSelectorData = {
      tag: this.selectedTag,
      openingDate: this.openingDate ? new Date(this.openingDate).toISOString() : ''
    }

    console.log(`📦 保存数据: ${JSON.stringify(data)}`)

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

