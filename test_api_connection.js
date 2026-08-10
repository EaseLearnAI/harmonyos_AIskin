/**
 * API连接测试脚本
 * 用于测试前后端交互和MongoDB数据验证
 */

const API_BASE_URL = process.env.API_BASE_URL || 'https://www.lunzo.site/api';
const TEST_PHONE = process.env.TEST_PHONE;
const TEST_PASSWORD = process.env.TEST_PASSWORD;

if (!TEST_PHONE || !TEST_PASSWORD) {
  console.error('请通过环境变量 TEST_PHONE / TEST_PASSWORD 提供测试账号，不要在脚本中硬编码。');
  process.exit(1);
}

// 颜色输出辅助函数
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logStep(step, message) {
  log(`\n===== ${step} =====`, 'cyan');
  log(message, 'bright');
}

function logRequest(method, url, body = null) {
  log('📡 请求开始', 'blue');
  log(`🔗 URL: ${url}`, 'blue');
  log(`📋 Method: ${method}`, 'blue');
  if (body) {
    log(`📤 Request Body: ${JSON.stringify(body, null, 2)}`, 'blue');
  }
}

function logResponse(status, data) {
  log('✅ 收到响应', 'green');
  log(`📊 Status Code: ${status}`, 'green');
  log(`📦 Response Body: ${JSON.stringify(data, null, 2)}`, 'green');
}

function logError(message, error) {
  log('❌ 错误', 'red');
  log(`📋 Error Message: ${message}`, 'red');
  if (error) {
    log(`📦 Error Details: ${JSON.stringify(error, null, 2)}`, 'red');
  }
}

// 测试函数
async function testLogin() {
  logStep('🧪 测试登录', '使用测试账号登录');
  
  const url = `${API_BASE_URL}/users/login`;
  const body = {
    phone: TEST_PHONE,
    password: TEST_PASSWORD
  };

  logRequest('POST', url, body);

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    });

    const data = await response.json();
    
    if (response.ok && data.success) {
      logResponse(response.status, data);
      log(`✅ 登录成功！Token: ${data.token.substring(0, 20)}...`, 'green');
      return data.token;
    } else {
      logError('登录失败', data);
      return null;
    }
  } catch (error) {
    logError('网络请求失败', error);
    return null;
  }
}

async function testGetCurrentUser(token) {
  logStep('👤 获取当前用户信息', '使用token获取用户信息');
  
  const url = `${API_BASE_URL}/users/me`;
  
  logRequest('GET', url);
  log(`🔑 Token: ${token.substring(0, 20)}...`, 'blue');

  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });

    const data = await response.json();
    
    if (response.ok && data.success) {
      logResponse(response.status, data);
      log(`✅ 获取用户信息成功！`, 'green');
      log(`👤 用户ID: ${data.data.user._id}`, 'green');
      log(`📱 手机号: ${data.data.user.phone}`, 'green');
      log(`👤 用户名: ${data.data.user.name}`, 'green');
      log(`⚧️ 性别: ${data.data.user.gender}`, 'green');
      return data.data.user;
    } else {
      logError('获取用户信息失败', data);
      return null;
    }
  } catch (error) {
    logError('网络请求失败', error);
    return null;
  }
}

async function testRegister() {
  logStep('🔐 测试注册', '注册新用户（如果已存在会失败）');
  
  const url = `${API_BASE_URL}/users/register`;
  const testPhone = `1${Math.floor(Math.random() * 9000000000) + 1000000000}`;
  const body = {
    name: `测试用户_${Date.now()}`,
    phone: testPhone,
    password: '12345678',
    gender: 'female'
  };

  logRequest('POST', url, body);

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    });

    const data = await response.json();
    
    if (response.ok && data.success) {
      logResponse(response.status, data);
      log(`✅ 注册成功！`, 'green');
      log(`👤 用户ID: ${data.data.user._id}`, 'green');
      log(`📱 手机号: ${data.data.user.phone}`, 'green');
      return data.token;
    } else {
      logError('注册失败（可能是手机号已存在）', data);
      return null;
    }
  } catch (error) {
    logError('网络请求失败', error);
    return null;
  }
}

// 主测试函数
async function runTests() {
  log('\n' + '='.repeat(60), 'bright');
  log('🚀 开始API连接测试', 'bright');
  log('='.repeat(60) + '\n', 'bright');

  // 测试1: 登录
  const token = await testLogin();
  
  if (!token) {
    log('\n❌ 登录测试失败，无法继续后续测试', 'red');
    return;
  }

  // 测试2: 获取当前用户信息
  const user = await testGetCurrentUser(token);
  
  if (!user) {
    log('\n❌ 获取用户信息测试失败', 'red');
    return;
  }

  // 测试3: 注册（可选，可能会因为手机号已存在而失败）
  log('\n💡 提示: 注册测试可能会因为手机号已存在而失败，这是正常的', 'yellow');
  await testRegister();

  log('\n' + '='.repeat(60), 'bright');
  log('✅ 所有测试完成！', 'green');
  log('='.repeat(60) + '\n', 'bright');
  
  log('📝 下一步: 使用MCP工具验证MongoDB中的数据', 'cyan');
  log(`   查询条件: { phone: "${TEST_PHONE}" }`, 'cyan');
}

// 运行测试
if (typeof fetch !== 'undefined') {
  runTests().catch(error => {
    logError('测试执行失败', error);
    process.exit(1);
  });
} else {
  log('❌ 当前环境不支持fetch API，请使用Node.js 18+或浏览器环境运行', 'red');
  log('💡 提示: 可以使用 curl 命令手动测试:', 'yellow');
  log(`   curl -X POST ${API_BASE_URL}/users/login \\`, 'yellow');
  log(`     -H "Content-Type: application/json" \\`, 'yellow');
  log(`     -d '{"phone":"${TEST_PHONE}","password":"${TEST_PASSWORD}"}'`, 'yellow');
}





