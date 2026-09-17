import { HttpService } from './HttpService'
import { AuthService } from './AuthService'

/**
 * 皮肤类型数据接口
 */
export interface SkinTypeData {
  type?: string
  subtype?: string
  basis?: string
}

/**
 * 黑头数据接口
 */
export interface BlackheadsData {
  description?: string
  exists?: boolean
  severity?: string
  distribution?: string[]
}

/**
 * 痘痘数据接口
 */
export interface AcneData {
  description?: string
  exists?: boolean
  count?: string
  types?: string[]
  distribution?: string[]
}

/**
 * 毛孔数据接口
 */
export interface PoresData {
  description?: string
  enlarged?: boolean
  severity?: string
  distribution?: string[]
}

/**
 * 肤色均匀度数据接口
 */
export interface SkinToneEvennessData {
  score?: number
  description?: string
}

/**
 * 泛红数据接口
 */
export interface RednessData {
  exists?: boolean
  severity?: string
  description?: string
  distribution?: string[]
}

/**
 * 色素沉着数据接口
 */
export interface HyperpigmentationData {
  exists?: boolean
  severity?: string
  description?: string
  types?: string[]
  distribution?: string[]
}

/**
 * 细纹数据接口
 */
export interface FineLinesData {
  exists?: boolean
  severity?: string
  description?: string
  distribution?: string[]
}

/**
 * 敏感度数据接口
 */
export interface SensitivityData {
  exists?: boolean
  severity?: string
  description?: string
  signs?: string[]
}

/**
 * 其他问题数据接口
 */
export interface OtherIssuesData {
  skinToneEvenness?: SkinToneEvennessData
  redness?: RednessData
  hyperpigmentation?: HyperpigmentationData
  fineLines?: FineLinesData
  sensitivity?: SensitivityData
}

/**
 * 整体评估数据接口
 */
export interface OverallAssessmentData {
  healthScore?: number
  summary?: string
  recommendations?: string[]
  skinCondition?: string
}

/**
 * 皮肤分析结果数据模型
 */
export interface SkinContext { condition?: string; light?: string; feelings?: string[] }
export interface SkinAnalysisData {
  context?: SkinContext
  _id?: string
  analysisId?: string
  imageUrl?: string
  imageName?: string
  skinType?: SkinTypeData
  blackheads?: BlackheadsData
  acne?: AcneData
  pores?: PoresData
  otherIssues?: OtherIssuesData
  overallAssessment?: OverallAssessmentData
  oilLevel?: string
  moistureLevel?: string
  poreLevel?: string
  moisture?: number
  glossiness?: number
  elasticity?: number
  problemAreaScore?: number
  createdAt?: string
  updatedAt?: string
}

/**
 * 分页数据接口
 */
export interface PaginationData {
  page?: number
  limit?: number
  total?: number
  pages?: number
}

/**
 * 分析历史响应数据
 */
export interface AnalysisHistoryData {
  analyses?: SkinAnalysisData[]
  pagination?: PaginationData
}

/**
 * 分析详情响应数据
 */
export interface AnalysisDetailData {
  analysis?: SkinAnalysisData
}

/**
 * 分析统计数据接口
 */
export interface AnalysisStatsInfo {
  totalAnalyses?: number
  averageHealthScore?: number
  latestSkinCondition?: string
  latestAnalysisDate?: string
}

/**
 * 分析统计响应数据
 */
export interface AnalysisStatsData {
  stats?: AnalysisStatsInfo
}

/**
 * API响应接口
 */
export interface SkinAnalysisApiResponse<T> {
  success: boolean
  data?: T
  message?: string
}

/**
 * Skin Analysis API Service
 * 处理皮肤分析相关的API调用
 */
export class SkinAnalysisApiService {
  private static instance: SkinAnalysisApiService | null = null
  private httpService: HttpService
  private authService: AuthService

  private constructor() {
    this.httpService = HttpService.getInstance()
    this.authService = AuthService.getInstance()
  }

  static getInstance(): SkinAnalysisApiService {
    if (SkinAnalysisApiService.instance === null) {
      SkinAnalysisApiService.instance = new SkinAnalysisApiService()
    }
    return SkinAnalysisApiService.instance
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
    const headers: Record<string, string> = {
      'Authorization': `Bearer ${token}`
    }
    return headers
  }

