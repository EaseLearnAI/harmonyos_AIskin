import { HttpService } from '../../services/HttpService'
import { AuthService } from '../../services/AuthService'

/**
 * 冲突项接口
 */
export interface ConflictItem {
  components?: string[]
  description?: string
  severity?: string
  effects?: string[]
}

/**
 * 安全组合项接口
 */
export interface SafeComboItem {
  components?: string[]
  description?: string
}

/**
 * 配对项接口
 */
export interface PairingItem {
  products?: string[]
  reason?: string
}

/**
 * 产品配对接口
 */
export interface ProductPairings {
  cannotUseTogether?: PairingItem[]
  canUseTogether?: PairingItem[]
}

/**
 * 护肤步骤接口
 */
export interface Routines {
  morning?: string[]
  evening?: string[]
}

/**
 * 推荐数据接口
 */
export interface RecommendationData {
  productPairings?: ProductPairings
  routines?: Routines
}

/**
 * 产品信息接口
 */
export interface ConflictProductInfo {
  id?: string
  name?: string
  description?: string
  imageUrl?: string
}

/**
 * 冲突分析响应数据
 */
export interface ConflictAnalysisData {
  conflictId?: string
  conflicts?: ConflictItem[]
  safeCombo?: SafeComboItem[]
  recommendations?: RecommendationData
  products?: ConflictProductInfo[]
}

/**
 * 分析冲突请求接口
 */
export interface AnalyzeConflictRequest {
  productIds: string[]
}

/**
 * API响应接口
 */
export interface ConflictApiResponse<T> {
  success: boolean
  data?: T
  message?: string
}

/**
 * Conflict API Service
 * 处理产品冲突检测相关的API调用
 */
export class ConflictApiService {
  private static instance: ConflictApiService | null = null
  private httpService: HttpService
  private authService: AuthService

  private constructor() {
    this.httpService = HttpService.getInstance()
    this.authService = AuthService.getInstance()
  }

  static getInstance(): ConflictApiService {
    if (ConflictApiService.instance === null) {
      ConflictApiService.instance = new ConflictApiService()
    }
    return ConflictApiService.instance
  }

  /**
   * 获取认证请求头
   */
  private getAuthHeaders(): Record<string, string> {
    const token = this.authService.getToken()
    console.log(`🔑 获取Token: ${token ? '已找到' : '未找到'}`)
    if (!token) {
      console.warn('⚠️ Token为空，请求将不带认证头')
      return {}
    }
    const headers: Record<string, string> = {} as Record<string, string>
    headers['Authorization'] = `Bearer ${token}`
    console.log(`📦 认证头: Authorization: Bearer ${token.substring(0, 20)}...`)
    return headers
  }

  /**
   * 分析产品冲突
   */
  async analyzeConflict(productIds: string[]): Promise<ConflictApiResponse<ConflictAnalysisData>> {
    console.log('===== ⚠️ 开始冲突分析 =====')
    console.log(`📊 分析产品:`)
    for (let i = 0; i < productIds.length; i++) {
      console.log(`   ${i + 1}. 产品ID: ${productIds[i]}`)
    }

    const headers = this.getAuthHeaders()
    const body: AnalyzeConflictRequest = {
      productIds: productIds
    }

    // 转换为 Record 类型以符合 HttpService 的要求
    const bodyRecord: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    bodyRecord.productIds = body.productIds

    const response = await this.httpService.post<ConflictAnalysisData>(
      '/conflicts',
      bodyRecord,
      headers
    )

    if (response.success && response.data) {
      const conflictData = response.data
      console.log(`✅ 冲突分析成功！`)
      console.log(`📋 冲突记录ID: ${conflictData.conflictId || '未知'}`)
      console.log(`📋 发现冲突数: ${conflictData.conflicts?.length || 0}`)
      console.log(`📋 安全组合数: ${conflictData.safeCombo?.length || 0}`)

      if (conflictData.conflicts && conflictData.conflicts.length > 0) {
        console.log('⚠️ 检测到的冲突:')
        for (let i = 0; i < conflictData.conflicts.length; i++) {
          const conflict = conflictData.conflicts[i]
          console.log(`🔴 ${i + 1}. ${conflict.components?.join(' + ') || '未知成分'} - ${conflict.severity || '未知'}风险`)
          console.log(`  描述: ${conflict.description || '无'}`)
        }
      }

      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 冲突分析失败:', response.message)
    return {
      success: false,
      message: response.message || '冲突分析失败'
    }
  }

  /**
   * 获取冲突详情
   */
  async getConflictDetails(conflictId: string): Promise<ConflictApiResponse<ConflictAnalysisData>> {
    console.log('===== 🔍 获取冲突详情 =====')
    console.log(`🆔 冲突ID: ${conflictId}`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<ConflictAnalysisData>(
      `/conflicts/${conflictId}`,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取冲突详情成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取冲突详情失败:', response.message)
    return {
      success: false,
      message: response.message || '获取冲突详情失败'
    }
  }
}

