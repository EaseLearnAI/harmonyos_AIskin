import { AuthApiService, LoginRequest, RegisterRequest } from './AuthApiService'

// User Data Interface
export interface UserData {
  id?: string
  name?: string
  phone?: string
  gender?: string
  token?: string
}

/**
 * 登录响应接口
 */
interface LoginServiceResponse {
  success: boolean
  user?: UserData
  message?: string
}

/**
 * 注册响应接口
 */
interface RegisterServiceResponse {
  success: boolean
  user?: UserData
  message?: string
}

/**
 * 获取用户信息响应接口
 */
interface FetchUserServiceResponse {
  success: boolean
  user?: UserData
  message?: string
}

// Auth Service Class - Using AppStorage for simplicity
export class AuthService {
  private static instance: AuthService | null = null
  private readonly STORAGE_KEY_TOKEN = 'auth_token'
  private readonly STORAGE_KEY_USER = 'auth_user'
  private authApiService: AuthApiService

  private constructor() {
    // Private constructor for singleton
    this.authApiService = AuthApiService.getInstance()
  }

  static getInstance(): AuthService {
    if (AuthService.instance === null) {
      AuthService.instance = new AuthService()
    }
    return AuthService.instance
  }

  isAuthenticated(): boolean {
    const token = AppStorage.get<string>(this.STORAGE_KEY_TOKEN)
    return token !== undefined && token !== '' && token !== null
  }

  getCurrentUser(): UserData | null {
    const userStr = AppStorage.get<string>(this.STORAGE_KEY_USER)
    if (userStr === undefined || userStr === '' || userStr === null) {
      return null
    }
    try {
      return JSON.parse(userStr) as UserData
    } catch (err) {
      console.error('Failed to parse stored user data')
      return null
    }
  }

  getToken(): string | null {
    const token = AppStorage.get<string>(this.STORAGE_KEY_TOKEN) || null
    return token
  }

  setUser(user: UserData, token: string): void {
    if (!token || token.trim() === '') {
      console.error('❌ Token为空，无法保存')
      return
    }
    
    user.token = token
    
    // 使用setOrCreate确保能够正确保存
    AppStorage.setOrCreate<string>(this.STORAGE_KEY_TOKEN, token)
    AppStorage.setOrCreate<string>(this.STORAGE_KEY_USER, JSON.stringify(user))
    
  }

  logout(): void {
    AppStorage.delete(this.STORAGE_KEY_TOKEN)
    AppStorage.delete(this.STORAGE_KEY_USER)
  }

  /**
   * 用户登录
   * @param credentials 登录凭证
   * @returns Promise<LoginServiceResponse>
   */
  async login(credentials: LoginRequest): Promise<LoginServiceResponse> {
    const response = await this.authApiService.login(credentials)
    
    if (response.success && response.data) {
      this.setUser(response.data.user, response.data.token)
      return {
        success: true,
        user: response.data.user
      }
    } else {
      return {
        success: false,
        message: response.message || '登录失败'
      }
    }
  }

  /**
   * 用户注册
   * @param userData 注册数据
   * @returns Promise<RegisterServiceResponse>
   */
  async register(userData: RegisterRequest): Promise<RegisterServiceResponse> {
    const response = await this.authApiService.register(userData)
    
    if (response.success && response.data) {
      this.setUser(response.data.user, response.data.token)
      return {
        success: true,
        user: response.data.user
      }
    } else {
      return {
        success: false,
        message: response.message || '注册失败'
      }
    }
  }

  /**
   * 获取当前用户信息（从服务器）
   * @returns Promise<FetchUserServiceResponse>
   */
  async fetchCurrentUser(): Promise<FetchUserServiceResponse> {
    const token = this.getToken()
    if (!token) {
      return {
        success: false,
        message: '未登录'
      }
    }

    const response = await this.authApiService.getCurrentUser(token)
    
    if (response.success && response.data) {
      // 更新本地存储的用户信息
      this.setUser(response.data, token)
      return {
        success: true,
        user: response.data
      }
    } else {
      // 如果token失效，清除本地数据
      if (response.message && (response.message.includes('401') || response.message.includes('未授权'))) {
        this.logout()
      }
      return {
        success: false,
        message: response.message || '获取用户信息失败'
      }
    }
  }
}
