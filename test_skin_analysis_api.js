#!/usr/bin/env node

/**
 * 皮肤分析API测试脚本
 * 测试前后端交互,验证服务器连接和数据存储
 */

const axios = require('axios')
const https = require('https')

// 配置
const API_BASE_URL = 'https://www.lunzo.site/api'
const TEST_PHONE = '15691887650'
const TEST_PASSWORD = '12345678'

// 颜色输出
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
}

function log(level, message, data = null) {
  const timestamp = new Date().toISOString()
  const colorMap = {
    'INFO': colors.cyan,
    'SUCCESS': colors.green,
    'ERROR': colors.red,
    'WARN': colors.yellow,
    'STEP': colors.blue
  }
  const color = colorMap[level] || colors.reset
  console.log(`${color}[${timestamp}] [${level}]${colors.reset} ${message}`)
  if (data) {
    console.log(JSON.stringify(data, null, 2))
  }
}

// 创建axios实例
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  httpsAgent: new https.Agent({
    rejectUnauthorized: false // 允许自签名证书
  })
})

let authToken = ''

/**
 * 步骤1: 登录获取token
 */
async function step1_login() {
  log('STEP', '===== 步骤1: 用户登录 =====')
  log('INFO', `📡 请求URL: ${API_BASE_URL}/users/login`)
  log('INFO', `📋 请求方法: POST`)
  log('INFO', `📦 请求体:`, {
    phone: TEST_PHONE,
    password: TEST_PASSWORD
  })

  try {
    const response = await apiClient.post('/users/login', {
      phone: TEST_PHONE,
      password: TEST_PASSWORD
    })

    log('SUCCESS', `✅ 登录成功`)
    log('INFO', `📊 状态码: ${response.status}`)
    log('INFO', `📦 响应数据:`, response.data)

    if (response.data && response.data.token) {
      authToken = response.data.token
      log('SUCCESS', `🔑 Token获取成功: ${authToken.substring(0, 20)}...`)
      return true
    } else {
      log('ERROR', `❌ 响应中未找到token`)
      return false
    }
  } catch (error) {
    log('ERROR', `❌ 登录失败: ${error.message}`)
    if (error.response) {
      log('ERROR', `📊 状态码: ${error.response.status}`)
      log('ERROR', `📦 响应数据:`, error.response.data)
    }
    return false
  }
}

/**
 * 步骤2: 获取当前用户信息
 */
async function step2_getUserInfo() {
  log('STEP', '===== 步骤2: 获取当前用户信息 =====')
  log('INFO', `📡 请求URL: ${API_BASE_URL}/users/me`)
  log('INFO', `📋 请求方法: GET`)
  log('INFO', `📦 请求头:`, {
    'Authorization': `Bearer ${authToken.substring(0, 20)}...`
  })

  try {
    const response = await apiClient.get('/users/me', {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    })

    log('SUCCESS', `✅ 获取用户信息成功`)
    log('INFO', `📊 状态码: ${response.status}`)
    log('INFO', `📦 响应数据:`, response.data)
    return response.data
  } catch (error) {
    log('ERROR', `❌ 获取用户信息失败: ${error.message}`)
    if (error.response) {
      log('ERROR', `📊 状态码: ${error.response.status}`)
      log('ERROR', `📦 响应数据:`, error.response.data)
    }
    return null
  }
}

/**
 * 步骤3: 获取分析历史
 */
async function step3_getAnalysisHistory() {
  log('STEP', '===== 步骤3: 获取分析历史 =====')
  log('INFO', `📡 请求URL: ${API_BASE_URL}/skin-analysis?page=1&limit=10`)
  log('INFO', `📋 请求方法: GET`)
  log('INFO', `📦 请求头:`, {
    'Authorization': `Bearer ${authToken.substring(0, 20)}...`
  })

  try {
    const response = await apiClient.get('/skin-analysis', {
      params: {
        page: 1,
        limit: 10
      },
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    })

    log('SUCCESS', `✅ 获取分析历史成功`)
    log('INFO', `📊 状态码: ${response.status}`)
    log('INFO', `📦 响应数据:`, response.data)

    if (response.data && response.data.data && response.data.data.analyses) {
      const analyses = response.data.data.analyses
      log('INFO', `📋 历史记录数量: ${analyses.length}`)
      if (analyses.length > 0) {
        log('INFO', `📋 最新记录:`, {
          id: analyses[0]._id,
          createdAt: analyses[0].createdAt,
          healthScore: analyses[0].overallAssessment?.healthScore
        })
      }
    }

    return response.data
  } catch (error) {
    log('ERROR', `❌ 获取分析历史失败: ${error.message}`)
    if (error.response) {
      log('ERROR', `📊 状态码: ${error.response.status}`)
      log('ERROR', `📦 响应数据:`, error.response.data)
    }
    return null
  }
}

