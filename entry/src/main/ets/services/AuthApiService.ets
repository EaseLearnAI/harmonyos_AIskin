import { HttpService, LoginRequestBody, RegisterRequestBody } from './HttpService'
import { UserData } from './AuthService'

/**
 * 登录请求参数
 */
export interface LoginRequest {
  phone: string
  password: string
  remember?: boolean
}

/**
 * 注册请求参数
 */
export interface RegisterRequest {
  name: string
  phone: string
  password: string
  gender: 'male' | 'female'
}

/**
 * 登录响应数据
 */
export interface LoginResponse {
  user: UserData
  token: string
}

/**
 * 注册响应数据
 */
export interface RegisterResponse {
  user: UserData
  token: string
}

/**
 * 登录API响应接口
 */
interface LoginApiResponse {
  success: boolean
  data?: LoginResponse
  message?: string
}

/**
 * 注册API响应接口
 */
interface RegisterApiResponse {
  success: boolean
  data?: RegisterResponse
  message?: string
}

/**
 * 获取用户信息API响应接口
 */
interface GetUserApiResponse {
  success: boolean
  data?: UserData
  message?: string
}

/**
 * 后端返回的用户数据接口
 */
interface BackendUserData {
  _id?: string
  id?: string
  name?: string
  phone?: string
  gender?: string
}

/**
 * 后端响应数据接口
 */
interface BackendResponseData {
  user?: BackendUserData
  token?: string
}

// 使用 HttpService 中导出的请求体接口，避免重复声明导致的结构化类型问题

/**
 * 登录请求体记录接口（用于转换为Record）
 */
// 注意：ArkTS 不支持结构化类型兼容，避免使用形状相同的不同接口作为替代

/**
 * Auth API Service
 * 处理认证相关的API调用
 */
export class AuthApiService {
  private static instance: AuthApiService | null = null
  private httpService: HttpService

  private constructor() {
    this.httpService = HttpService.getInstance()
  }

  static getInstance(): AuthApiService {
    if (AuthApiService.instance === null) {
      AuthApiService.instance = new AuthApiService()
    }
    return AuthApiService.instance
  }

  /**
   * 用户登录
   * @param credentials 登录凭证
   * @returns Promise<LoginApiResponse>
   */
  async login(credentials: LoginRequest): Promise<LoginApiResponse> {
    console.log('🔐 开始登录请求')
    console.log(`📱 手机号: ${credentials.phone}`)

    const requestBody: LoginRequestBody = {
      phone: credentials.phone,
      password: credentials.password
    }

    const response = await this.httpService.post<BackendResponseData>(
      '/users/login',
      requestBody
    )

    if (response.success && response.data) {
      const backendData = response.data as BackendResponseData
      console.log('✅ 登录成功')
      console.log(`🔑 响应中的Token: ${response.token ? response.token.substring(0, 20) + '...' : '未找到'}`)
      console.log(`🔑 Data中的Token: ${backendData.token ? backendData.token.substring(0, 20) + '...' : '未找到'}`)
      
      if (backendData.user) {
        console.log(`👤 用户ID: ${backendData.user._id || backendData.user.id}`)
        console.log(`📱 手机号: ${backendData.user.phone}`)
        console.log(`👤 用户名: ${backendData.user.name}`)

        // 转换用户数据格式
        const userData: UserData = {
          id: backendData.user._id || backendData.user.id,
          name: backendData.user.name,
          phone: backendData.user.phone,
          gender: backendData.user.gender
        }

        // 优先使用response.token（响应体顶层的token）
        const token = response.token || backendData.token || ''
        console.log(`🔑 最终使用的Token: ${token ? token.substring(0, 20) + '...' : '未找到'}`)

        const loginResponse: LoginResponse = {
          user: userData,
          token: token
        }

        return {
          success: true,
          data: loginResponse
        }
      }
    }
    
    console.error('❌ 登录失败:', response.message)
    return {
      success: false,
      message: response.message || '登录失败，请重试'
    }
  }

  /**
   * 用户注册
   * @param userData 注册数据
   * @returns Promise<RegisterApiResponse>
   */
  async register(userData: RegisterRequest): Promise<RegisterApiResponse> {
    console.log('🔐 开始注册请求')
    console.log(`📱 手机号: ${userData.phone}`)
    console.log(`👤 用户名: ${userData.name}`)
    console.log(`⚧️ 性别: ${userData.gender}`)

    const requestBody: RegisterRequestBody = {
      name: userData.name,
      phone: userData.phone,
      password: userData.password,
      gender: userData.gender
    }

    const response = await this.httpService.post<BackendResponseData>(
      '/users/register',
      requestBody
    )

    if (response.success && response.data) {
      const backendData = response.data as BackendResponseData
      console.log('✅ 注册成功')
      
      if (backendData.user) {
        console.log(`👤 用户ID: ${backendData.user._id || backendData.user.id}`)
        console.log(`📱 手机号: ${backendData.user.phone}`)
        console.log(`👤 用户名: ${backendData.user.name}`)

        // 转换用户数据格式
        const user: UserData = {
          id: backendData.user._id || backendData.user.id,
          name: backendData.user.name,
          phone: backendData.user.phone,
          gender: backendData.user.gender
        }

        const registerResponse: RegisterResponse = {
          user: user,
          token: response.token || backendData.token || ''
        }

        return {
          success: true,
          data: registerResponse
        }
      }
    }
    
    console.error('❌ 注册失败:', response.message)
    return {
      success: false,
      message: response.message || '注册失败，请重试'
    }
  }

  /**
   * 获取当前用户信息
   * @param token 认证token
   * @returns Promise<GetUserApiResponse>
   */
  async getCurrentUser(token: string): Promise<GetUserApiResponse> {
    console.log('👤 获取当前用户信息')

    const headers: Record<string, string> = {
      'Authorization': `Bearer ${token}`
    }

    const response = await this.httpService.get<BackendResponseData>(
      '/users/me',
      headers
    )

    if (response.success && response.data) {
      const backendData = response.data as BackendResponseData
      console.log('✅ 获取用户信息成功')
      
      if (backendData.user) {
        const userData: UserData = {
          id: backendData.user._id || backendData.user.id,
          name: backendData.user.name,
          phone: backendData.user.phone,
          gender: backendData.user.gender
        }
        
        return {
          success: true,
          data: userData
        }
      }
    }
    
    console.error('❌ 获取用户信息失败:', response.message)
    return {
      success: false,
      message: response.message || '获取用户信息失败'
    }
  }
}
