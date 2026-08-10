# AIskin3 源码与仓库安全审计报告

- 仓库：`EaseLearnAI/harmonyos_AIskin`
- 审计分支：`codex/app-store-readiness`（从 `main` 新建，`main` 目前只有 1 个提交）
- 审计范围：源码与仓库安全审计。**本次不进行 AppGallery 提交**，也未生成签名 Release HAP（见文末说明）。
- 审计日期：2026-08-10

---

## 结论速览

| 检查项 | 结论 |
|---|---|
| 移除 READ_IMAGEVIDEO，改用系统 PhotoViewPicker | ✅ 通过 |
| AI 生成内容标识 | ⚠️ 部分通过（有标签，无逐次同意/无结果页免责声明） |
| 非医疗声明 | ⚠️ 部分通过（仅存在于注册页条款全文，结果页未复现） |
| 隐私政策 / 用户协议 | ⚠️ 部分通过（注册时展示，登录后无法再次查看） |
| 注销（删除账户）入口 | ❌ 不存在 |
| 证书 / 私钥 / 签名密码残留 | 🔴 严重：当前代码中即存在 |
| build 产物 / node_modules 残留 | 🔴 严重：当前代码中即存在 |
| 签名 Release HAP | ❌ 未生成，本环境不具备 DevEco Studio / HarmonyOS SDK |

---

## 1. READ_IMAGEVIDEO 权限 / PhotoViewPicker

**结论：当前代码已正确移除，通过。**

- `entry/src/main/module.json5` 的 `requestPermissions` 中**只声明了 `ohos.permission.INTERNET`**，未声明 `ohos.permission.READ_IMAGEVIDEO`（也未声明 `WRITE_IMAGEVIDEO`）。
- 相册选择逻辑在 `entry/src/main/ets/services/ImagePickerService.ets` 中，使用的是系统级 `picker.PhotoViewPicker`（来自 `@ohos.file.picker`），属于免权限的系统选择器，符合"不申请相册受限权限、改用系统选择器"的要求。

**遗留问题（非风险，但会误导后续开发）：**
- `doc/相册.md`、`doc/皮肤分析API实现总结.md` 等文档中仍大量引用 `ohos.permission.READ_IMAGEVIDEO` / `WRITE_IMAGEVIDEO` 的旧实现方案。这些文档不影响当前 `module.json5` 的实际权限声明，但若后续开发者按文档"抄作业"，有把该权限重新加回去的风险。建议在文档顶部标注"已废弃，现方案见 ImagePickerService.ets”或直接删除过时段落。

摄像头拍照功能（`takePhoto`）目前是未实现的占位代码，直接返回失败，因此当前也未声明 `CAMERA` 权限，逻辑自洽。

---

## 2. AI 生成内容标识 / 同意 / 非医疗声明

**结论：三项均有雏形，但都不完整，需要在结果页补齐。**

- **AI 标识**：结果卡片上有明确文案，如 `AIRecommendations.ets` 中的"AI智能护肤建议"、`HealthScoreCard.ets` 中的"AI肌肤健康评分""基于深度学习智能分析"。这部分构成了基本的"内容由 AI 生成"标识。
- **非医疗声明**：仅存在于 `entry/src/main/ets/utils/DocumentContent.ets` 的《使用条款》长文本第 6 条"免责声明"里："本应用提供的分析报告仅供参考，不构成医疗诊断，不应替代专业医生或皮肤科建议。"该文本只在**注册流程**（`RegisterView.ets` / `RegisterForm.ets`）中以模态框展示一次。
  - 我检查了皮肤分析结果相关组件（`HealthScoreCard.ets`、`AIRecommendations.ets`、`SkinAnalysisHeader.ets`、`SkinStatusOverview.ets`、`SkinTypeAnalysis.ets`）以及成分分析、冲突检测相关组件（`ingredient/`、`conflict/`），**没有任何一处在展示 AI 结果时复现"仅供参考/非医疗建议"字样**。用户如果直接跳过注册时的条款阅读（只是勾选同意），此后使用产品全程不会再看到非医疗声明。
