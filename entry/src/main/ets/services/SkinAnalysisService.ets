import { FileService, FileUploadResponse, FileUploadResponseData } from './FileService'
import { ImagePickerService, ImagePickerResult } from './ImagePickerService'
import { SkinAnalysisApiService, SkinAnalysisData, AnalysisHistoryData, AnalysisDetailData } from './SkinAnalysisApiService'
import { common } from '@kit.AbilityKit'

/**
 * 皮肤分析响应
 */
export interface SkinAnalysisResponse {
  success: boolean
  data?: SkinAnalysisData
  message?: string
}

/**
 * 分析历史响应
 */
export interface AnalysisHistoryResponse {
  success: boolean
  data?: AnalysisHistoryData
  message?: string
}

/**
 * 删除分析记录响应接口
 */
export interface DeleteAnalysisResponse {
  success: boolean
  message?: string
}

/**
 * Skin Analysis Service
 * 皮肤分析业务逻辑层,整合文件上传和API调用
 */
export class SkinAnalysisService {
  private static instance: SkinAnalysisService | null = null
  private fileService: FileService
  private imagePickerService: ImagePickerService
  private apiService: SkinAnalysisApiService

  private constructor() {
    this.fileService = FileService.getInstance()
    this.imagePickerService = ImagePickerService.getInstance()
    this.apiService = SkinAnalysisApiService.getInstance()
  }

  static getInstance(): SkinAnalysisService {
    if (SkinAnalysisService.instance === null) {
      SkinAnalysisService.instance = new SkinAnalysisService()
    }
    return SkinAnalysisService.instance
  }

  /**
   * 从相册选择图片并分析
   * @param context 应用上下文
   * @param onProgress 进度回调
   * @returns Promise<SkinAnalysisResponse>
   */
  async analyzeFromGallery(
    context?: common.UIAbilityContext,
    onProgress?: (progress: number, status: string) => void
  ): Promise<SkinAnalysisResponse> {
    console.log('===== 🖼️ 从相册选择并分析 =====')

    // 1. 选择图片 (不显示进度,因为用户可能取消)
    const pickResult = await this.imagePickerService.selectFromGallery(context)

    if (!pickResult.success || !pickResult.filePath) {
      return {
        success: false,
        message: pickResult.message || '选择图片失败'
      }
    }

    // 2. 用户已选择图片,现在开始显示进度并上传分析
    if (onProgress) {
      onProgress(20, '正在上传图片到云端...')
    }

    // 3. 上传并分析
    return this.analyzeImage(pickResult.filePath, onProgress)
  }

  /**
   * 拍照并分析
   * @param context 应用上下文(必需)
   * @param onProgress 进度回调
   * @returns Promise<SkinAnalysisResponse>
   */
  async analyzeFromCamera(
    context: common.UIAbilityContext,
    onProgress?: (progress: number, status: string) => void
  ): Promise<SkinAnalysisResponse> {
    console.log('===== 📷 拍照并分析 =====')

    if (!context) {
      return {
        success: false,
        message: '无法获取应用上下文'
      }
    }

    // 1. 拍照
    if (onProgress) {
      onProgress(10, '正在拍照...')
    }
    const photoResult = await this.imagePickerService.takePhoto(context)

    if (!photoResult.success || !photoResult.filePath) {
      return {
        success: false,
        message: photoResult.message || '拍照失败'
      }
    }

    // 2. 上传并分析
    return this.analyzeImage(photoResult.filePath, onProgress)
  }

