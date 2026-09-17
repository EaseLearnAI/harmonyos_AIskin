# 第二轮前端对齐与原生验收

[打开双端原生截图对照](comparison.html)

2026-09-15。视觉与组件接口依据 iOS `main 9f69aa9`；服务端为 `main d17ebf0`。第一轮 `4359098` 的截图位于 `../review-evidence`，不代表本轮重建后的界面。

## 已完成的实现

- 阅读 iOS `AGENTS.md`，在鸿蒙根目录加入同职责规则；背景锁定，Foundation 为视觉数值唯一来源，共享组件通过语义参数及内容插槽复用。详见 [组件映射与差异](../ios-component-audit.md)。
- 首页、护肤柜、成分报告、冲突报告、肌肤概览/报告/历史、方案表单/预览/历史、个人中心、登录注册、引导均迁入共享体系。清除被替代的私有组件与固定颜色图标。
- 重建统一按钮、卡片、字段、标签、筛选、标题栏、底栏、状态、弹层、报告骨架、产品行、肌肤摘要与照片标注。公共卡片改用独立 borderColor/borderWidth，修复热切换后卡片边框停留在旧主题。修复原生 Builder 回调上下文导致的拍摄状态弹层崩溃，以及菜单绑定无响应、图标笔画缺失、安全区白条等运行问题。
- 方案来源报告返回保留已选目标；请求、删除、保存、关闭和离开页面采用失效保护。错误与真正的空记录分开。修复关闭方案后从个人中心返回又自动弹出的状态残留。
- 补上 iOS 已有的冷启动登录恢复：令牌与精简用户快照只写系统 AssetStore，普通偏好仅保存退出标记。真实 401 清理会话，网络失败保留；相机取消/失败关闭句柄并清理临时文件。实现细节见 [安全会话说明](../auth-session-alignment.md)。

## 证据的来源

`ios/` 是固定提交的干净源码副本在 iOS Simulator 中运行所得，业务数据为 iOS Mock。iOS build-for-testing 通过；既有部分 UI 测试因旧路径/门槛失败，未声称整套 UI 测试通过。

`harmony/` 是本机 HarmonyOS 6 / API 20 原生模拟器截图，1320×2856。使用本地 HTTP 服务、真实认证与独立 Mongo 测试库。产品、成分、肌肤与冲突的固定样本在正文明确标注「前端验收样本」，不能作为这些内容的真实 AI 识别证据。图片来自后端测试素材，没有使用个人照片。

`plan-preview-real.jpeg`、`plan-processing-final.jpeg` 与 [真实方案读取证据](real-plan-native.json) 对应在原生界面通过真实服务生成、采用方案，再完成首步打卡。它们使用样本产品及肤况作为输入，但方案内容由实际模型返回。后端再次读取 active 与 Daily 均为 200，首步已完成；Daily 实际时区为 `America/Chicago`，不能改用上海或 UTC 查询并声称成功。这两张生成过程截图早于最终安全区/组件细调。

## 原生检查范围

| 页面/流程 | 实际检查 | 证据及限制 |
|---|---|---|
| 首页与底栏 | 本地登录后加载、真实方案首步勾选回显、浅深切换、状态栏与底部安全区 | home-current-light / home-current-dark |
| 护肤柜 | 5 类筛选、完整产品行、空分类、原生更多菜单、编辑表单、返回、冲突选择 | cabinet-current-light/dark、cabinet-edit-current、cabinet-menu-final |
| 成分报告 | 功效/风险/建议/成分目录、信息编辑、日期选择、真实保存回显、浅深显示 | ingredient-current-light/dark；保存操作使用隔离样本 |
| 冲突报告与历史 | 从个人中心历史进入；单页滚动到全部建议和 AI 说明 | conflict-current-dark；本轮固定报告样本，第一轮真实 AI 长报告另存 |
| 肌肤报告与历史 | 概览、四项目录、照片标注滚动、两条历史、拍摄状态弹层打开/保存/返回 | skin-overview/report/context-current-dark；删除竞态另有受控 Promise 方法测试 |
| 定制方案 | 两项目标、来源报告进入/返回保留 2/3、个人状态、年龄保存、真实生成/采用 | plan-form-current-dark、plan-preview-real；未将方法测试混作每个并发场景的原生操作 |
| 个人中心 | 记录入口、个人信息、年龄编辑、账户安全入口及返回 | profile-current-dark；第一轮已验证一次性账号注销 |
| 无业务记录 | 首页、护肤柜、肌肤引导、方案前置条件与历史空态 | home-empty-dark、cabinet-empty-light/dark、skin-empty-dark、plan-gate/history-empty；只暂移隔离账号数据并完整恢复 |
| 断网与重试 | 移除模拟器至本地 5001 的映射后显示错误；恢复映射、点击重试后读取空态 | home-offline-error、home-retry-empty-light；服务端本身保持运行 |
| 系统相册 | 上传前说明、系统安全图库打开、取消回到原页面 | system-gallery-current；未接受输入法首次协议 |
| 系统相机 | 发起系统相机、失败后有错误提示 | 当前镜像缺少 `com.huawei.hmos.camera`，不能验证成功拍照；见 camera-unavailable.log 与截图 |
| 系统深色 | 从系统「深色模式→全天开启」实际打开，检查主要页面、表单、空态与图标；之后恢复浅色 | system-dark-enabled、theme-light-cold / theme-dark-hot / theme-light-hot-restored；同进程双向切换并检查表单标签，不依赖重启修复颜色 |
| 正式包引导/登录/注册 | production HAP 安装启动；三页引导不操作自动轮播；登录字段为空并能显示必填错误，注册表单可滚动到按钮 | release-onboarding-01/02/03、release-login-blank/validation、release-register-blank；未向生产提交账号或表单 |
| 登录恢复与退出 | 登录后进程 PID 6218→6258，未点击登录直接恢复首页，服务端 /me 200；断网冷启保留登录；退出后冷启回引导 | [原生会话证据](session-native-verification.json)；真实过期令牌的设备测试未执行，401 错误分支由受控响应测试覆盖 |