- **同意（Consent）**：`RegisterForm.ets` 中有"我已阅读并同意《隐私政策》"的强制勾选框，这是**账户层面的一次性同意**，覆盖的是整体服务条款。但没有找到**针对"上传人脸照片交给 AI 处理"这一具体行为的单独同意步骤**——`SkinDetectionWelcome.ets`（拍照/选图入口页）只有"AI智能分析，专业护肤建议"的宣传语，没有拍照前的二次确认或同意勾选。

**建议（供参考，未实施）：**
1. 在结果展示页（至少 `HealthScoreCard`/`AIRecommendations`）加一条常驻小字："本结果由 AI 生成，仅供参考，不构成医疗诊断"。
2. 在首次拍照/上传照片前增加一次轻量确认（例如底部弹窗"我了解该结果由 AI 生成，仅供护肤参考"），而不是仅依赖注册时的一次性勾选。

---

## 3. 隐私政策 / 用户协议 / 注销入口

- **隐私政策与用户协议文本**：存在且内容详实，位于 `entry/src/main/ets/utils/DocumentContent.ets`（`TERMS_OF_USE` 与 `PRIVACY_POLICY`），涵盖收集信息范围、使用方式、存储保护、用户权利、未成年人保护等条款，符合应用商店对政策文本完整性的基本要求。政策文本中还写明用户拥有"删除权""随时……删除账户"的权利。
- **访问入口**：目前只在**注册流程**（`RegisterView.ets` 第 78 行链接到"隐私政策"）中可查看。**登录后的"我的"页面（`ProfileView.ets` + `SettingsMenu.ets`）没有隐私政策/用户协议入口**——`SettingsMenu` 只有"消息通知""主题设置""帮助与反馈""关于我们"四项，不含政策链接。多数应用商店（含 AppGallery）要求政策在应用内可随时查阅，仅在注册时展示一次通常不满足审核要求。
- **注销（账户删除）入口：不存在。**
  - `ProfileView.ets` 中只有"退出登录"（logout）按钮，调用 `AuthService.logout()`。
  - `AuthApiService.ets` / `AuthService.ets` 只实现了 `login`、`register`、`getCurrentUser`（`fetchCurrentUser`），**没有任何 `deleteAccount` / 注销相关方法**，后端接口层面也未见调用。
  - 隐私政策文本承诺的"随时……删除账户"权利，在产品功能上**没有对应实现**，属于政策与实现不一致，也是目前最直接会导致上架审核被拒的问题之一（凡是允许应用内注册账号的应用，几乎都强制要求提供应用内自助注销能力）。

---

## 4. 证书 / 私钥 / 签名密码 / build 产物 / node_modules 残留

**这是本次审计发现的最严重问题，且是"当前代码问题"，不是仅存在于历史提交中的旧问题。**

### 4.1 签名证书与私钥文件已被提交（当前 HEAD 即存在）

```
doc/password/AIskin3/AIskin3          # 数据文件（很可能是私钥相关材料）
doc/password/AIskin3/AIskin3.p12      # PKCS#12 证书+私钥（keystore）
doc/password/AIskin3/AIskin3.cer      # 签名证书
doc/password/AIskin3/AIskin3.csr      # 证书签名请求
doc/password/AIskin3/AIskin3Release.p7b  # 签名 Profile（PKCS#7）
doc/password/AIskin3/material/...     # 相关材料文件
```

这些文件通过 `git ls-files` 可直接确认为**已跟踪（tracked）**文件，也就是说它们不是"历史遗留、现在已经删除"，而是**此刻就存在于工作区和 HEAD 提交中**。

### 4.2 签名密码明文（加密串）写入根目录配置文件

`build-profile.json5`（仓库根目录，当前已跟踪）：

```json5
"material": {
  "storeFile": "/Users/terry/Desktop/tmp/password/AIskin3/AIskin3.p12",
  "storePassword": "0000001B8FE61EBDAB1377DC034A0DD72CBD227152A2AF24BF47387F4B3EB71960536FD042094286404B0A",
  "keyAlias": "AIskin3",
  "keyPassword": "0000001B59B6008B354FD324574BADFFEDFB861DAF3378E2369FA02722386F924CC6374E9B55CF73962ACE",
  "signAlg": "SHA256withECDSA",
  "profile": "/Users/terry/Desktop/tmp/password/AIskin3/AIskin3Release.p7b",
  "certpath": "/Users/terry/Desktop/tmp/password/AIskin3/AIskin3.cer"
}
```

