import picker from '@ohos.file.picker'
import fs from '@ohos.file.fs'
import { common } from '@kit.AbilityKit'

/**
 * 图片选择结果
 */
export interface ImagePickerResult {
  success: boolean
  filePath?: string
  uri?: string
  message?: string
}

/**
 * Image Picker Service
 * 处理图片选择(相册和摄像头)
 */
export class ImagePickerService {
  private static instance: ImagePickerService | null = null

  private constructor() {
    // Private constructor for singleton
  }

  static getInstance(): ImagePickerService {
    if (ImagePickerService.instance === null) {
      ImagePickerService.instance = new ImagePickerService()
    }
    return ImagePickerService.instance
  }

  /**
   * 从相册选择图片
   * @param context 应用上下文
   * @returns Promise<ImagePickerResult>
   */
  async selectFromGallery(context?: common.UIAbilityContext): Promise<ImagePickerResult> {
    console.log('===== 📁 从相册选择图片 =====')
    
    try {
      // 使用PhotoViewPicker API (注意: 这些API在某些版本可能已废弃,但当前仍可使用)
      // 如果编译报错,可能需要使用@kit.MediaLibraryKit中的新API
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new picker.PhotoViewPicker()
      console.log('📡 打开相册选择器...')
      
      const selectResult = await photoPicker.select(photoSelectOptions)
      
      if (selectResult && selectResult.photoUris && selectResult.photoUris.length > 0) {
        const photoUri = selectResult.photoUris[0]
        console.log(`✅ 已选择图片: ${photoUri}`)
        
        // 将图片复制到应用沙箱
        const sandboxPath = await this.copyToSandbox(photoUri, context)
        
        if (sandboxPath) {
          console.log(`📁 图片已复制到沙箱: ${sandboxPath}`)
          return {
            success: true,
            filePath: sandboxPath,
            uri: photoUri
          }
        } else {
          return {
            success: false,
            message: '复制图片到沙箱失败'
          }
        }
      } else {
        console.log('ℹ️ 用户取消选择')
        return {
          success: false,
          message: '未选择图片'
        }
      }
    } catch (error) {
      console.error('❌ 选择图片失败:', JSON.stringify(error))
      return {
        success: false,
        message: `选择图片失败: ${error}`
      }
    }
  }

  /**
   * 使用摄像头拍照
   * @param context 应用上下文(必需)
   * @returns Promise<ImagePickerResult>
   */
  async takePhoto(context: common.UIAbilityContext): Promise<ImagePickerResult> {
    console.log('===== 📷 使用摄像头拍照 =====')
    
    if (!context) {
      return {
        success: false,
        message: '无法获取应用上下文'
      }
    }
    
    try {
      // 注意: CameraPicker API在当前HarmonyOS版本中可能不可用
      // 根据文档,CameraPicker需要从@ohos.file.picker导入,但实际API可能不同
      // 这里暂时返回提示,建议使用相册选择功能
      // TODO: 实现正确的相机API调用
      // 需要使用@kit.CameraKit中的CameraManager和CameraSession来实现自定义相机
      // 或者等待HarmonyOS提供CameraPicker API的正式支持
      console.log('📡 打开系统相机...')
      console.log('⚠️ 相机功能暂未实现,请使用相册选择功能')
      return {
        success: false,
        message: '相机功能需要更新API实现,请使用相册选择功能'
      }
    } catch (error) {
      console.error('❌ 拍照失败:', JSON.stringify(error))
      return {
        success: false,
        message: `拍照失败: ${error}`
      }
    }
  }

  /**
   * 将图片URI复制到应用沙箱
   * @param uri 图片URI
   * @param context 应用上下文(可选)
   * @returns Promise<string | null> 沙箱文件路径
   */
  private async copyToSandbox(uri: string, context?: common.UIAbilityContext): Promise<string | null> {
    try {
      let appContext: common.UIAbilityContext | null = context || null
      
      if (!appContext) {
        console.error('❌ 无法获取应用上下文')
        return null
      }

      const timestamp = Date.now()
      const fileName = `skin_analysis_${timestamp}.jpg`
      const sandboxPath = `${appContext.cacheDir}/${fileName}`

      console.log(`📋 复制文件: ${uri} -> ${sandboxPath}`)

      // 方法1: 尝试直接使用fs.openSync(最简单的方法)
      // 注意: PhotoViewPicker返回的URI可能可以直接通过fs访问
      try {
        console.log('📡 尝试直接使用fs.openSync...')
        // 打开源文件(URI)
        const srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY)
        
        // 使用copyFileSync复制文件(从文件描述符到路径)
        fs.copyFileSync(srcFile.fd, sandboxPath)
        
        // 关闭源文件
        fs.closeSync(srcFile)
        
        console.log(`✅ 文件复制成功(使用copyFileSync)`)
        return sandboxPath
      } catch (copyError) {
        console.log(`⚠️ copyFileSync失败: ${JSON.stringify(copyError)}`)
        
        // 方法3: 手动读取和写入(备用方法)
        try {
          console.log('📡 尝试手动读取和写入...')
          // 打开源文件
          const srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY)
          
          // 获取文件大小
          const fileStat = fs.statSync(uri)
          const fileSize = fileStat.size
          console.log(`📊 文件大小: ${fileSize} bytes`)
          
          // 创建目标文件
          const destFile = fs.openSync(sandboxPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
          
          // 分块读取和写入(避免大文件内存问题)
          const chunkSize = 8192 // 8KB chunks
          let totalRead = 0
          
          while (totalRead < fileSize) {
            const remaining = fileSize - totalRead
            const currentChunkSize = Math.min(chunkSize, remaining)
            const buffer = new ArrayBuffer(currentChunkSize)
            
            // 读取数据
            const bytesRead = fs.readSync(srcFile.fd, buffer, {
              offset: totalRead,
              length: currentChunkSize
            })
            
            if (bytesRead > 0) {
              // 写入数据
              fs.writeSync(destFile.fd, buffer)
              totalRead += bytesRead
            } else {
              break
            }
          }
          
          // 关闭文件
          fs.closeSync(srcFile)
          fs.closeSync(destFile)
          
          console.log(`✅ 文件复制成功(手动复制),共${totalRead}字节`)
          return sandboxPath
        } catch (readWriteError) {
          console.error(`❌ 手动复制也失败: ${JSON.stringify(readWriteError)}`)
          // ArkTS要求throw必须抛出Error类型
          const errorMsg = readWriteError instanceof Error ? readWriteError.message : JSON.stringify(readWriteError)
          throw new Error(`文件复制失败: ${errorMsg}`)
        }
      }
    } catch (error) {
      console.error('❌ 复制文件失败:', JSON.stringify(error))
      return null
    }
  }
}

