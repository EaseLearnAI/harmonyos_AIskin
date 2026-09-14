import { AISkinColor } from '../../design/AISkinTheme'
@Component
export struct ImageUploader {
  @State selectedImage: string | null = null
  @State isLoading: boolean = false
  @Prop placeholder: string = '点击选择图片'
  @Prop imagePath: string | null = null
  onImageSelected?: (image: string) => void
  onImageRemoved?: () => void
  onSelectImage?: () => void

  aboutToAppear() {
    console.log(`===== 🖼️ ImageUploader aboutToAppear =====`)
    // 如果传入了图片路径，使用它
    if (this.imagePath) {
      this.selectedImage = this.imagePath
      console.log('✅ 已设置待上传图片')
    }
  }

  aboutToUpdate() {
    // 如果传入了新的图片路径，更新显示
    if (this.imagePath && this.imagePath !== this.selectedImage) {
      console.log(`===== 🔄 ImageUploader 更新图片 =====`)
      this.selectedImage = this.imagePath
      console.log('✅ 已更新待上传图片')
    } else if (!this.imagePath && this.selectedImage) {
      // 如果图片路径被清空，也清空显示
      console.log(`🗑️ 清空图片显示`)
      this.selectedImage = null
    }
  }

  build() {
    Column() {
      if (!this.selectedImage && !this.isLoading) {
        this.UploadPlaceholder()
      } else if (this.isLoading) {
        this.LoadingState()
      } else {
        this.PreviewState()
      }
    }
    .width('100%')
  }

  @Builder
  UploadPlaceholder() {
    Column() {
      Column() {
        Image($r('app.media.product_capture')).width(140).height(140).objectFit(ImageFit.Contain)
      }
      .width(140)
      .height(140)
      .backgroundColor(Color.Transparent)
      .borderRadius(30)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Text(this.placeholder)
        .fontSize(15)
        .fontColor(AISkinColor.secondary)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(220)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AISkinColor.muted)
    .borderRadius(12)
    .border({
      width: 2,
      color: AISkinColor.divider,
      style: BorderStyle.Dashed
    })
    .onClick(() => {
      if (this.onSelectImage) {
        this.onSelectImage()
      } else {
        this.selectImage()
      }
    })
  }

  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(AISkinColor.accent)
        .margin({ bottom: 12 })

      Text('上传中...')
        .fontSize(15)
        .fontColor(AISkinColor.secondary)
    }
    .width('100%')
    .height(220)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AISkinColor.muted)
    .borderRadius(12)
  }

  @Builder
  PreviewState() {
    Stack() {
      Image(this.selectedImage || '')
        .width('100%')
        .height(270)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)

      Row() {
        Button() {
          Text('✕')
            .fontSize(16)
            .fontColor(AISkinColor.danger)
        }
        .type(ButtonType.Circle)
        .width(36)
        .height(36)
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .onClick(() => {
          this.removeImage()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ top: 12, right: 12 })
    }
    .width('100%')
  }

  selectImage() {
    // 如果提供了外部选择处理，使用它
    if (this.onSelectImage) {
      this.onSelectImage()
      return
    }
    
    // 否则使用默认行为（占位图片）
    this.isLoading = true
    setTimeout(() => {
      this.selectedImage = 'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=400'
      this.isLoading = false
      if (this.onImageSelected && this.selectedImage) {
        this.onImageSelected(this.selectedImage)
      }
    }, 1000)
  }

  removeImage() {
    this.selectedImage = null
    if (this.onImageRemoved) {
      this.onImageRemoved()
    }
  }
}