`storePassword` / `keyPassword` 是 DevEco Studio 加密后的密码串（与本机 DevEco 安装绑定的可逆加密，非哈希），**理论上可被同版本 DevEco Studio 解密使用**。结合 4.1 中同一目录下已提交的 `.p12` 私钥、`.cer` 证书、`.p7b` 签名 Profile，等于**签名所需的四要素（私钥、证书、签名 Profile、密码）在仓库中全部齐备**，任何能访问该仓库的人理论上都可以用这套材料对篡改后的应用重新签名并冒充官方发布。这是**严重（Critical）安全问题**。

### 4.3 已编译/已签名的构建产物被提交

```
build/outputs/default/AIskin3-default-signed.app     # 已用上述证书签名的发布包
build/outputs/default/AIskin3-default-unsigned.app
build/outputs/default/symbol/release/app-symbol.zip
build/outputs/default/pac.json
build/outputs/default/pack.info
```

构建产物不应进入源码仓库，且 `AIskin3-default-signed.app` 恰恰是用已泄露证书签出的成品包，进一步印证证书材料是"可用、已被使用"的，而非无效的历史文件。

### 4.4 依赖目录整包提交，且根目录无 .gitignore

- 仓库**根目录没有 `.gitignore` 文件**。唯一的 `.gitignore` 在 `entry/.gitignore`，内容仅为：
  ```
  /node_modules
  /oh_modules
  /.preview
  /build
  /.cxx
  /.test
  ```
  这只能忽略 `entry/` 目录下的同名子目录，**管不到仓库根目录的 `node_modules/`、`oh_modules/`、`build/`**。
- 实测：根目录 `node_modules/` 下 388 个文件、`oh_modules/` 下 85 个文件、根 `build/` 下 6 个文件均被 `git` 跟踪，是当前 HEAD 的一部分。
- 附带问题：`.DS_Store` 文件也被大量跟踪（`doc/`、`entry/`、`node_modules/`、`oh_modules/` 下均有），侧面说明该仓库从未配置过有效的忽略规则。

### 4.5 附带发现：测试脚本中的明文账号密码

`test_api_connection.js` 与 `test_skin_analysis_api.js`（仓库根目录）中硬编码：

```js
const TEST_PHONE = '15691887650';
const TEST_PASSWORD = '12345678';
```

且请求目标是**生产环境**接口 `https://www.lunzo.site/api`（非本地/测试环境地址）。这是一个真实手机号 + 弱密码的明文组合，指向线上生产服务，属于中等风险的信息泄露（个人信息 + 弱口令），建议改为从环境变量读取，并确认该账号是否为专用测试账号、是否需要在生产库中禁用/轮换密码。

---

## 5. "当前代码问题" vs "Git 历史证书泄露问题" 的区分

**关键事实：本仓库当前只有 1 个提交。**

```
$ git rev-list --all | wc -l
1
$ git log --all --oneline
f420059 Initial commit: HarmonyOS AI Skin Analysis Project
```

因此，与常见场景（"证书早期误传，后来已删除，只是历史里还留着"）不同，**本仓库不存在"当前已清理、只是历史里有"的情况**——第 4 节列出的证书、私钥、签名密码、build 产物、node_modules 目前**同时是"当前代码问题"和"全部 Git 历史"**，二者是同一件事，因为压根只有这一个提交，没有更早的、更干净的版本可以回退。

这对整改方式有直接影响：

