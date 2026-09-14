import http from '@ohos.net.http'
import { rcp } from '@kit.RemoteCommunicationKit'
import { ApiConfig } from './ApiConfig'

/**
 * HTTP响应接口
 */
export interface HttpResponse<T = Record<string, string>> {
  success: boolean
  data?: T
  message?: string
  error?: string
  token?: string
}

/**
 * HTTP请求选项
 */
export interface HttpRequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
  headers?: Record<string, string>
  body?: LoginRequestBody | RegisterRequestBody | TextDataRecord | Record<string, Object | string | number | boolean>
  timeout?: number
}

/**
 * 登录请求体接口（用于类型兼容）
 */
export interface LoginRequestBody {
  phone: string
  password: string
}

/**
 * 注册请求体接口（用于类型兼容）
 */
export interface RegisterRequestBody {
  name: string
  phone: string
  password: string
  gender: string
}

/**
 * HTTP响应数据接口
 */
interface HttpResponseData {
  success?: boolean
  data?: Record<string, string> | TextDataRecord
  message?: string
  error?: string
  token?: string
}

/**
 * 文本数据接口（用于非JSON响应）
 */
interface TextData {
  content: string
}

/**
 * 文本数据记录接口（用于转换为Record）
 */
export interface TextDataRecord {
  content: string
}

/**
 * 错误对象接口
 */
interface ErrorWithMessage {
  message?: string
  name?: string
  toString?: () => string
}

/**
 * HTTP Service
 * 封装HarmonyOS的http模块，提供统一的HTTP请求方法
 */
export class HttpService {
  private static instance: HttpService | null = null
  private defaultTimeout: number = 30000 // 30秒超时

  private constructor() {
    // Private constructor for singleton
  }

  static getInstance(): HttpService {
    if (HttpService.instance === null) {
      HttpService.instance = new HttpService()
    }
    return HttpService.instance
  }

  /**
   * 打印请求信息（用于调试）
   */
  private logRequest(_url: string, options: HttpRequestOptions): void {
    console.log('===== 📡 HTTP 请求 =====')
    console.log(`📋 Method: ${options.method || 'GET'}`)
  }

  /**
   * 打印响应信息（用于调试）
   */
  private logResponse(_url: string, statusCode: number, _responseData: HttpResponseData): void {
    console.log('✅ 收到响应')
    console.log(`📊 Status Code: ${statusCode}`)
  }

  /**
   * 合并请求头
   */
  private mergeHeaders(baseHeaders: Record<string, string>, customHeaders?: Record<string, string>): Record<string, string> {
    const merged: Record<string, string> = {}
    
    // 复制基础请求头
    const baseKeys = Object.keys(baseHeaders)
    for (let i = 0; i < baseKeys.length; i++) {
      const key = baseKeys[i]
      merged[key] = baseHeaders[key]
    }
    
    // 合并自定义请求头
    if (customHeaders) {
      const customKeys = Object.keys(customHeaders)
      for (let i = 0; i < customKeys.length; i++) {
        const key = customKeys[i]
        merged[key] = customHeaders[key]
      }
    }
    
    return merged
  }

  /**
   * 检查错误对象是否有message属性
   */
  private getErrorMessage(error: ErrorWithMessage | string | null | undefined): string {
    if (error === null || error === undefined) {
      return '网络请求失败'
    }
    
    // 如果是字符串，直接返回
    if (typeof error === 'string') {
      return error
    }
    
    // 尝试转换为ErrorWithMessage类型
    const errorObj = error as ErrorWithMessage
    if (errorObj && errorObj.message) {
      return String(errorObj.message)
    }
    
    // 尝试转换为字符串
    try {
      return String(error)
    } catch {
      return '网络请求失败'
    }
  }

  /**
   * 发送HTTP请求
   * @param endpoint API端点路径
   * @param options 请求选项
   * @returns Promise<HttpResponse<T>>
   */
  private async requestPatch<T>(url: string, headers: Record<string, string>, body: string): Promise<HttpResponse<T>> {
    // NetworkKit's RequestMethod has no PATCH in SDK 20. RCP supports the real method.
    let session: rcp.Session | undefined = undefined
    try {
      session = rcp.createSession()
      const response = await session.fetch(new rcp.Request(url, 'PATCH', headers, body))
      const payload = response.toJSON() as HttpResponse<T> | null
      if (response.statusCode < 200 || response.statusCode >= 300 || !payload?.success) {
        return { success: false, message: payload?.message || `HTTP ${response.statusCode}` } as HttpResponse<T>
      }
      return payload
    } catch (error) {
      return { success: false, message: '网络请求失败，请检查连接后重试' } as HttpResponse<T>
    } finally { session?.close() }
  }

