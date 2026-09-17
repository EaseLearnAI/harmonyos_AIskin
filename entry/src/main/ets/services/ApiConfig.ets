/**
 * API Configuration
 * 配置API服务器地址
 */
export class ApiConfig {
  static readonly ENABLE_COMPONENT_PREVIEW: boolean = false
  // 服务器基础URL - 从接口.md文档中获取
  private static readonly BASE_URL: string = 'https://www.lunzo.site/api'

  /**
   * 获取完整的API URL
   * @param endpoint API端点路径（例如：'/users/login'）
   * @returns 完整的URL
   */
  static getApiUrl(endpoint: string): string {
    // 确保endpoint以/开头
    const normalizedEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`
    return `${ApiConfig.BASE_URL}${normalizedEndpoint}`
  }

  /**
   * 获取服务器基础URL
   */
  static getBaseUrl(): string {
    return ApiConfig.BASE_URL
  }
}