1. **仅仅在新提交里删除这些文件是不够的。** 即使之后提交一个"移除证书"的 commit，`doc/password/AIskin3/*`、`build-profile.json5` 里的密码串、`build/outputs/*` 仍然完整保留在 `f420059` 这个初始提交里，任何 `git clone` 该仓库、或已经 fork/拉取过的人都能通过 `git show f420059:build-profile.json5` 之类的命令直接取出。要做到"从仓库中真正抹去"，需要重写历史（如 `git filter-repo` 或 BFG Repo-Cleaner）并强制推送，且所有已有克隆都需要重新获取，这是一个有破坏性、需要单独授权确认的操作，**本次审计不会自动执行**。
2. **删除文件不能替代吊销/轮换证书。** 因为该证书私钥、签名 Profile、密码已经**实际存在于（哪怕只有一次）公开可达的提交历史中**，必须视为已泄露，无论今后是否清理仓库，都建议：
   - 在 AppGallery Connect 中作废/重新生成新的签名证书、CSR、Profile；
   - 用新证书重新签名后续发布包；
   - 旧的 `AIskin3.p12` / `AIskin3.cer` / `AIskin3Release.p7b` 不应再用于任何正式签名。
3. 由于历史与当前是同一个提交，**本报告不区分"历史遗留问题"和"当前代码问题"两张单子**——它们就是同一份清单（见第 4 节）。若日后仓库有了更多提交、且有人曾经"删除后又保留在旧 commit 里"，才需要单独区分这两类问题；目前不适用。

---

## 6. 关于签名 Release HAP 与"具备提交条件"的说明

**本次审计运行环境中没有安装 DevEco Studio，也没有配置 HarmonyOS SDK**（`$HOS_SDK_HOME` 为空，系统内未找到 DevEco / HarmonyOS SDK 相关目录，也没有 `hvigorw` 可执行文件）。

因此：

- 本次审计**只做了静态源码/仓库检查**，没有执行、也无法执行 `hvigorw` 构建流程。
- **未生成任何签名 Release HAP**（仓库里已有的 `build/outputs/default/AIskin3-default-signed.app` 是历史遗留产物，不是本次审计生成的，且如第 4.3 节所述，它本身就是需要被清理、用泄露证书签出的问题文件，不能作为"可提交"的凭证）。
- 本报告**不代表、也不得被解读为"当前版本具备 AppGallery 提交条件"**。是否具备提交条件，除代码问题外还取决于：使用未泄露的新证书重新签名、隐私/协议/注销等合规项整改完成、并在具备 DevEco Studio + HarmonyOS SDK 的环境中实际构建验证。这些均超出本次"仅源码与仓库安全审计"的范围，未执行。

---

## 附：问题清单与建议优先级

| 优先级 | 问题 | 位置 |
|---|---|---|
| 🔴 严重 | 私钥/证书/签名 Profile 提交到仓库 | `doc/password/AIskin3/*` |
| 🔴 严重 | 签名密码写入可跟踪的配置文件 | `build-profile.json5` |
| 🟠 高 | 已签名/未签名构建产物入库 | `build/outputs/default/*` |
| 🟠 高 | 根目录 node_modules / oh_modules 整包入库，且无根 .gitignore | 根目录 |
| 🟠 高 | 无应用内自助注销（账户删除）功能，与隐私政策承诺不符 | `ProfileView.ets` / `AuthApiService.ets` |
| 🟡 中 | 隐私政策/用户协议登录后不可查阅，仅注册时展示一次 | `SettingsMenu.ets` |
| 🟡 中 | 非医疗免责声明未在 AI 结果页复现，仅存在于注册条款全文中 | `HealthScoreCard.ets` 等结果组件 |
| 🟡 中 | 拍照/上传照片前无针对 AI 处理的单独同意步骤 | `SkinDetectionWelcome.ets` |
| 🟡 中 | 测试脚本硬编码真实手机号+弱密码，指向生产 API | `test_api_connection.js`、`test_skin_analysis_api.js` |
| 🟢 低 | `.DS_Store` 等无关文件被跟踪 | 多处 |
| 🟢 低 | 文档仍引用已废弃的 READ_IMAGEVIDEO 方案，易误导后续开发 | `doc/相册.md` 等 |

以上问题均为**发现与记录**，本次未做任何修改/删除/历史重写操作，是否整改、以何种方式整改（尤其是证书轮换与历史重写这类不可逆操作）需用户明确授权后再执行。
