import { HttpService } from '../../services/HttpService'
import { AuthService } from '../../services/AuthService'

/**
 * 风险数据接口
 */
export interface RiskData {
  level?: string
  percentage?: number
}

/**
 * 成分分析数据接口
 */
export interface IngredientAnalysisData {
  safetyIndex?: number
  efficacyScore?: number
  activeIngredients?: number
  acneRisk?: RiskData
  irritationRisk?: RiskData
  allergyRisk?: RiskData
  efficacyAnalysis?: string[]
  potentialRisks?: string[]
  recommendations?: string[]
  overallRating?: number
  summary?: string
}

/**
 * 成分分析响应数据
 */
export interface IngredientAnalysisResponseData {
  ingredientAnalysis?: IngredientAnalysisData
}

/**
 * API响应接口
 */
export interface IngredientAnalysisApiResponse<T> {
  success: boolean
  data?: T
  message?: string
}

/**
 * Ingredient Analysis API Service
 * 处理成分分析相关的API调用
 */
export class IngredientAnalysisApiService {
  private static instance: IngredientAnalysisApiService | null = null
  private httpService: HttpService
  private authService: AuthService

  private constructor() {
    this.httpService = HttpService.getInstance()
    this.authService = AuthService.getInstance()
  }

  static getInstance(): IngredientAnalysisApiService {
    if (IngredientAnalysisApiService.instance === null) {
      IngredientAnalysisApiService.instance = new IngredientAnalysisApiService()
    }
    return IngredientAnalysisApiService.instance
  }

  /**
   * 获取认证请求头
   */
  private getAuthHeaders(): Record<string, string> {
    const token = this.authService.getToken()
    if (!token) {
      console.warn('⚠️ Token为空，请求将不带认证头')
      return {}
    }
    const headers: Record<string, string> = {} as Record<string, string>
    headers['Authorization'] = `Bearer ${token}`
    return headers
  }

  /**
   * 分析产品成分
   */
  async analyzeIngredients(productId: string): Promise<IngredientAnalysisApiResponse<IngredientAnalysisResponseData>> {
    console.log('===== 🧪 步骤4: 分析产品成分 =====')

    const headers = this.getAuthHeaders()
    const emptyBody: Record<string, string> = {} as Record<string, string>
    const response = await this.httpService.post<IngredientAnalysisResponseData>(
      `/products/${productId}/analyze-ingredients`,
      emptyBody,
      headers
    )

    if (response.success && response.data) {
      console.log(`✅ 成分分析成功！`)
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 分析成分失败:', response.message)
    return {
      success: false,
      message: response.message || '分析成分失败'
    }
  }

  /**
   * 获取成分分析结果
   */
  async getIngredientAnalysis(productId: string): Promise<IngredientAnalysisApiResponse<IngredientAnalysisResponseData>> {
    console.log('===== 🔍 获取成分分析结果 =====')

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<IngredientAnalysisResponseData>(
      `/products/${productId}/ingredient-analysis`,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取成分分析成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取成分分析失败:', response.message)
    return {
      success: false,
      message: response.message || '获取成分分析失败'
    }
  }
}