  /**
   * 上传图片并分析皮肤
   * 注意: 这个接口实际上是通过FileService上传文件,这里只提供获取分析结果的接口
   * @param analysisId 分析ID(从上传响应中获取)
   * @returns Promise<SkinAnalysisApiResponse<AnalysisDetailData>>
   */
  async getAnalysisResult(analysisId: string): Promise<SkinAnalysisApiResponse<AnalysisDetailData>> {
    console.log('===== 🔍 获取分析结果 =====')

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<AnalysisDetailData>(
      `/skin-analysis/${analysisId}`,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取分析结果成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取分析结果失败:', response.message)
    return {
      success: false,
      message: response.message || '获取分析结果失败'
    }
  }

  /**
   * 获取分析历史记录
   * @param page 页码
   * @param limit 每页数量
   * @returns Promise<SkinAnalysisApiResponse<AnalysisHistoryData>>
   */
  async getAnalysisHistory(page: number = 1, limit: number = 10): Promise<SkinAnalysisApiResponse<AnalysisHistoryData>> {
    console.log('===== 📚 获取分析历史 =====')
    console.log(`📄 页码: ${page}`)
    console.log(`📊 每页数量: ${limit}`)

    const headers = this.getAuthHeaders()
    const endpoint = `/skin-analysis?page=${page}&limit=${limit}`
    
    const response = await this.httpService.get<AnalysisHistoryData>(
      endpoint,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取分析历史成功')
      const data = response.data
      if (data.pagination) {
        console.log(`📊 总记录数: ${data.pagination.total}`)
        console.log(`📄 当前页: ${data.pagination.page}`)
        console.log(`📋 总页数: ${data.pagination.pages}`)
      }
      if (data.analyses) {
        console.log(`📋 本页记录数: ${data.analyses.length}`)
      }
      return {
        success: true,
        data: data
      }
    }

    console.error('❌ 获取分析历史失败:', response.message)
    return {
      success: false,
      message: response.message || '获取分析历史失败'
    }
  }

  /**
   * 获取分析详情
   * @param analysisId 分析ID
   * @returns Promise<SkinAnalysisApiResponse<AnalysisDetailData>>
   */
  async getAnalysisDetail(analysisId: string): Promise<SkinAnalysisApiResponse<AnalysisDetailData>> {
    console.log('===== 🔍 获取分析详情 =====')

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<AnalysisDetailData>(
      `/skin-analysis/${analysisId}`,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取分析详情成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取分析详情失败:', response.message)
    return {
      success: false,
      message: response.message || '获取分析详情失败'
    }
  }

  /**
   * 获取分析统计信息
   * @returns Promise<SkinAnalysisApiResponse<AnalysisStatsData>>
   */
  async getAnalysisStats(): Promise<SkinAnalysisApiResponse<AnalysisStatsData>> {
    console.log('===== 📈 获取分析统计 =====')

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<AnalysisStatsData>(
      '/skin-analysis/stats',
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取分析统计成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取分析统计失败:', response.message)
    return {
      success: false,
      message: response.message || '获取分析统计失败'
    }
  }

  /**
   * 获取最新分析结果
   * @returns Promise<SkinAnalysisApiResponse<AnalysisDetailData>>
   */
  async getLatestAnalysis(): Promise<SkinAnalysisApiResponse<AnalysisDetailData>> {
    console.log('===== 🔍 获取最新分析 =====')

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<AnalysisDetailData>(
      '/skin-analysis/latest',
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取最新分析成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取最新分析失败:', response.message)
    return {
      success: false,
      message: response.message || '获取最新分析失败'
    }
  }

  /**
   * 删除分析记录
   * @param analysisId 分析ID
   * @returns Promise<SkinAnalysisApiResponse<Record<string, string>>>
   */
  async updateContext(analysisId: string, context: SkinContext): Promise<SkinAnalysisApiResponse<AnalysisDetailData>> {
    const body: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    body.condition = context.condition || ''
    body.light = context.light || ''
    body.feelings = context.feelings || []
    return this.httpService.request<AnalysisDetailData>(`/skin-analysis/${analysisId}/context`, { method: 'PATCH', body: body, headers: this.getAuthHeaders() })
  }

  async deleteAnalysis(analysisId: string): Promise<SkinAnalysisApiResponse<Record<string, string>>> {
    console.log('===== 🗑️ 删除分析记录 =====')

    const headers = this.getAuthHeaders()
    const response = await this.httpService.delete<Record<string, string>>(
      `/skin-analysis/${analysisId}`,
      headers
    )

    if (response.success) {
      console.log('✅ 删除分析记录成功')
      return {
        success: true
      }
    }

    console.error('❌ 删除分析记录失败:', response.message)
    return {
      success: false,
      message: response.message || '删除分析记录失败'
    }
  }
}
