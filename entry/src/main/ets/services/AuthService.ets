import { AuthApiService, GetUserApiResponse, LoginRequest, RegisterRequest } from './AuthApiService'
import { AuthSessionStore } from './AuthSessionStore'

// User Data Interface
export interface UserData {
  id?: string
  name?: string
  phone?: string
  gender?: string
  age?: number
  avatar?: string
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

export interface RestoreSessionResponse {
  success: boolean
  retryRequired?: boolean
  message?: string
}

// AppStorage is a process-local projection of the secure session, not its store.
export class AuthService {
  private static instance: AuthService | null = null
  private readonly STORAGE_KEY_TOKEN = 'auth_token'
  private readonly STORAGE_KEY_USER = 'auth_user'
  private authApiService: AuthApiService
  private sessionStore: AuthSessionStore = AuthSessionStore.getInstance()
  private sessionGeneration: number = 0
  private restored: boolean = false
  private rejectedSession: boolean = false

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
    return !this.rejectedSession && token !== undefined && token !== '' && token !== null
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

  private publishUser(user: UserData, token: string): void {
    const snapshot: UserData = { id: user.id, name: user.name, phone: user.phone,
      gender: user.gender, age: user.age, avatar: user.avatar }
    AppStorage.setOrCreate<string>(this.STORAGE_KEY_TOKEN, token)
    AppStorage.setOrCreate<string>(this.STORAGE_KEY_USER, JSON.stringify(snapshot))
    AppStorage.setOrCreate<boolean>('aiskinAuthenticated', true)
  }

  setUser(user: UserData, token: string): void {
    if (!token.trim()) throw new Error('登录凭据为空，请重新登录')
    this.sessionStore.save(user, token)
    this.sessionGeneration++
    this.rejectedSession = false
    this.restored = true
    this.publishUser(user, token)
  }

  private clearMemory(): void {
    AppStorage.delete(this.STORAGE_KEY_TOKEN)
    AppStorage.delete(this.STORAGE_KEY_USER)
    AppStorage.setOrCreate<boolean>('aiskinAuthenticated', false)
  }

  logout(): void {
    // Invalidate responses before touching storage. Report a failure if neither
    // the signed-out barrier nor deletion can be made durable.
    this.sessionGeneration++
    this.sessionStore.clear()
    this.restored = true
    this.rejectedSession = false
    this.clearMemory()
  }

  async restoreSession(): Promise<RestoreSessionResponse> {
    try {
      if (this.rejectedSession) this.logout()
      if (!this.restored) {
        const session = this.sessionStore.read()
        if (session) this.publishUser(session.user, session.token)
        else this.clearMemory()
        this.restored = true
      }
      if (!this.isAuthenticated()) return { success: true }
      // A transport/server failure keeps the credential and cached profile.
      // Only the real HTTP 401 below revokes this session.
      const response = await this.fetchCurrentUser()
      return { success: response.success, message: response.message }
    } catch (error) {
      return { success: false, retryRequired: true, message: '安全登录信息读取或清理失败，请重试' }
    }
  }

  /**
   * 用户登录
   * @param credentials 登录凭证
   * @returns Promise<LoginServiceResponse>
   */
  async login(credentials: LoginRequest): Promise<LoginServiceResponse> {
    const generation = ++this.sessionGeneration
    const response = await this.authApiService.login(credentials)
    if (generation !== this.sessionGeneration) return { success: false, message: '登录操作已取消，请重试' }
    
    if (response.success && response.data) {
      try { this.setUser(response.data.user, response.data.token) }
      catch (error) { return { success: false, message: '无法安全保存登录信息，请重试' } }
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
    const generation = ++this.sessionGeneration
    const response = await this.authApiService.register(userData)
    if (generation !== this.sessionGeneration) return { success: false, message: '注册登录操作已取消，请重试' }
    
    if (response.success && response.data) {
      try { this.setUser(response.data.user, response.data.token) }
      catch (error) { return { success: false, message: '无法安全保存登录信息，请重试' } }
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

    const generation = this.sessionGeneration
    let response: GetUserApiResponse
    try { response = await this.authApiService.getCurrentUser(token) }
    catch (error) { return { success: false, message: '网络请求失败，请检查连接后重试' } }

    if (generation !== this.sessionGeneration || this.getToken() !== token) return { success: false, message: '登录状态已变化，请重新登录' }
    if (response.success && response.data) {
      // A profile-cache write failure must not revoke an otherwise valid token.
      try { this.sessionStore.update(response.data, token) }
      catch (error) { console.error('Unable to refresh the secure profile snapshot') }
      this.publishUser(response.data, token)
      return { success: true, user: response.data }
    }
    if (response.statusCode === 401) {
      this.rejectedSession = true
      this.clearMemory()
      this.logout()
    }
    return { success: false, message: response.message || '获取用户信息失败' }
  }

  async updateAge(age: number): Promise<FetchUserServiceResponse> {
    const token = this.getToken()
    if (!token) return { success: false, message: '请先登录' }
    if (!Number.isInteger(age) || age < 13 || age > 120) return { success: false, message: '请输入13–120的整数' }
    const generation = this.sessionGeneration
    const response = await this.authApiService.updateAge(age, token)
    if (generation !== this.sessionGeneration || this.getToken() !== token) return { success: false, message: '登录状态已变化，请重新登录' }
    if (response.success && response.data) {
      try { this.sessionStore.update(response.data, token) }
      catch (error) { console.error('Unable to refresh the secure profile snapshot') }
      this.publishUser(response.data, token)
      return { success: true, user: response.data }
    }
    return { success: false, message: response.message || '年龄保存失败，请稍后重试' }
  }

}