  /**
   * 分析图片
   * @param imagePath 图片路径
   * @param onProgress 进度回调
   * @returns Promise<SkinAnalysisResponse>
   */
  async analyzeImage(
    imagePath: string,
    onProgress?: (progress: number, status: string) => void
  ): Promise<SkinAnalysisResponse> {
    console.log('===== 🔬 开始皮肤分析 =====')
    console.log(`📁 图片路径: ${imagePath}`)

    try {
      // 1. 上传图片
      if (onProgress) {
        onProgress(20, '正在上传图片到云端...')
      }
      console.log('📤 步骤1: 上传图片')

      const uploadResponse = await this.fileService.uploadImageForAnalysis(imagePath)

      if (!uploadResponse.success) {
        console.error('❌ 上传失败:', uploadResponse.message)
        return {
          success: false,
          message: uploadResponse.message || '上传图片失败'
        }
      }

      console.log('✅ 图片上传成功')
      console.log(`📊 上传响应: ${JSON.stringify(uploadResponse.data)}`)

      // 2. 从上传响应中获取分析结果
      // 根据Vue项目的实现,上传接口直接返回分析结果
      if (uploadResponse.data) {
        // 检查响应中是否包含分析数据
        const analysisData = uploadResponse.data as FileUploadResponseData
        
        // 如果响应中包含analysisId,需要再次获取详情
        if (analysisData.analysisId || analysisData._id) {
          if (onProgress) {
            onProgress(80, '正在获取分析结果...')
          }
          
          const analysisId = analysisData.analysisId || analysisData._id
          if (!analysisId) {
            return {
              success: false,
              message: '无法获取分析ID'
            }
          }
          const detailResponse = await this.apiService.getAnalysisDetail(analysisId)
          
          if (detailResponse.success && detailResponse.data?.analysis) {
            if (onProgress) {
              onProgress(100, '分析完成！')
            }
            console.log('✅ 分析完成')
            return {
              success: true,
              data: detailResponse.data.analysis
            }
          }
        } else if (analysisData.overallAssessment || analysisData.skinType) {
          // 如果响应中直接包含分析数据
          if (onProgress) {
            onProgress(100, '分析完成！')
          }
          console.log('✅ 分析完成')
          return {
            success: true,
            data: analysisData as SkinAnalysisData
          }
        }
      }

      // 3. 如果上传响应中没有分析结果,尝试获取最新分析
      if (onProgress) {
        onProgress(90, '正在获取分析结果...')
      }
      
      const latestResponse = await this.apiService.getLatestAnalysis()
      if (latestResponse.success && latestResponse.data?.analysis) {
        if (onProgress) {
          onProgress(100, '分析完成！')
        }
        console.log('✅ 分析完成')
        return {
          success: true,
          data: latestResponse.data.analysis
        }
      }

      return {
        success: false,
        message: '无法获取分析结果'
      }
    } catch (error) {
      console.error('❌ 分析过程异常:', JSON.stringify(error))
      return {
        success: false,
        message: `分析失败: ${error}`
      }
    }
  }

  /**
   * 获取分析历史
   * @param page 页码
   * @param limit 每页数量
   * @returns Promise<AnalysisHistoryResponse>
   */
  async getHistory(page: number = 1, limit: number = 10): Promise<AnalysisHistoryResponse> {
    console.log('===== 📚 获取分析历史 =====')
    
    const response = await this.apiService.getAnalysisHistory(page, limit)
    
    if (response.success && response.data) {
      return {
        success: true,
        data: response.data
      }
    }

    return {
      success: false,
      message: response.message || '获取历史记录失败'
    }
  }

  /**
   * 获取分析详情
   * @param analysisId 分析ID
   * @returns Promise<SkinAnalysisResponse>
   */
  async getDetail(analysisId: string): Promise<SkinAnalysisResponse> {
    console.log('===== 🔍 获取分析详情 =====')
    
    const response = await this.apiService.getAnalysisDetail(analysisId)
    
    if (response.success && response.data?.analysis) {
      return {
        success: true,
        data: response.data.analysis
      }
    }

    return {
      success: false,
      message: response.message || '获取分析详情失败'
    }
  }

  /**
   * 删除分析记录
   * @param analysisId 分析ID
   * @returns Promise<DeleteAnalysisResponse>
   */
  async deleteAnalysis(analysisId: string): Promise<DeleteAnalysisResponse> {
    console.log('===== 🗑️ 删除分析记录 =====')
    
    const response = await this.apiService.deleteAnalysis(analysisId)
    
    const result: DeleteAnalysisResponse = {
      success: response.success
    }
    if (response.message) {
      result.message = response.message
    }
    return result
  }
}