截图表示拍摄时的状态，不能证明所有机型、字号、屏幕阅读器、每个请求时序都已通过。Mate 60 / Pura 80 Pro+ / Mate X5 真机尚未连接。

## 一处修改、多个页面同步变化

在独立构建副本把一个全局强调色临时改为蓝色、把公共 `CardStyle` 圆角临时改为 0，重新编译安装，检查组件验收页、首页、护肤柜和肌肤页面均同步改变。`*-reuse-probe.jpeg` 是该实验的原生截图；41 个业务文件的哈希均未改变。之后两个源文件逐字节还原，再用正式源码重新构建，详见 [恢复校验](reuse-restoration.json)。

这证明上述实际页面使用同一颜色及卡片实现。实验在本轮中途进行，不能把实验布局当作最终外观，也不能推断未运行场景自动完成视觉验收。

## 可复现检查

```sh
python3 scripts/check-design-system.py
node --test scripts/tests/*.test.cjs
git diff --check
./scripts/build-local.sh production
```

结构检查覆盖 41 个业务文件与全前端 Builder 回调约束，核对 58 个 iOS 数值 Token 和 4 份素材原文件。它只能发现明确扫描的违规，不替代原生检查。源码提取回归覆盖方案、年龄、肌肤/首页竞态、相机临时资源和安全会话存取。它从当前 ArkTS 提取真实业务方法，平台/界面使用测试桩，具体覆盖见 `scripts/tests/README.md`。

最终运行：**61/61 方法回归通过**，结构扫描 0 项违规；严格颜色模式按预期返回 1，明确保留下面列出的 4 项差异。最终 production/release 构建成功，`module.json` 的 `debug=false`，包内存在正式 HTTPS 地址、不含本地接口及一次性测试账号/令牌；源副本预览开关为 false、登录字段为空。[构建校验及 SHA-256](build-verification.json)对应未签名 HAP，不能直接代表 AGC 可发布包。相关构建、扫描和测试日志随本目录保存。

## 仍有的对齐差异与上线条件

58 个已纳入检查的数值 Token、4 份图片素材与 iOS 一致；浅色语义颜色 18/22 一致。辅助文字、错误、警告、成功共 4 项为处理 Huawei 对比度意见而保留更深颜色；`--strict-parity` 会明确失败，不能声称所有颜色相同。系统字体、原生控件、底栏材质、手机号与 Apple 登录、系统相机/相册也有平台差异。尚未完成所有页面逐像素及指定真机验收，因此不能宣称全量 1:1。

上架仍需真实运营主体安全评估材料、有效发布签名和指定真机验证；代码与本地截图不能替代资质或审核通过。具体逐项状态见 [Huawei 整改说明](../华为2026-02-19最新审核整改说明.md)。没有执行发布、云部署、PR 合并或商店提交。

再次限定查找了当前项目、两个 DevEco 构建副本及本机常见签名配置目录，未找到匹配本应用的 release 配置/证书/profile。旧 `AIskin3-default-signed.app` 的内部 HAP 与 unsigned 包相同，SDK 验签提示无签名块，不能因文件名有 signed 就当作可用签名。SDK 附带的 OpenHarmony 通用材料不能替代本应用的 AGC 发布身份。

最终留在模拟器运行的是 `local` 构建：无内置测试凭据，组件预览关闭，通过系统安全存储恢复本地验收账号。服务端与图片服务保持在 127.0.0.1:5001 / 5002，系统为浅色。正式 release HAP 单独保存在本机证据目录，不加入 Git。
