import picker from '@ohos.file.picker'
import { common } from '@kit.AbilityKit'
import { camera, cameraPicker } from '@kit.CameraKit'
import { fileIo as fs, fileUri } from '@kit.CoreFileKit'

/**
 * 图片选择结果
 */
export interface ImagePickerResult {
  success: boolean
  filePath?: string
  uri?: string
  message?: string
}

interface ImagePickerError { code?: number }

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
        console.log('✅ 已选择图片')
        
        // 将图片复制到应用沙箱
        const sandboxPath = await this.copyToSandbox(photoUri, context)
        
        if (sandboxPath) {
          console.log('✅ 图片已复制到应用缓存')
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
      console.error('❌ 选择图片失败')
      return {
        success: false,
        message: '选择图片失败，请重试'
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
    
    let capturePath: string = ''
    let cleanupCapture: boolean = false
    try {
      console.log('📡 打开系统相机...')

      // 将系统相机拍摄结果直接写入应用缓存，不自动保存到系统相册。
      capturePath = `${context.cacheDir}/skin_capture_${Date.now()}.jpg`
      const captureFile = fs.createRandomAccessFileSync(capturePath, fs.OpenMode.CREATE)
      cleanupCapture = true
      // Only create the destination here; the camera and uploader open it independently.
      captureFile.close()
      const captureUri = fileUri.getUriFromPath(capturePath)
      const profile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT,
        saveUri: captureUri
      }

      const result = await cameraPicker.pick(
        context,
        [cameraPicker.PickerMediaType.PHOTO],
        profile
      )

      if (result.resultCode === 0 && result.resultUri) {
        console.log('✅ 拍照完成')
        // The caller still needs this file for upload; only unsuccessful captures belong to this cleanup.
        cleanupCapture = false
        return {
          success: true,
          filePath: capturePath,
          uri: result.resultUri
        }
      }

      const resultCode = Number.isFinite(result.resultCode) ? String(result.resultCode) : 'unknown'
      console.log(`ℹ️ 未完成拍照，resultCode=${resultCode}`)
      return {
        success: false,
        message: '未拍摄照片'
      }
    } catch (error) {
      const code = (error as ImagePickerError)?.code
      console.error(`❌ 拍照失败，errorCode=${typeof code === 'number' && Number.isFinite(code) ? code : 'unknown'}`)
      return {
        success: false,
        message: '拍照失败，请重试'
      }
    } finally {
      if (cleanupCapture) {
        try { fs.unlinkSync(capturePath) }
        catch (error) {
          const code = (error as ImagePickerError)?.code
          console.warn(`拍照临时文件清理失败，errorCode=${typeof code === 'number' && Number.isFinite(code) ? code : 'unknown'}`)
        }
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
      } catch (_copyError) {
        console.log('⚠️ 直接复制失败，尝试分块复制')
        
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
        } catch (_readWriteError) {
          console.error('❌ 分块复制失败')
          throw new Error('文件复制失败')
        }
      }
    } catch (error) {
      console.error('❌ 复制文件失败')
      return null
    }
  }
}
