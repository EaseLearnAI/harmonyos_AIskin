import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct DocumentModal {
  @Prop show: boolean = false
  @Prop title: string = ''
  @Prop content: string = ''
  onClose?: () => void

  build() {
    if (this.show) {
      // 使用全屏覆盖的 Stack，确保覆盖整个屏幕并居中
      Stack({ alignContent: Alignment.Center }) {
        // Backdrop - 全屏半透明背景，覆盖整个屏幕
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(AISkinColor.scrim)
          .onClick(() => {
            if (this.onClose) {
              this.onClose()
            }
          })

        // Modal Content - 居中显示的白色卡片
        Column() {
          // Header
          Row() {
            Text(this.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(AISkinColor.text)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button() {
              Text('✕')
                .fontSize(18)
                .fontColor(AISkinColor.secondary)
            }
            .type(ButtonType.Circle)
            .width(32)
            .height(32)
            .backgroundColor(AISkinColor.muted)
            .onClick(() => {
              if (this.onClose) {
                this.onClose()
              }
            })
          }
          .width('100%')
          .padding({ top: 16, bottom: 12, left: 20, right: 20 })
          .border({
            width: { bottom: 1 },
            color: AISkinColor.divider,
            style: BorderStyle.Solid
          })

          // Content - Scrollable
          Scroll() {
            Column() {
              // Parse and render markdown-like content
              this.renderContent(this.content)
            }
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 20, right: 20 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('90%')
        .height('80%')
        
        .constraintSize({ maxWidth: 500, maxHeight: '85%', minHeight: 300 })
        .attributeModifier(new CardStyle())
        .onClick(() => {
          // Prevent backdrop click from closing when clicking modal content
        })
      }
      .width('100%')
      .height('100%')
      .zIndex(10000)
    }
  }

  // 格式化内容的方法
  private formatContent(content: string): string {
    if (!content) {
      return '内容加载中...'
    }

    // 简化实现：直接显示格式化后的文本
    // 移除 markdown 标记，保留基本格式
    return content
      .replace(/#{1,3}\s*\*\*(.+?)\*\*/g, '$1') // 移除标题的 ** 标记
      .replace(/\*\*(.+?)\*\*/g, '$1') // 移除其他 ** 标记
      .replace(/^#\s+/gm, '') // 移除一级标题标记
      .replace(/^##\s+/gm, '') // 移除二级标题标记
      .replace(/^###\s+/gm, '') // 移除三级标题标记
      .replace(/^-\s+/gm, '• ') // 将 - 转换为 •
      .replace(/^\d+\.\s+/gm, '') // 移除数字列表标记（保留内容）
      .replace(/^---$/gm, '') // 移除分隔线
  }

  @Builder
  renderContent(content: string) {
    Text(this.formatContent(content))
      .fontSize(14)
      .fontColor(AISkinColor.secondary)
      .lineHeight(24)
      .width('100%')
      .textAlign(TextAlign.Start)
  }
}

