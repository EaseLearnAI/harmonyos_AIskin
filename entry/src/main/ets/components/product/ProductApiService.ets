import { HttpService } from '../../services/HttpService'
import { AuthService } from '../../services/AuthService'
import http from '@ohos.net.http'
import fs from '@ohos.file.fs'
import { ApiConfig } from '../../services/ApiConfig'

/**
 * 产品数据接口
 */
export interface ProductData {
  _id?: string
  id?: string
  name?: string
  description?: string
  label?: string
  imageUrl?: string
  ingredients?: string[]
  safetyScore?: number
  efficacyScore?: number
  overallRating?: number
  openingDate?: string
  createdAt?: string
  updatedAt?: string
}

/**
 * 创建产品请求接口
 */
export interface CreateProductRequest {
  name: string
  description?: string
  label?: string
}

/**
 * 更新产品请求接口
 */
export interface UpdateProductRequest {
  name?: string
  description?: string
  label?: string
  openingDate?: string
}

/**
 * 产品列表响应数据
 */
export interface ProductListData {
  products?: ProductData[]
  count?: number
}

/**
 * 产品详情响应数据
 */
export interface ProductDetailData {
  product?: ProductData
}

/**
 * 提取成分响应数据
 */
export interface ExtractIngredientsData {
  name?: string
  ingredients?: string[]
  rawContent?: string
}

/**
 * 上传图片响应数据
 */
export interface UploadImageData {
  imageUrl?: string
}

/**
 * API响应接口
 */
export interface ProductApiResponse<T> {
  success: boolean
  data?: T
  message?: string
  count?: number
}

/**
 * Product API Service
 * 处理产品相关的API调用
 */
export class ProductApiService {
  private static instance: ProductApiService | null = null
  private httpService: HttpService
  private authService: AuthService
  private httpRequest: http.HttpRequest

  private constructor() {
    this.httpService = HttpService.getInstance()
    this.authService = AuthService.getInstance()
    this.httpRequest = http.createHttp()
  }

