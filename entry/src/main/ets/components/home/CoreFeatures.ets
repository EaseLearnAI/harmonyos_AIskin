@Component
export struct CoreFeatures {
  onNavigate?: (route: string, params?: ProductViewParams) => void
  onShowPersonalizedRoutineModal?: () => void

  build() {
    Column() {
      // Features Container
      Column() {
        // Section Header
        Row() {
          Text('核心功能')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1f2937')
        }
        .width('100%')
        .margin({ bottom: 16 })
        .alignItems(VerticalAlign.Center)

        // Features Grid
        Grid() {
          GridItem() {
            this.FeatureCard('01', '产品分析', 'AI智能解析成分', () => {
              // Navigate to product page
              if (this.onNavigate) {
                this.onNavigate('/product')
              }
            })
          }

          GridItem() {
            this.FeatureCard('02', '冲突检测', '避免产品成分冲突', () => {
              // Navigate to product page with conflict mode enabled
              if (this.onNavigate) {
                const params: ProductViewParams = {
                  autoEnableConflictMode: true
                }
                this.onNavigate('/product', params)
              }
            })
          }

          GridItem() {
            this.FeatureCard('03', '肌肤检测', 'AI智能皮肤分析', () => {
              // Navigate to skin analysis
              if (this.onNavigate) {
                this.onNavigate('/skinstatus')
              }
            })
          }

          GridItem() {
            this.FeatureCard('04', '个性化方案', 'AI定制护肤方案', () => {
              if (this.onShowPersonalizedRoutineModal) {
                this.onShowPersonalizedRoutineModal()
              }
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(16)
        .rowsGap(16)
        .width('100%')
        .height(304)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      .borderRadius(24)
      .border({
        width: 1,
        color: '#f3f4f6',
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 10
      })
      .margin({ left: 0, right: 0 })
    }
    .width('100%')
    .margin({ bottom: 0 })
  }

  @Builder
  FeatureCard(number: string, title: string, description: string, onClick: () => void) {
    Stack() {
      // Content
      Column() {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .margin({ bottom: 8 })

        Text(description)
          .fontSize(14)
          .fontColor('#6b7280')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, top: 16, right: 16, bottom: 16 })
      .zIndex(10)

      // Decorative Number container - positioned at bottom right
      Stack({ alignContent: Alignment.BottomEnd }) {
        Text(number)
          .fontSize(96)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getNumberColor(number))
          .opacity(1.0)
          .margin({ right: 8, bottom: 8 })
      }
      .width('100%')
      .height('100%')
      .zIndex(1)
    }
    .width('100%')
    .height(140)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({
      width: 1,
      color: '#f3f4f6',
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 3,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(onClick)
  }

  getNumberColor(number: string): ResourceColor {
    switch (number) {
      case '01':
        return '#fdf2f8'
      case '02':
        return '#faf5ff'
      case '03':
        return '#eff6ff'
      case '04':
        return '#f0fdf4'
      default:
        return '#fdf2f8'
    }
  }
}

// Data Models
interface ProductViewParams {
  autoEnableConflictMode?: boolean
}

