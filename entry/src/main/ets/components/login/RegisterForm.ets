import { UserData } from '../../services/AuthService'

@Component
export struct RegisterForm {
  @State name: string = ''
  @State phone: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State gender: 'male' | 'female' | '' = ''
  @State agreeTerms: boolean = false
  @State showPassword: boolean = false
  @State showConfirmPassword: boolean = false
  @State loading: boolean = false
  @State error: boolean = false
  @State errorMessage: string = ''
  @State validationErrors: ValidationErrors = {
    name: '',
    phone: '',
    password: '',
    confirmPassword: '',
    gender: '',
    agreeTerms: ''
  }

  onRegisterSuccess?: (user: UserData) => void
  onNavigateToLogin?: () => void
  onShowTerms?: () => void
  onShowPrivacy?: () => void

  build() {
    Stack() {
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

      // Name Input
      Column() {
        Row() {
          Text('👤')
            .fontSize(16)
            .margin({ right: 8 })
            .fontColor('#F8BBD0')
          Text('用户名')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
        }
        .width('100%')
        .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入用户名', text: this.name })
          .type(InputType.Normal)
          .width('100%')
          .height(44)
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .backgroundColor('#fafafa')
          .borderRadius(8)
          .border({
            width: this.validationErrors.name ? 1 : 0,
            color: this.validationErrors.name ? '#f44336' : '#e0e0e0',
            style: BorderStyle.Solid
          })
          .onChange((value: string) => {
            this.name = value
            this.validationErrors.name = ''
            this.error = false
          })

        if (this.validationErrors.name) {
          Text(this.validationErrors.name)
            .fontSize(12)
            .fontColor('#f44336')
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Gender Selection
      Column() {
        Row() {
          Text('⚧️')
            .fontSize(16)
            .margin({ right: 8 })
            .fontColor('#F8BBD0')
          Text('性别')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Button() {
            Text('👨 男生')
              .fontSize(14)
              .fontColor(this.gender === 'male' ? Color.White : '#424242')
          }
          .width('48%')
          .height(44)
          .backgroundColor(this.gender === 'male' ? '#F8BBD0' : '#fafafa')
          .borderRadius(8)
          .onClick(() => {
            this.gender = 'male'
            this.validationErrors.gender = ''
          })

          Button() {
            Text('👩 女生')
              .fontSize(14)
              .fontColor(this.gender === 'female' ? Color.White : '#424242')
          }
          .width('48%')
          .height(44)
          .backgroundColor(this.gender === 'female' ? '#F8BBD0' : '#fafafa')
          .borderRadius(8)
          .onClick(() => {
            this.gender = 'female'
            this.validationErrors.gender = ''
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.validationErrors.gender) {
          Text(this.validationErrors.gender)
            .fontSize(12)
            .fontColor('#f44336')
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

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
          TextInput({ placeholder: '请输入密码（至少6个字符）', text: this.password })
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

      // Confirm Password Input
      Column() {
        Row() {
          Text('🔒')
            .fontSize(16)
            .margin({ right: 8 })
            .fontColor('#F8BBD0')
          Text('确认密码')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#424242')
        }
        .width('100%')
        .margin({ bottom: 8 })

        Stack({ alignContent: Alignment.TopEnd }) {
          TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
            .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
            .width('100%')
            .height(44)
            .padding({ left: 12, right: 48 })
            .fontSize(14)
            .backgroundColor('#fafafa')
            .borderRadius(8)
            .border({
              width: this.validationErrors.confirmPassword ? 1 : 0,
              color: this.validationErrors.confirmPassword ? '#f44336' : '#e0e0e0',
              style: BorderStyle.Solid
            })
            .onChange((value: string) => {
              this.confirmPassword = value
              this.validationErrors.confirmPassword = ''
              this.error = false
            })

          Button() {
            Text(this.showConfirmPassword ? '🙈' : '👁️')
              .fontSize(16)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .width(40)
          .height(44)
          .margin({ right: 4 })
          .onClick(() => {
            this.showConfirmPassword = !this.showConfirmPassword
          })
        }
        .width('100%')
        .height(44)

        if (this.validationErrors.confirmPassword) {
          Text(this.validationErrors.confirmPassword)
            .fontSize(12)
            .fontColor('#f44336')
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Terms Agreement
      Row() {
        Checkbox()
          .select(this.agreeTerms)
          .selectedColor('#F8BBD0')
          .onChange((checked: boolean) => {
            this.agreeTerms = checked
            this.validationErrors.agreeTerms = ''
          })

        Column() {
          Row() {
            Text('我已阅读并同意')
              .fontSize(14)
              .fontColor('#424242')
            Text('使用条款')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F8BBD0')
              .onClick(() => {
                if (this.onShowTerms) {
                  this.onShowTerms()
                }
              })
          }
          Row() {
            Text('和')
              .fontSize(14)
              .fontColor('#424242')
            Text('隐私政策')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F8BBD0')
              .onClick(() => {
                if (this.onShowPrivacy) {
                  this.onShowPrivacy()
                }
              })
          }
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 20 })
      .alignItems(VerticalAlign.Top)

      if (this.validationErrors.agreeTerms) {
        Text(this.validationErrors.agreeTerms)
          .fontSize(12)
          .fontColor('#f44336')
          .margin({ bottom: 8 })
          .width('100%')
      }

      // Register Button
      Button() {
        if (this.loading) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(Color.White)
        } else {
          Text('注册账号')
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
        this.handleRegister()
      })

      // Login Link
      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#666666')
        Text('立即登录')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F8BBD0')
          .margin({ left: 4 })
          .onClick(() => {
            if (this.onNavigateToLogin) {
              this.onNavigateToLogin()
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
  }

  validateForm(): boolean {
    let isValid = true
    this.validationErrors = {
      name: '',
      phone: '',
      password: '',
      confirmPassword: '',
      gender: '',
      agreeTerms: ''
    }

    // Validate name
    if (!this.name) {
      this.validationErrors.name = '请输入用户名'
      isValid = false
    }

    // Validate gender
    if (!this.gender) {
      this.validationErrors.gender = '请选择性别'
      isValid = false
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
    } else if (this.password.length < 6) {
      this.validationErrors.password = '密码长度至少6个字符'
      isValid = false
    }

    // Validate confirm password
    if (!this.confirmPassword) {
      this.validationErrors.confirmPassword = '请确认密码'
      isValid = false
    } else if (this.password !== this.confirmPassword) {
      this.validationErrors.confirmPassword = '两次输入的密码不一致'
      isValid = false
    }

    // Validate terms
    if (!this.agreeTerms) {
      this.validationErrors.agreeTerms = '请阅读并同意条款和政策'
      isValid = false
    }

    return isValid
  }

  async handleRegister() {
    if (!this.validateForm()) {
      return
    }

    this.loading = true
    this.error = false

    try {
      // 导入AuthService
      const authModule = await import('../../services/AuthService')
      const authService = authModule.AuthService.getInstance()

      // 调用真实的注册API
      const response = await authService.register({
        name: this.name,
        phone: this.phone,
        password: this.password,
        gender: this.gender as 'male' | 'female'
      })

      if (response.success && response.user) {
        // 注册成功
        if (this.onRegisterSuccess) {
          this.onRegisterSuccess(response.user)
        }
      } else {
        // 注册失败
        this.error = true
        this.errorMessage = response.message || '注册失败，请重试'
      }
    } catch (err) {
      this.error = true
      const errorObj = err as Record<string, string>
      let errorMsg = '注册失败，请重试'
      if (errorObj && typeof errorObj === 'object') {
        const messageValue = errorObj['message']
        if (messageValue) {
          errorMsg = String(messageValue)
        }
      }
      this.errorMessage = errorMsg
      console.error('注册错误:', JSON.stringify(err))
    } finally {
      this.loading = false
    }
  }
}

// Data Models
interface ValidationErrors {
  name?: string
  phone?: string
  password?: string
  confirmPassword?: string
  gender?: string
  agreeTerms?: string
}