  static getInstance(): ProductApiService {
    if (ProductApiService.instance === null) {
      ProductApiService.instance = new ProductApiService()
    }
    return ProductApiService.instance
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
   * 将字符串转换为Uint8Array
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
   */
  private async readFileAsArrayBuffer(filePath: string): Promise<ArrayBuffer> {
    try {
      console.log(`📁 读取文件: ${filePath}`)
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
      console.error('❌ 读取文件失败:', JSON.stringify(error))
      throw new Error(`读取文件失败: ${error}`)
    }
  }

  /**
   * 创建产品
   */
  async createProduct(productData: CreateProductRequest): Promise<ProductApiResponse<ProductDetailData>> {
    console.log('===== 📦 步骤1: 创建产品 =====')
    console.log(`📋 产品名称: ${productData.name}`)
    console.log(`📝 产品描述: ${productData.description || '无'}`)
    console.log(`🏷️ 产品标签: ${productData.label || '无'}`)

    const headers = this.getAuthHeaders()
    const body: CreateProductRequest = {
      name: productData.name,
      description: productData.description || '这是一个用于成分分析的产品',
      label: productData.label || ''
    }

    // 转换为 Record 类型以符合 HttpService 的要求
    const bodyRecord: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    bodyRecord.name = body.name
    bodyRecord.description = body.description || ''
    bodyRecord.label = body.label || ''

    const response = await this.httpService.post<ProductDetailData>(
      '/products',
      bodyRecord,
      headers
    )

    if (response.success && response.data) {
      const productId = response.data.product?._id || response.data.product?.id
      console.log(`✅ 产品创建成功！产品ID: ${productId}`)
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 创建产品失败:', response.message)
    return {
      success: false,
      message: response.message || '创建产品失败'
    }
  }

  /**
   * 上传产品图片
   */
  async uploadProductImage(productId: string, imagePath: string): Promise<ProductApiResponse<UploadImageData>> {
    console.log('===== 📷 步骤2: 上传产品图片 =====')
    console.log(`🆔 产品ID: ${productId}`)
    console.log(`📁 图片路径: ${imagePath}`)

    try {
      // 读取文件
      const fileBuffer = await this.readFileAsArrayBuffer(imagePath)
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

      // 构建multipart/form-data请求体
      const boundary = '----WebKitFormBoundary' + Date.now()
      const fieldName = 'productImage'
      const fileName = `product_${Date.now()}.jpg`
      const contentType = 'image/jpeg'

      // 构建multipart/form-data请求体
      const formDataParts: Uint8Array[] = []

      // 添加文件字段
      const fileHeader = `--${boundary}\r\nContent-Disposition: form-data; name="${fieldName}"; filename="${fileName}"\r\nContent-Type: ${contentType}\r\n\r\n`
      const fileHeaderBytes = this.stringToUint8Array(fileHeader)
      formDataParts.push(fileHeaderBytes)

      // 添加文件内容
      formDataParts.push(new Uint8Array(fileBuffer))

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
      const uploadHeaders: Record<string, string> = {} as Record<string, string>
      uploadHeaders['Authorization'] = `Bearer ${token}`
      uploadHeaders['Content-Type'] = `multipart/form-data; boundary=${boundary}`

      const url = ApiConfig.getApiUrl(`/products/${productId}/upload-image`)
      console.log(`🔗 上传URL: ${url}`)
      console.log(`📦 请求方法: POST`)
      console.log(`📋 请求头: ${JSON.stringify(uploadHeaders)}`)

      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: uploadHeaders,
        extraData: combinedBuffer,
        connectTimeout: 120000,
        readTimeout: 120000
      }

      console.log('📡 发送上传请求...')
      const response = await this.httpRequest.request(url, requestOptions)

      console.log(`✅ 收到响应`)
      console.log(`📊 状态码: ${response.responseCode}`)

      interface ApiResponse {
        success?: boolean
        data?: UploadImageData
        message?: string
      }

      let responseData: ApiResponse = {}
      try {
        const responseBody = response.result.toString()
        responseData = JSON.parse(responseBody) as ApiResponse
        console.log(`📦 响应数据: ${JSON.stringify(responseData)}`)
      } catch (parseError) {
        console.error('❌ 解析响应失败:', JSON.stringify(parseError))
        return {
          success: false,
          message: '服务器响应格式错误'
        }
      }

      if (response.responseCode >= 200 && response.responseCode < 300) {
        if (responseData.success) {
          const imageUrl = responseData.data?.imageUrl
          console.log(`✅ 图片上传成功！图片URL: ${imageUrl}`)
          return {
            success: true,
            data: responseData.data || {}
          }
        } else {
          console.error('❌ 上传失败:', responseData.message)
          return {
            success: false,
            message: responseData.message || '上传图片失败'
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
      console.error('❌ 文件上传异常:', JSON.stringify(error))
      return {
        success: false,
        message: `上传失败: ${error}`
      }
    }
  }

  /**
   * 提取产品成分
   */
  async extractIngredients(productId: string): Promise<ProductApiResponse<ExtractIngredientsData>> {
    console.log('===== 🔬 步骤3: 提取产品成分 =====')
    console.log(`🆔 产品ID: ${productId}`)

    const headers = this.getAuthHeaders()
    const emptyBody: Record<string, string> = {} as Record<string, string>
    const response = await this.httpService.post<ExtractIngredientsData>(
      `/products/${productId}/extract-ingredients`,
      emptyBody,
      headers
    )

    if (response.success && response.data) {
      const ingredients = response.data.ingredients || []
      console.log(`✅ 成分提取成功！`)
      console.log(`📋 产品名称: ${response.data.name || '未知'}`)
      console.log(`📋 成分数量: ${ingredients.length}`)
      console.log(`📋 成分列表: ${ingredients.join(', ')}`)
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 提取成分失败:', response.message)
    return {
      success: false,
      message: response.message || '提取成分失败'
    }
  }

  /**
   * 获取用户产品列表
   */
  async getUserProducts(userId: string): Promise<ProductApiResponse<ProductListData>> {
    console.log('===== 📚 加载用户产品列表 =====')
    console.log(`📊 用户ID: ${userId}`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<ProductListData>(
      `/products/user/${userId}`,
      headers
    )

    if (response.success && response.data) {
      const products = response.data.products || []
      console.log(`✅ 产品列表加载成功，共${products.length}个产品`)
      return {
        success: true,
        data: response.data,
        count: response.data.count || products.length
      }
    }

    console.error('❌ 获取产品列表失败:', response.message)
    return {
      success: false,
      message: response.message || '获取产品列表失败'
    }
  }

  /**
   * 获取产品详情
   */
  async getProduct(productId: string): Promise<ProductApiResponse<ProductDetailData>> {
    console.log('===== 🔍 获取产品详情 =====')
    console.log(`🆔 产品ID: ${productId}`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.get<ProductDetailData>(
      `/products/${productId}`,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 获取产品详情成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 获取产品详情失败:', response.message)
    return {
      success: false,
      message: response.message || '获取产品详情失败'
    }
  }

  /**
   * 删除产品
   */
  async deleteProduct(productId: string): Promise<ProductApiResponse<Record<string, string>>> {
    console.log('===== 🗑️ 删除产品 =====')
    console.log(`🆔 产品ID: ${productId}`)

    const headers = this.getAuthHeaders()
    const response = await this.httpService.delete<Record<string, string>>(
      `/products/${productId}`,
      headers
    )

    if (response.success) {
      console.log('✅ 删除产品成功')
      return {
        success: true
      }
    }

    console.error('❌ 删除产品失败:', response.message)
    return {
      success: false,
      message: response.message || '删除产品失败'
    }
  }

  /**
   * 更新产品
   */
  async updateProduct(productId: string, updateData: UpdateProductRequest): Promise<ProductApiResponse<ProductDetailData>> {
    console.log('===== ✏️ 更新产品 =====')
    console.log(`🆔 产品ID: ${productId}`)
    console.log(`📋 更新数据: ${JSON.stringify(updateData)}`)

    const headers = this.getAuthHeaders()
    // 转换为 Record 类型以符合 HttpService 的要求
    const bodyRecord: Record<string, Object | string | number | boolean> = {} as Record<string, Object | string | number | boolean>
    if (updateData.name !== undefined) {
      bodyRecord.name = updateData.name
    }
    if (updateData.description !== undefined) {
      bodyRecord.description = updateData.description
    }
    if (updateData.label !== undefined) {
      bodyRecord.label = updateData.label
    }
    if (updateData.openingDate !== undefined) {
      bodyRecord.openingDate = updateData.openingDate
    }

    const response = await this.httpService.put<ProductDetailData>(
      `/products/${productId}`,
      bodyRecord,
      headers
    )

    if (response.success && response.data) {
      console.log('✅ 更新产品成功')
      return {
        success: true,
        data: response.data
      }
    }

    console.error('❌ 更新产品失败:', response.message)
    return {
      success: false,
      message: response.message || '更新产品失败'
    }
  }
}