/**
 * 步骤4: 获取最新分析
 */
async function step4_getLatestAnalysis() {
  log('STEP', '===== 步骤4: 获取最新分析 =====')
  log('INFO', `📡 请求URL: ${API_BASE_URL}/skin-analysis/latest`)
  log('INFO', `📋 请求方法: GET`)
  log('INFO', `📦 请求头:`, {
    'Authorization': `Bearer ${authToken.substring(0, 20)}...`
  })

  try {
    const response = await apiClient.get('/skin-analysis/latest', {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    })

    log('SUCCESS', `✅ 获取最新分析成功`)
    log('INFO', `📊 状态码: ${response.status}`)
    log('INFO', `📦 响应数据:`, response.data)
    return response.data
  } catch (error) {
    log('ERROR', `❌ 获取最新分析失败: ${error.message}`)
    if (error.response) {
      log('ERROR', `📊 状态码: ${error.response.status}`)
      log('ERROR', `📦 响应数据:`, error.response.data)
    }
    return null
  }
}

/**
 * 步骤5: 获取分析统计
 */
async function step5_getAnalysisStats() {
  log('STEP', '===== 步骤5: 获取分析统计 =====')
  log('INFO', `📡 请求URL: ${API_BASE_URL}/skin-analysis/stats`)
  log('INFO', `📋 请求方法: GET`)
  log('INFO', `📦 请求头:`, {
    'Authorization': `Bearer ${authToken.substring(0, 20)}...`
  })

  try {
    const response = await apiClient.get('/skin-analysis/stats', {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    })

    log('SUCCESS', `✅ 获取分析统计成功`)
    log('INFO', `📊 状态码: ${response.status}`)
    log('INFO', `📦 响应数据:`, response.data)
    return response.data
  } catch (error) {
    log('ERROR', `❌ 获取分析统计失败: ${error.message}`)
    if (error.response) {
      log('ERROR', `📊 状态码: ${error.response.status}`)
      log('ERROR', `📦 响应数据:`, error.response.data)
    }
    return null
  }
}

/**
 * 主测试函数
 */
async function runTests() {
  console.log('\n' + '='.repeat(60))
  console.log(colors.bright + colors.cyan + '🧪 皮肤分析API测试开始' + colors.reset)
  console.log('='.repeat(60) + '\n')

  log('INFO', `🔗 API服务器: ${API_BASE_URL}`)
  log('INFO', `📱 测试账号: ${TEST_PHONE}`)
  log('INFO', `🔑 测试密码: ${'*'.repeat(TEST_PASSWORD.length)}`)
  console.log('')

  // 步骤1: 登录
  const loginSuccess = await step1_login()
  if (!loginSuccess) {
    log('ERROR', '❌ 登录失败,终止测试')
    process.exit(1)
  }
  console.log('')

  // 步骤2: 获取用户信息
  const userInfo = await step2_getUserInfo()
  console.log('')

  // 步骤3: 获取分析历史
  const history = await step3_getAnalysisHistory()
  console.log('')

  // 步骤4: 获取最新分析
  const latest = await step4_getLatestAnalysis()
  console.log('')

  // 步骤5: 获取分析统计
  const stats = await step5_getAnalysisStats()
  console.log('')

  // 测试总结
  console.log('='.repeat(60))
  console.log(colors.bright + colors.green + '✅ 测试完成总结' + colors.reset)
  console.log('='.repeat(60))
  console.log(`登录: ${loginSuccess ? '✅ 成功' : '❌ 失败'}`)
  console.log(`获取用户信息: ${userInfo ? '✅ 成功' : '❌ 失败'}`)
  console.log(`获取分析历史: ${history ? '✅ 成功' : '❌ 失败'}`)
  console.log(`获取最新分析: ${latest ? '✅ 成功' : '❌ 失败'}`)
  console.log(`获取分析统计: ${stats ? '✅ 成功' : '❌ 失败'}`)
  console.log('='.repeat(60) + '\n')

  // 返回测试结果
  return {
    login: loginSuccess,
    userInfo: userInfo !== null,
    history: history !== null,
    latest: latest !== null,
    stats: stats !== null
  }
}

// 运行测试
if (require.main === module) {
  runTests()
    .then((results) => {
      const allPassed = Object.values(results).every(r => r === true)
      process.exit(allPassed ? 0 : 1)
    })
    .catch((error) => {
      log('ERROR', `❌ 测试执行异常: ${error.message}`)
      console.error(error)
      process.exit(1)
    })
}

module.exports = { runTests, step1_login, step2_getUserInfo, step3_getAnalysisHistory, step4_getLatestAnalysis, step5_getAnalysisStats }
