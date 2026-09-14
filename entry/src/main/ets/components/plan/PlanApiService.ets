import { HttpService } from '../../services/HttpService'
import { AuthService } from '../../services/AuthService'

/**
 * 方案步骤接口
 */
export interface PlanStep {
  step?: number
  product?: string
  reason?: string
  completed?: boolean
}

/**
 * 方案数据接口
 */
export interface PlanData {
  _id?: string
  id?: string
  name?: string
  requirement?: string
  skinConcerns?: string[]
  customRequirements?: string
  userAge?: number
  userGender?: string
  skinAnalysisId?: string | null
  menstrualCycleInfo?: string | null
  morning?: PlanStep[]
  evening?: PlanStep[]
  recommendations?: string[]
  skinAnalysisSummary?: string
  creatorNote?: string
  notes?: string
  tags?: string[]
  days?: Record<string, Object | string | number | boolean>[]
  createdAt?: string
  updatedAt?: string
}

/**
 * 创建方案请求接口
 */
export interface CreatePlanRequest {
  requirement?: string
  skinConcerns?: string[]
  customRequirements?: string
  age?: number
}

/**
 * 更新步骤完成状态请求接口
 */
export interface UpdateStepRequest {
  period: 'morning' | 'evening'
  step: number
  completed: boolean
}

/**
 * 方案列表响应数据
 */
export interface PlanListData {
  plans?: PlanData[]
  count?: number
}

/**
 * 方案详情响应数据
 */
export interface DailyStep { step: number; completed: boolean }
export interface DailyProgress { date: string; timezone: string; morning: DailyStep[]; evening: DailyStep[]; completedCount: number; totalCount: number }
export interface DailyResponse { daily: DailyProgress }
export interface PlanDetailData {
  plan?: PlanData
}

/**
 * API响应接口
 */
export interface PlanApiResponse<T> {
  success: boolean
  data?: T
  message?: string
  count?: number
}

/**
 * Plan API Service
 * 处理护肤方案相关的API调用
 */
export class PlanApiService {
  private static instance: PlanApiService | null = null
  private httpService: HttpService
  private authService: AuthService

  private constructor() {
    this.httpService = HttpService.getInstance()
    this.authService = AuthService.getInstance()
  }

