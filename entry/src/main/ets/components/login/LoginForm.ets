import { UserData } from '../../services/AuthService'

@Component
export struct LoginForm {
  @State phone: string = ''
  @State password: string = ''
  @State remember: boolean = false
  @State showPassword: boolean = false
  @State loading: boolean = false
  @State error: boolean = false
  @State errorMessage: string = ''
  @State validationErrors: ValidationErrors = {
    phone: '',
    password: ''
  }
  private isDestroyed: boolean = false

  onLoginSuccess?: (user: UserData) => void

  build() {
    Column() {
      // Error Message
      if (this.error) {
        Row() {
          Text('⚠️')
            .fontSize(16)
            .margin({ right: 8 })
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#b71c1c')
            .flexGrow(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#ffebee')
        .borderRadius(8)
        .margin({ bottom: 16 })
      }

      // Phone Input
      Column() {
        Row() {
          Text('📱')
            .fontSize(16)
            .margin({ right: 8 })
            .fontColor('#F8BBD0')
          Text('手机号')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
        }
        .width('100%')
        .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入手机号', text: this.phone })
          .type(InputType.PhoneNumber)
          .width('100%')
          .height(44)
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .backgroundColor('#fafafa')
          .borderRadius(8)
          .border({
            width: this.validationErrors.phone ? 1 : 0,
            color: this.validationErrors.phone ? '#f44336' : '#e0e0e0',
            style: BorderStyle.Solid
          })
          .onChange((value: string) => {
            this.phone = value
            this.validationErrors.phone = ''
            this.error = false
          })

        if (this.validationErrors.phone) {
          Text(this.validationErrors.phone)
            .fontSize(12)
            .fontColor('#f44336')
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Password Input
      Column() {
        Row() {
          Text('🔒')
            .fontSize(16)
            .margin({ right: 8 })
            .fontColor('#F8BBD0')
          Text('密码')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
        }
        .width('100%')
        .margin({ bottom: 8 })

        Stack({ alignContent: Alignment.TopEnd }) {
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .width('100%')
            .height(44)
            .padding({ left: 12, right: 48 })
            .fontSize(14)
            .backgroundColor('#fafafa')
            .borderRadius(8)
            .border({
              width: this.validationErrors.password ? 1 : 0,
              color: this.validationErrors.password ? '#f44336' : '#e0e0e0',
              style: BorderStyle.Solid
            })
            .onChange((value: string) => {
              this.password = value
              this.validationErrors.password = ''
              this.error = false
            })

          Button() {
            Text(this.showPassword ? '🙈' : '👁️')
              .fontSize(16)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .width(40)
          .height(44)
          .margin({ right: 4 })
          .onClick(() => {
            this.showPassword = !this.showPassword
          })
        }
        .width('100%')
        .height(44)

        if (this.validationErrors.password) {
          Text(this.validationErrors.password)
            .fontSize(12)
            .fontColor('#f44336')
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Form Actions
      Row() {
        Row() {
          Checkbox()
            .select(this.remember)
            .selectedColor('#F8BBD0')
            .onChange((checked: boolean) => {
              this.remember = checked
            })
          Text('记住我')
            .fontSize(14)
            .fontColor('#424242')
            .margin({ left: 8 })
        }
        .onClick(() => {
          this.remember = !this.remember
        })

        Blank()
      }
      .width('100%')
      .margin({ bottom: 24 })

      // Login Button
      Button() {
        if (this.loading) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(Color.White)
        } else {
          Text('登录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .height(44)
      .backgroundColor('#F8BBD0')
      .borderRadius(8)
      .enabled(!this.loading)
      .opacity(this.loading ? 0.7 : 1)
      .onClick(() => {
        this.handleLogin()
      })

      // Register Link
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#666666')
        Text('立即注册')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F8BBD0')
          .margin({ left: 4 })
          .onClick(() => {
            // TODO: Navigate to register page
            if (this.onNavigateToRegister) {
              this.onNavigateToRegister()
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: 'rgba(255, 182, 193, 0.15)',
      offsetX: 0,
      offsetY: 8
    })
  }

  onNavigateToRegister?: () => void

  validateForm(): boolean {
    let isValid = true
    this.validationErrors = {
      phone: '',
      password: ''
    }

    // Validate phone
    if (!this.phone) {
      this.validationErrors.phone = '请输入手机号'
      isValid = false
    } else if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      this.validationErrors.phone = '请输入有效的手机号'
      isValid = false
    }

    // Validate password
    if (!this.password) {
      this.validationErrors.password = '请输入密码'
      isValid = false
    }

    return isValid
  }

  async handleLogin() {
    if (!this.validateForm()) {
      return
    }

    if (this.isDestroyed) {
      return
    }

    this.loading = true
    this.error = false

    try {
      // 导入AuthService
      const authModule = await import('../../services/AuthService')
      const authService = authModule.AuthService.getInstance()

      // 调用真实的登录API
      const response = await authService.login({
        phone: this.phone,
        password: this.password,
        remember: this.remember
      })

      // 检查组件是否已被销毁
      if (this.isDestroyed) {
        return
      }

      if (response.success && response.user) {
        // 登录成功 - 先调用回调，再更新状态
        if (this.onLoginSuccess) {
          this.onLoginSuccess(response.user)
        }
        // 延迟更新状态，避免在组件销毁时更新
        setTimeout(() => {
          if (!this.isDestroyed) {
            this.loading = false
          }
        }, 100)
      } else {
        // 登录失败
        if (!this.isDestroyed) {
          this.error = true
          this.errorMessage = response.message || '登录失败，请重试'
          this.loading = false
        }
      }
    } catch (err) {
      if (!this.isDestroyed) {
        this.error = true
        const errorObj = err as Record<string, string>
        let errorMsg = '登录失败，请重试'
        if (errorObj && typeof errorObj === 'object') {
          const messageValue = errorObj['message']
          if (messageValue) {
            errorMsg = String(messageValue)
          }
        }
        this.errorMessage = errorMsg
        this.loading = false
        console.error('登录错误:', JSON.stringify(err))
      }
    }
  }

  aboutToDisappear() {
    this.isDestroyed = true
  }
}

// Data Models
interface ValidationErrors {
  phone?: string
  password?: string
}

