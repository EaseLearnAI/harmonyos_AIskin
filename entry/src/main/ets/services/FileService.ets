import http from '@ohos.net.http'
import fs from '@ohos.file.fs'
import { common } from '@kit.AbilityKit'
import { ApiConfig } from './ApiConfig'
import { AuthService } from './AuthService'

/**
 * 文件上传响应数据接口
 */
export interface FileUploadResponseData {
  url?: string
  filename?: string
  analysisId?: string
  _id?: string
  overallAssessment?: Record<string, Object>
  skinType?: Record<string, Object>
}

/**
 * 文件上传响应接口
 */
export interface FileUploadResponse {
  success: boolean
  data?: FileUploadResponseData
  message?: string
}

/**
 * 文件上传选项
 */
export interface FileUploadOptions {
  filePath: string
  fieldName?: string
  fileName?: string
  contentType?: string
  headers?: Record<string, string>
}

/**
 * 错误对象接口
 */
interface FileError {
  code?: number
  message?: string
}

/**
 * File Service
 * 处理文件上传相关功能
 */
export class FileService {
  private static instance: FileService | null = null
  private httpRequest: http.HttpRequest
  private authService: AuthService

  private constructor() {
    this.httpRequest = http.createHttp()
    this.authService = AuthService.getInstance()
  }

  static getInstance(): FileService {
    if (FileService.instance === null) {
      FileService.instance = new FileService()
    }
    return FileService.instance
  }

  /**
   * 将字符串转换为Uint8Array
   * @param str 字符串
   * @returns Uint8Array
   */
  private stringToUint8Array(str: string): Uint8Array {
    const arr = new Uint8Array(str.length)
    for (let i = 0; i < str.length; i++) {
      arr[i] = str.charCodeAt(i)
    }
    return arr
  }

  /**
   * 读取文件为ArrayBuffer
   * @param filePath 文件路径(完整路径或URI)
   */
  private async readFileAsArrayBuffer(filePath: string): Promise<ArrayBuffer> {
    try {
      // 检查是否是URI格式
      if (filePath.startsWith('file://')) {
        console.log('📋 检测到URI格式，尝试直接读取')
      }
      
      // 尝试读取文件
      const fileStat = fs.statSync(filePath)
      const fileSize = fileStat.size
      console.log(`📊 文件大小: ${fileSize} bytes`)
      
      const fileHandle = fs.openSync(filePath, fs.OpenMode.READ_ONLY)
      const buffer = new ArrayBuffer(fileSize)
      fs.readSync(fileHandle.fd, buffer)
      fs.closeSync(fileHandle)
      
      console.log(`✅ 文件读取成功`)
      return buffer
    } catch (error) {
      console.error('❌ 读取文件失败')
      // 如果是权限错误，提供更详细的错误信息
      const errorObj = error as FileError
      if (errorObj.code === 13900002) {
        throw new Error(`文件读取失败: 权限不足(错误码13900002)，请检查文件权限配置`)
      }
      throw new Error(`读取文件失败: ${error}`)
    }
  }