  static getInstance(): PlanApiService {
    if (PlanApiService.instance === null) {
      PlanApiService.instance = new PlanApiService()
    }
    return PlanApiService.instance
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

  async getActivePlan(): Promise<PlanApiResponse<PlanDetailData>> {
    return this.httpService.get<PlanDetailData>('/plans/active', this.getAuthHeaders())
  }
  async adoptPlan(planId: string): Promise<PlanApiResponse<PlanDetailData>> {
    const body: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    body.planId = planId
    return this.httpService.put<PlanDetailData>('/plans/active', body, this.getAuthHeaders())
  }
  private localDate(): string {
    const now = new Date()
    return `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`
  }
  private timezone(): string { return Intl.DateTimeFormat().resolvedOptions().timeZone }
  async getDailyProgress(planId: string): Promise<PlanApiResponse<DailyResponse>> {
    return this.httpService.get<DailyResponse>(`/plans/${planId}/daily?date=${this.localDate()}&timezone=${encodeURIComponent(this.timezone())}`, this.getAuthHeaders())
  }
  async completeDailyStep(planId: string, period: string, step: number, completed: boolean): Promise<PlanApiResponse<DailyResponse>> {
    const body: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    body.date = this.localDate()
    body.timezone = this.timezone()
    body.period = period
    body.step = step
    body.completed = completed
    return this.httpService.put<DailyResponse>(`/plans/${planId}/daily/steps`, body, this.getAuthHeaders())
  }

  /**
   * 创建个性化护肤方案
   * @param planData 方案创建数据
   * @returns Promise<PlanApiResponse<PlanDetailData>>
   */
  async createPlan(planData: CreatePlanRequest): Promise<PlanApiResponse<PlanDetailData>> {
    console.log('===== 🎯 创建个性化护肤方案 =====')
    console.log(`📡 API请求: 创建方案`)

    const headers = this.getAuthHeaders()
    
    // 转换为 Record 类型以符合 HttpService 的要求
    const bodyRecord: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    if (planData.requirement) {
      bodyRecord.requirement = planData.requirement
    }
    if (planData.skinConcerns && planData.skinConcerns.length > 0) {
      bodyRecord.skinConcerns = planData.skinConcerns
    }
    if (planData.customRequirements) {
      bodyRecord.customRequirements = planData.customRequirements
    }
    if (planData.age) {
      bodyRecord.age = planData.age
    }

    const response = await this.httpService.post<PlanDetailData>(
      '/plans',
      bodyRecord,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 方案创建成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 创建方案失败:', response.message)
    return {
      success: false,
      message: response.message || '创建方案失败'
    }
  }

  /**
   * 获取用户的所有护肤方案
   * @returns Promise<PlanApiResponse<PlanListData>>
   */
  async getAllPlans(): Promise<PlanApiResponse<PlanListData>> {
    console.log('===== 📚 获取所有护肤方案 =====')
    console.log(`📡 API请求: 获取方案列表`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<PlanListData>(
      '/plans',
      headers
    )

    if (response.success && response.data) {
      const plans = response.data.plans || []
      console.log('✅ 方案列表获取成功')
      console.log(`📊 方案数量: ${plans.length}`)
      
      return {
        success: true,
        data: response.data,
        count: response.data.count || plans.length
      }
    }

    console.error('❌ 获取方案列表失败:', response.message)
    return {
      success: false,
      message: response.message || '获取方案列表失败'
    }
  }

  /**
   * 获取单个护肤方案详情
   * @param planId 方案ID
   * @returns Promise<PlanApiResponse<PlanDetailData>>
   */
  async getPlan(planId: string): Promise<PlanApiResponse<PlanDetailData>> {
    console.log('===== 🔍 获取方案详情 =====')
    console.log(`📡 API请求: 获取方案详情`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<PlanDetailData>(
      `/plans/${planId}`,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 方案详情获取成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取方案详情失败:', response.message)
    return {
      success: false,
      message: response.message || '获取方案详情失败'
    }
  }

  /**
   * 删除护肤方案
   * @param planId 方案ID
   * @returns Promise<PlanApiResponse<Record<string, string>>>
   */
  async deletePlan(planId: string): Promise<PlanApiResponse<Record<string, string>>> {
    console.log('===== 🗑️ 删除护肤方案 =====')
    console.log(`📡 API请求: 删除方案`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.delete<Record<string, string>>(
      `/plans/${planId}`,
      headers
    )

    if (response.success) {
      console.log('✅ 方案删除成功')
      return {
        success: true
      }
    }

    console.error('❌ 删除方案失败:', response.message)
    return {
      success: false,
      message: response.message || '删除方案失败'
    }
  }

  /**
   * 更新方案步骤完成状态
   * @param planId 方案ID
   * @param updateData 更新数据
   * @returns Promise<PlanApiResponse<PlanDetailData>>
   */
  async updateStepCompleted(planId: string, updateData: UpdateStepRequest): Promise<PlanApiResponse<PlanDetailData>> {
    console.log('===== ✅ 更新步骤完成状态 =====')
    console.log(`📡 API请求: 更新步骤状态`)

    const headers = this.getAuthHeaders()
    
    // 转换为 Record 类型
    const bodyRecord: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    bodyRecord.period = updateData.period
    bodyRecord.step = updateData.step
    bodyRecord.completed = updateData.completed

    // 使用 request 方法而不是 patch，因为 patch 方法的类型限制
    const response = await this.httpService.request<PlanDetailData>(
      `/plans/${planId}/step`,
      {
        method: 'PATCH',
        body: bodyRecord,
        headers: headers
      }
    )

    if (response.success && response.data) {
      console.log('✅ 步骤状态更新成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 更新步骤状态失败:', response.message)
    return {
      success: false,
      message: response.message || '更新步骤状态失败'
    }
  }
}