  async request<T = Record<string, string>>(endpoint: string, options: HttpRequestOptions = {}): Promise<HttpResponse<T>> {
    const url = ApiConfig.getApiUrl(endpoint)
    const method = options.method || 'GET'
    
    // 构建请求头
    const baseHeaders: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    
    // 合并自定义请求头
    const headers = this.mergeHeaders(baseHeaders, options.headers)

    // 构建请求体
    let body: string | undefined = undefined
    if (options.body && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
      // 直接序列化body对象
      body = JSON.stringify(options.body)
    }

    // 打印请求信息
    const logOptions: HttpRequestOptions = {
      method: options.method,
      headers: options.headers,
      body: options.body
    }
    this.logRequest(url, logOptions)

    if (method === 'PATCH') return this.requestPatch<T>(url, headers, body || '{}')

    const request = http.createHttp()
    try {
      // 构建http请求选项
      const httpRequestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod[method],
        header: headers,
        connectTimeout: options.timeout || this.defaultTimeout,
        readTimeout: options.timeout || ((endpoint.includes('analy') || endpoint.includes('extract-ingredients') || (endpoint === '/plans' || endpoint === '/conflicts') && options.method === 'POST') ? 120000 : this.defaultTimeout)
      }

      // 如果有请求体，添加到选项中
      if (body) {
        httpRequestOptions.extraData = body
      }

      // 发送HTTP请求
      const response = await request.request(url, httpRequestOptions)

      // 解析响应
      let responseData: HttpResponseData = {}
      const responseBody = response.result.toString()
      
      try {
        // 解析JSON响应，直接断言为HttpResponseData
        const parsed = JSON.parse(responseBody) as HttpResponseData
        responseData = parsed
      } catch (parseError) {
        // 如果不是JSON，直接使用文本作为data
        const textData: TextData = {
          content: responseBody
        }
        const textDataRecord: TextDataRecord = {
          content: textData.content
        }
        // 直接使用TextDataRecord，避免创建Record对象字面量
        responseData = {
          data: textDataRecord
        } as HttpResponseData
      }

      // 打印响应信息
      this.logResponse(url, response.responseCode, responseData)

      // 处理响应
      if (response.responseCode >= 200 && response.responseCode < 300) {
        // 如果响应格式是 {success: true, data: {...}, token: "..."}
        if (responseData.success !== undefined) {
          // 直接使用responseData.data，通过类型断言处理
          return {
            success: responseData.success,
            data: responseData.data as T,
            message: responseData.message,
            token: responseData.token
          } as HttpResponse<T>
        }
        // 如果响应格式是直接的数据
        return {
          success: true,
          data: responseData.data as T
        } as HttpResponse<T>
      } else {
        // HTTP错误状态码
        return {
          success: false,
          message: responseData.message || responseData.error || `HTTP ${response.responseCode}`,
          error: responseData.error
        } as HttpResponse<T>
      }
    } catch (error) {
      console.error('❌ HTTP请求错误')
      
      // 处理不同类型的错误
      const errorObj = error as ErrorWithMessage | string | null | undefined
      const errorMessage = this.getErrorMessage(errorObj)

      return {
        success: false,
        message: errorMessage,
        error: String(error)
      } as HttpResponse<T>
    } finally {
      request.destroy()
    }
  }

  /**
   * GET请求
   */
  async get<T = Record<string, string>>(endpoint: string, headers?: Record<string, string>): Promise<HttpResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'GET',
      headers: headers
    })
  }

  /**
   * POST请求
   */
  async post<T = Record<string, string>>(endpoint: string, body?: LoginRequestBody | RegisterRequestBody | TextDataRecord | Record<string, Object | string | number | boolean>, headers?: Record<string, string>): Promise<HttpResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: body,
      headers: headers
    })
  }

  /**
   * PUT请求
   */
  async put<T = Record<string, string>>(endpoint: string, body?: LoginRequestBody | RegisterRequestBody | TextDataRecord | Record<string, Object | string | number | boolean>, headers?: Record<string, string>): Promise<HttpResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: body,
      headers: headers
    })
  }

  /**
   * PATCH请求
   */
  async patch<T = Record<string, string>>(endpoint: string, body?: LoginRequestBody | RegisterRequestBody | TextDataRecord, headers?: Record<string, string>): Promise<HttpResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'PATCH',
      body: body,
      headers: headers
    })
  }

  /**
   * DELETE请求
   */
  async delete<T = Record<string, string>>(endpoint: string, headers?: Record<string, string>): Promise<HttpResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'DELETE',
      headers: headers
    })
  }

  /**
   * 设置默认超时时间
   */
  setTimeout(timeout: number): void {
    this.defaultTimeout = timeout
  }

  /**
   * 销毁HTTP请求实例
   */
  destroy(): void {
    // Requests release their own handles in finally.
  }
}