  /**
   * 上传文件到服务器
   * @param options 上传选项
   * @returns Promise<FileUploadResponse>
   */
  async uploadFile(options: FileUploadOptions): Promise<FileUploadResponse> {
    console.log('===== 📤 开始文件上传 =====')

    try {
      // 读取文件
      const fileBuffer = await this.readFileAsArrayBuffer(options.filePath)
      console.log(`📊 文件大小: ${fileBuffer.byteLength} bytes`)

      // 获取token
      const token = this.authService.getToken()
      if (!token) {
        console.error('❌ 未找到认证token')
        return {
          success: false,
          message: '未登录，请先登录'
        }
      }

      // 构建请求头
      const headers: Record<string, string> = {
        'Authorization': `Bearer ${token}`
      }
      // 合并自定义请求头
      if (options.headers) {
        const headerKeys = Object.keys(options.headers)
        for (let i = 0; i < headerKeys.length; i++) {
          const key = headerKeys[i]
          headers[key] = options.headers[key]
        }
      }

      // 构建multipart/form-data请求体
      // 注意: HarmonyOS的http模块需要特殊处理multipart/form-data
      const url = ApiConfig.getApiUrl('/skin-analysis/analyze')
      console.log(`📦 请求方法: POST`)

      // HarmonyOS的http模块不支持files字 段
      // 需要使用extraData构建multipart/form-data格式
      // 构建multipart/form-data边界
      const boundary = '----WebKitFormBoundary' + Date.now()
      const fieldName = options.fieldName || 'faceImage'
      const fileName = options.fileName || 'image.jpg'
      const contentType = options.contentType || 'image/jpeg'
      
      // 构建multipart/form-data请求体
      const formDataParts: Uint8Array[] = []
      
      // 添加文件字段
      // 注意: HarmonyOS不支持TextEncoder,需要手动转换字符串为Uint8Array
      const fileHeader = `--${boundary}\r\nContent-Disposition: form-data; name="${fieldName}"; filename="${fileName}"\r\nContent-Type: ${contentType}\r\n\r\n`
      const fileHeaderBytes = this.stringToUint8Array(fileHeader)
      formDataParts.push(fileHeaderBytes)
      
      // 添加文件内容
      formDataParts.push(new Uint8Array(fileBuffer))

      // 面部图片属于敏感信息，服务端仅在收到本次明确同意后处理。
      const consentField = `\r\n--${boundary}\r\nContent-Disposition: form-data; name="processingConsent"\r\n\r\ntrue`
      formDataParts.push(this.stringToUint8Array(consentField))
      
      // 添加结束边界
      const footer = `\r\n--${boundary}--\r\n`
      const footerBytes = this.stringToUint8Array(footer)
      formDataParts.push(footerBytes)
      
      // 合并所有部分
      let totalLength = 0
      for (let i = 0; i < formDataParts.length; i++) {
        totalLength += formDataParts[i].length
      }
      
      const combinedBuffer = new ArrayBuffer(totalLength)
      const combinedView = new Uint8Array(combinedBuffer)
      let offset = 0
      for (let i = 0; i < formDataParts.length; i++) {
        combinedView.set(formDataParts[i], offset)
        offset += formDataParts[i].length
      }
      
      // 设置请求头
      const uploadHeaders: Record<string, string> = {
        'Authorization': headers['Authorization'],
        'Content-Type': `multipart/form-data; boundary=${boundary}`
      }

      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: uploadHeaders,
        extraData: combinedBuffer,
        connectTimeout: 120000, // 2分钟超时
        readTimeout: 120000
      }

      console.log('📡 发送上传请求...')
      const response = await this.httpRequest.request(url, requestOptions)

      console.log(`✅ 收到响应`)
      console.log(`📊 状态码: ${response.responseCode}`)

      interface ApiResponse {
        success?: boolean
        data?: FileUploadResponseData
        message?: string
      }
      
      let responseData: ApiResponse = {}
      try {
        const responseBody = response.result.toString()
        responseData = JSON.parse(responseBody) as ApiResponse
      } catch (parseError) {
        console.error('❌ 解析响应失败')
        return {
          success: false,
          message: '服务器响应格式错误'
        }
      }

      if (response.responseCode >= 200 && response.responseCode < 300) {
        if (responseData.success) {
          console.log('✅ 文件上传成功')
          return {
            success: true,
            data: responseData.data || {}
          }
        } else {
          console.error('❌ 上传失败:', responseData.message)
          return {
            success: false,
            message: responseData.message || '上传失败'
          }
        }
      } else {
        console.error(`❌ HTTP错误: ${response.responseCode}`)
        return {
          success: false,
          message: responseData.message || `HTTP ${response.responseCode}`
        }
      }
    } catch (error) {
      console.error('❌ 文件上传异常')
      return {
        success: false,
        message: '上传失败，请重试'
      }
    }
  }

  /**
   * 上传图片并分析皮肤
   * @param imagePath 图片路径
   * @returns Promise<FileUploadResponse>
   */
  async uploadImageForAnalysis(imagePath: string): Promise<FileUploadResponse> {
    return this.uploadFile({
      filePath: imagePath,
      fieldName: 'faceImage',
      fileName: `skin_analysis_${Date.now()}.jpg`,
      contentType: 'image/jpeg'
    })
  }

  /**
   * 销毁HTTP请求实例
   */
  destroy(): void {
    this.httpRequest.destroy()
  }
}
