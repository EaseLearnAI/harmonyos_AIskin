# 冷启动登录恢复对齐

基准为 iOS `9f69aa9` 的 `AIskin/Core/Authentication/SessionStore.swift`：初始化调用 `restorePersistedSession()`，凭据由 CredentialStore 保存，用户快照独立保存。原鸿蒙 `AuthService` 只读写 AppStorage，进程退出后丢失登录状态，因此每次冷启动回到引导/登录是明确的交互缺口。

本次实现由 `services/AuthSessionStore.ets` 唯一负责持久化。令牌和精简用户快照写入 AssetStore 的单条 SECRET，读取条件为 `DEVICE_FIRST_UNLOCKED`、同步策略为 `NEVER`。别名包含 API base URL，开发环境与正式环境互不恢复对方的会话。SECRET 最大 1024 字节；超出时先省略可从 `/users/me` 恢复的可选用户字段，仍超出则明确返回登录保存失败。头像不写入该离线快照。

`preferences` 仅保存 boolean 退出标记，不存令牌、用户快照或密码。登录先持久化禁止恢复标记，安全资产写入和解除标记均成功才发布登录状态；解除标记失败会尝试删除新资产并恢复标记。退出先保存标记再删除安全资产：删除暂时失败但标记已落盘时，冷启动仍不能恢复旧会话；两项都失败则提示退出未完成。注销账户成功后也走同一清理路径。AppStorage 仅为进程内状态映射，普通用户 JSON 不再重复包含 token。

`EntryAbility.onCreate` 注入系统 Context；`Index` 使用已有 `AISkinStateView` 显示恢复、读取失败与重试。在读取安全会话后，`AuthService.restoreSession()` 调用真实 `/users/me` 刷新用户信息。网络异常和服务器错误不删除原有效会话；只有实际 HTTP 401 才清理。`HttpService.statusCode` 与 `AuthApiService` 透传状态码，避免靠错误文案中是否含“401”推断。登录、注册、用户读取和年龄更新使用会话代次，退出后的迟到响应不能重新写入账户。401 清理失败保留拒绝标记并阻止该会话在本进程重试时绕过清理。

引导已看标记保持原逻辑。iOS 当前源码没有独立持久化的 hasSeenOnboarding：有会话恢复主界面，无会话走登录内引导。此次不新增“看过引导后永久跳过”的另一套产品行为。

API 20 本地 SDK 核对范围：`@kit.AssetStoreKit` 中 `asset.addSync/querySync/removeSync` 为 API 12 起，`@kit.ArkData` 的 `preferences.getPreferencesSync` 为 API 10/11 起、`flushSync` 为 API 14 起；`BusinessError` 从 `@kit.BasicServicesKit` 导出。`Tag.IS_PERSISTENT` 的含义是卸载后保留资产，本次没有设置，也没有因此申请 `STORE_PERSISTENT_DATA`。SECRET 长度与属性依据 [华为关键资产更新文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/asset-js-update-V5) 和本机 SDK 的 `@ohos.security.asset.d.ts` 核对。

回归入口为 `node --test scripts/tests/auth-session-regression.test.cjs`。这些测试执行实际服务类的业务代码，对 Asset/Preferences/HTTP 注入明确的测试桩；它们验证持久化协议、错误分支和迟到响应，不证明系统加密实现、ArkUI 渲染或设备冷启动已通过。原生构建、安装、冷启动与实际 `/users/me` 请求的运行结果以主任务验收记录为准。

2026-09-15 原生补充：最终实现已在 API20 模拟器安装运行，完成真实登录、强制停止后无操作恢复首页、/me 200、断网冷启保留登录、退出后冷启回引导。production 与 local 包互不恢复对方会话，切回无预填 local 包仍恢复原本地账号。具体截图/日志见 [原生验收](frontend-evidence/session-native-verification.json)。这不扩展为真机、真实令牌过期、系统故障注入均已验证。
