# iOS → HarmonyOS 组件与页面审计

审计日期：2026-09-15。iOS 基准 `9f69aa94dde44d0d0e91fe16bb85b9df82156648`；鸿蒙整改前基准 `4359098f8b287769ff4e7fdb841a6bfefa969dd8`。下列位置属于这两个基准，后续整改会改变行号。本文是源码审计结果，不能替代模拟器交互、截图比对或全机型验收。

## 验收规则

已读取 `/Users/mac/Documents/ChatGPT/ios_aiskin/AGENTS.md`。第 34–36 行要求 Foundation Token、共享组件及默认/按下/选中/禁用/加载/错误状态；第 41–51 行要求同职责只有一个基础组件，业务页面只绑定数据与组合布局；第 62 行要求临时修改一个主题 Token 和一个基础组件，验证所有场景同步变化后恢复。存在共享文件本身不算复用完成。

整改前结论：鸿蒙已复用背景、颜色、部分卡片、三个主按钮入口、图标和预估处理面板，但尚未达到 iOS 强制复用架构，也没有完成逐页 1:1 验收。

## 结构盘点与目标接口

以下 iOS 路径以 `AIskin/` 为根，鸿蒙路径以 `entry/src/main/ets/` 为根。

| 职责 | iOS 共享入口/参数 | 鸿蒙整改前现状 | 迁移要求 |
| --- | --- | --- | --- |
| 视觉数值 | `DesignSystem/Foundation` 中 Color/Typography/Spacing/Radius/Layout/Motion 等 15 个文件 | `design/AISkinTheme.ets` 只有颜色与 6 个 Layout 数值，字体及大多数尺寸散在业务代码 | Foundation 成为唯一数值来源，按语义角色使用 |
| 卡片 | `AISkinCard(inset,state,role,content)`；content/feature/routine/overlay/action | 单一 `CardStyle`，统一 radius 24 和 shadow 12 | 同一 Card API 以角色表达表面与圆角，禁止页面覆盖 |
| 主次操作 | `AISkinButton(variant,layout,isLoading,action,label)`；Primary/Secondary/Surface/Destructive | `PrimaryButtonStyle` 只有 3 个调用，其他按钮逐页设计 | 所有普通操作迁移同一按钮，完整处理忙碌、禁用、按下 |
| 图标操作 | `AISkinIconButton(systemName,accessibilityLabel,variant,action)` | 每个 Header/历史/关闭入口重复 Button+宽高背景 | 共享 IconButton，保证可访问标签与点击区域 |
| 输入框 | `AISkinField(state,variant,content)`；Normal/Focused/Loading/Error | 登录、注册、标签编辑、方案输入各有修饰链 | 一个 Field 样式/接口，保留原生输入能力 |
| 标签/选择 | `AISkinTag(title,tone,state,size,variant,action)` | 分类及需求标签私有按钮；分类有多彩装饰圆点 | Neutral/Accent/Semantic tone，Selected/Disabled 状态，统一标签 |
| 标题栏 | `AISkinHeader(layout,leading,title,trailing)`；居中/左对齐双行 | `AppHeader` 与 `SkinAnalysisHeader` 两套，均缺 subtitle/slots | 单一 Header，业务组件组合左右按钮 |
| Tab/目录 | `AISkinTabBar`、SegmentedControl、UnderlineTabs、ReportAnchorBar | BottomNavigation 单一；Daily/Conflict/Ingredient 各自实现 | 底部导航与内容筛选分别共享，不逐页造样式 |
| 页面状态 | `AISkinStateView(content,actionTitle,action)` | 各页 Text/LoadingProgress/ErrorState | 同一 Loading/Empty/Error 状态组件 |
| 处理过程 | `AISkinProcessingScreen(title,message,detail,error,onRetry,onCancel)` + Panel | 仅共享 Panel，外层 scrim/header/cancel 分散 | 同一处理页面负责容器、取消与失败 |
| 报告容器 | `AISkinReportScreen(header,content,footer)` | 成分/冲突/肌肤各写固定区与滚动区 | 共享容器，不引入重复 Scroll |
| 底部操作 | `AISkinReportFooter(content)` | 每页重复底部padding/背景/边框 | 共享 footer，操作按钮复用 |
| 弹层 | `AISkinBottomSheet(title,detail,isBusy,contentLayout,onClose,content,footer)` | Modal 没有内容插槽；多页绕过它写 Stack | 一个有内容/操作插槽的容器，忙碌阻止关闭 |
| 产品行/图 | `AISkinProductRow(...,accessory)`、`AISkinProductThumbnail(url,size)` | ProductList 私有 ProductCard；报告 ProductInfo 独立 Image | 产品行与缩略图语义尺寸复用，附件操作不触发正文导航 |
| 功能入口 | `AISkinActionTile(title,subtitle,systemImage,action)` | CoreFeatures 私有 tile | 共享 action tile，卡片角色 Feature |
| 文本/分隔 | SectionHeading/SettingsRow/ReportTextItem/Divider | Profile/Report/history 重复字号、边距、分隔线 | 按职责提取复用，避免巨型组件 |

## 整改前问题清单（保留历史基准，不代表当前状态）

### P0：结构与复用不成立

1. **基础组件使用面不足。** 静态扫描全部 `pages`/`components`（含未引用的旧文件）发现裸 `fontSize` 324 处/43 文件、裸 `borderRadius` 94 处/30 文件、shadow 7 处/5 文件；CardStyle 43 次/29 文件，PrimaryButtonStyle 仅 3 次/3 文件。这是源码范围统计，不是运行路径覆盖率。
2. **肌肤报告结构不同。** iOS `Components/skin-analysis/SkinReportView.swift:31–40` 有问题/概览/建议/对比固定目录，`:114–123` 有照片观察结构，`:74–75` 有固定 footer。鸿蒙 `pages/SkinStatusView.ets:510–550` 为照片→总结→分数→肤质→问题→记录→建议长列，缺相应目录、照片观察图、固定定制方案入口。
3. **冲突报告多了一套信息架构。** iOS `Views/ConflictView.swift:71–90` 同页顺序展示总览、参与产品、冲突、建议、AI说明。鸿蒙 `pages/ConflictView.ets:26–29` 拆成搭配/建议两页签；标题也缺 iOS 的产品数副标题。
4. **护肤柜入口与选择方式不同。** iOS `Views/ProductView.swift:48–78` 空柜展示添加引导，非空展示 ProductList，添加可通过 Header；`:88–109` 在底部显示冲突选择提示/开始按钮。鸿蒙 `pages/ProductView.ets:54–63` 始终固定添加操作块，`:125–178` 顶部插入一套私有冲突卡片。
5. **成分报告操作结构不同。** iOS `Views/IngredientView.swift:117–137` 使用共享目录且有“和其他产品检查搭配”；`:202–214` footer 为删除图标与保存操作。鸿蒙 `pages/IngredientView.ets:100–106` 追加独立小结而无搭配入口，`:112–147` 等宽编辑/删除双按钮。
6. **个人中心缺子页面。** iOS `Views/ProfileView.swift:94–166` 有个人信息、账户与安全子页；`Views/PersonalInformationView.swift:40–57` 共享年龄编辑，校验 13–120。鸿蒙 `pages/ProfileView.ets:44–59` 把账户安全直接合入主页，缺个人信息/年龄的持久化入口。
7. **方案页面仍是独立旧弹窗。** iOS `Views/PersonalizedPlanView.swift:84–95` + `Components/plans/PlanInputForm.swift:16–84` 是完整页面，关联最近检测、最多 3 项目标、补充需求、可展开个人状态，年龄与账户共享。鸿蒙 `components/home/PersonalizedRoutineModal.ets:103–106` 固定 75% 弹窗，年龄本地输入，目标文案仍“美白”而非“提亮”，缺关联报告入口。

### P1：可见样式差异

- iOS `Foundation/AISkinRadius.swift:6–10` card 23、feature 24、routine 28、action 17、control 24；鸿蒙 `AISkinTheme.ets:35–57` card 一律 24，button 16。iOS `AISkinCard.swift:58–70` 内容卡无默认阴影，鸿蒙统一 shadow 12。不能只改颜色声称完成对齐。
- iOS Header 高度 64 / title 22 (`AISkinLayout.swift:14`, `AISkinTypography.swift:8`)；鸿蒙 AppHeader 标题 20 (`components/common/AppHeader.ets:25`)，SkinAnalysisHeader 单独高度 60、边距 16 (`:9–12`)。
- `components/product/ProductList.ets:7–16` 与 `TagSelector.ets:27–35` 重复分类，使用 warning/danger/success 与蓝绿十六进制装饰色，`:35`/`:113` 绘制分类圆点，违背紫黑单主题规则。
- `pages/HomeView.ets:124` 历史面板全屏纯 `AISkinColor.bottom`，覆盖锁定全局渐变。
- 鸿蒙引导页已复用原图、主要文案与 5 秒轮播，但 `pages/OnboardingView.ets:26–58` 仍硬编码完整样式，缺 iOS compactHeight/ReduceMotion/VoiceOver/拖动后延迟等控制 (`Views/LoginView.swift:62–94`)。
- 处理面板鸿蒙 padding32、gap24、更新200ms；iOS `AISkinProcessingPanel.swift:40–57` padding24、gap20，Foundation 更新100ms。鸿蒙还未复用 iOS 那层带取消/错误/重试的 ProcessingScreen。

## 平台差异与验证边界

- iOS `ContentView.swift:36` 强制浅色；鸿蒙跟随系统深色是华为整改扩展。应以浅色对照 iOS，深色单独验收对比度与完整组件覆盖。
- iOS 使用 Apple 登录、原生 iOS Tab/相机/相册；鸿蒙需原生可用的对应能力，不应复制不可用的 Apple 登录。系统字体栅格化、系统安全区域和平台原生控件不应宣称像素完全相同。
- iOS 会员/支付页存在；鸿蒙缺同等页面及对应平台支付链路，不能把其视为已经核验或擅自增加付费发布能力。
- 本文中的基准差异与扫描统计属于源码证据。本轮主任务进行了原生检查并据反馈修正，具体构建、操作、数据来源与截图范围由对应运行记录单独给出；不得把整改前截图或源码计数当作最新包的运行证明。

## 必需的复用与运行验收

1. 先完成上述基础 API，再批量迁移所有活跃页面；删除或明确移出遗留未引用组件，避免第二套视觉实现留在正式源码。
2. 以同一组业务数据逐页检查引导、登录、首页、空/非空护肤柜、成分、冲突、肌肤报告与历史、方案输入/预览/采用、个人中心与子页。
3. 每类基础组件检查正常、按下、选中、禁用、加载、失败/重试与长文本，浅色/深色、窄屏/大字体都需截图或交互证据。
4. 临时改 Accent Token 与 Card 默认外观，构建并验证各页同步变化；恢复后重新构建。源码扫描只能补充这项验收，不能替代它。

## 本轮源码迁移记录（不等同于运行验收）

产品、成分、冲突区域已按上表迁移到共享 `AISkinButton/Field/Tag/Tabs/StateView`、`Modal`、`AISkinProcessingScreen`。新增设计层 `AISkinReportComponents` 与 `AISkinProductThumbnail`，对应数值集中在 `Foundation/AISkinReportTokens`；报告分数按 iOS 的 scoreFirst/summaryFirst 语义变体区分。护肤柜空态与非空态分离，添加支持真实相机及相册，分类共享一份无装饰色定义；成分增加搭配入口、共享报告目录及保存反馈；冲突回归单页完整章节；无引用的旧 `ConflictAnalysis` 与虚构图片回退已移除。

引导页的三页素材与文案保持，视觉结构迁入 `AISkinOnboardingComponents`，尺寸/遮罩/动画值迁入 `Foundation/AISkinOnboardingTokens`。轮播在前台、无弹窗、无拖动、未开屏幕朗读时才推进；交互后重新等待五秒。iOS 风格 AI 说明由 `AISkinAIGeneratedNotice` 统一，华为要求的显式 AI 标签与人工反馈说明仍保留。

2026-09-15 本轮代码收敛后，`pages` 和 `components`（排除 Service）的裸数字字号、裸数字圆角、私有 shadow 和十六进制/rgba 色值搜索均为 0；`git diff --check` 通过。首次构建暴露的 ArkTS 回调推断、保留属性名、重复导入等已按编译器信息修复，最终构建与模拟器验证由本次运行记录提供，不能从此搜索结果推断通过。

仍需单独说明的差异：HarmonyOS API 20 的屏幕朗读查询/订阅已有对应实现；系统“减少动画”查询在已安装 SDK 中标为 API 23，不能声称本次 API 20 实现已经接入该设置。像素级跨平台相同、所有辅助功能状态和所有机型依旧需要对应证据。

本轮原生检查反馈后的进一步收敛：`AISkinReportScreen(header,anchor?,content,footer?)` 与 `AISkinReportFooter(content)` 已由设计层实现，成分、冲突及肌肤页面调用同一容器；传入含状态访问的 Builder 插槽使用 lambda，避免 ArkUI 更换接收方后错误绑定 `this`。产品上传、成分保存/删除、冲突检测新增本地返回与销毁/代次校验。取消图片处理会停止后续客户端阶段并忽略已在途请求的迟到响应，不代表服务端已接收的工作被撤销；已产生但未完成分析的产品可以从报告错误状态删除。

护肤柜进一步按 `Components/Product/ProductList.swift` 与 `DesignSystem/Components/AISkinProductRow.swift` 迁移：默认仅「全部 / 精华 / 面霜 / 防晒 / 洁面」下划线筛选，下面是数量与叠层图标操作；注册分类仍保留九类，二者职责分别定义。`design/AISkinProductRow.ets` 提供标题/摘要/类别/缩略图/主点击/accessory 插槽，卡片使用 16 vp 内边距、6 vp 文本间距和 112 vp 最小高度，不再额外显示开封日期。右上菜单为原生编辑/冲突/删除，附件和正文按钮是兄弟点击区域；编辑通过 `ProductView.onEditProduct` 与 `IngredientView.initialEditMode` 复用原产品编辑表单。缩略图改为与 iOS 一致的裁切填充，并区分加载、失败、无图片，避免使用引导插画冒充产品图片。菜单、编辑与选择操作的实际结果按主任务对应构建的原生运行记录核对。


## 本轮最终组件映射

此表记录本轮迁移后的职责/API与真实调用位置；上文“整改前”表格保留为对照历史。基础组件、业务适配和页面编排不再混写为同一层。

| iOS 职责 | 本轮 HarmonyOS 共享实现 | 调用位置与接口 |
| --- | --- | --- |
| Foundation / 语义颜色 | `design/Foundation/*Tokens.ets`、`AISkinTheme.ets`、base/dark同名颜色资源 | TextStyle(role,tone)、CardStyle(role,state,inset)；按职责集中报告/产品/引导/Toast数值 |
| Card / Button / Field / Tag / Tabs / StateView | `design/AISkinPrimitives.ets` | 产品、成分、冲突、首页、肌肤、认证、个人中心与表单均调用共享接口；按钮显式忙碌/禁用，字段错误/加载，标签选中/禁用，Tab语义变体 |
| Header / IconButton / TabBar | `AISkinPrimitives.ets`、`AISkinIcon.ets`、`AISkinTabBar.ets` | AppHeader与BottomNavigation为公共适配；产品附件以IconButton的tone/iconSize语义状态取Foundation数值 |
| ReportScreen / ReportFooter | `design/AISkinReportComponents.ets` | SkinStatusView、IngredientView、ConflictView → ReportScreen(header,anchor?,content,footer?)；肌肤/成分底部 → ReportFooter(content) |
| 报告章节 / 文本 / 评分 | `design/AISkinReportComponents.ets` | Heading(number,title,detail)、TextItem(title,text,style)、Score(label,score,summary,layout)；成分SummaryFirst、冲突ScoreFirst |
| ProductRow / ProductThumbnail | `AISkinProductRow.ets`、`AISkinProductThumbnail.ets` | ProductList → Row(title,summary,category,imageUrl,onSelect,accessory)；护肤柜/成分报告共用Thumbnail(Cabinet/Report) |
| 护肤柜分类与附件菜单 | `components/product/ProductList.ets`组合上述基础组件 | 五项Underline tabs；数量/叠层冲突按钮；系统菜单编辑/冲突/删除与正文为兄弟点击区 |
| Compact Toast | `design/AISkinToast.ets`、`Foundation/AISkinToastTokens.ets` | ProductView少于2件显示提示与关闭；至少2件显示232 vp最大宽度的单个开始检测按钮；顶部/系统返回仍可取消选择 |
| 产品编辑弹层 | `components/product/TagSelector.ets` + 公共`Modal` | ProductView.onEditProduct → IngredientView.initialEditMode；普通产品主点击只看报告；读取成功的草稿允许编辑/删除 |
| BottomSheet / Document / Confirm | `components/common/Modal.ets`、`DocumentModal.ets`、`DeleteConfirmModal.ets` | content/footer/presentation/isBusy插槽；阅读内容使用Scroll，保存/删除时阻止关闭与重复动作 |
| ProcessingScreen | `design/AISkinProcessingScreen.ets` + ProcessingPanel | 产品成分、冲突、肌肤、方案统一容器；取消和销毁后忽略迟到响应；不宣称撤销服务端已接收工作 |
| Onboarding | `AISkinOnboardingComponents.ets` | OnboardingView只提供页数据、交互/轮播状态；同一iOS素材，集中Slide/PageControl/AuthFooter结构 |
| AI生成说明 | `design/AISkinAIGeneratedNotice.ets` | AIContentNotice包装，所有报告复用同一AI标识与说明入口 |
| 首页操作 / 每日任务 / 方案内容 | `AISkinJourneyComponents.ets`、`AISkinPlanContent.ets`、`AISkinPlanInputComponents.ets` | CoreFeatures/DailyRoutine/方案输入与预览组合ActionTile、ChecklistRow、PlanContent、SourceRow/Goals/Requirements/PersonalStates |
| 个人中心结构 | `design/AISkinAccountComponents.ets` | ProfilePanel/ProfileIdentity/SettingsGroup/SettingsRow，ProfileView组织个人信息、账户安全、年龄和记录入口 |

本轮具体回归范围包括：产品上传、成分编辑/删除、冲突选择与检测的局部返回及迟到响应保护；肌肤来源页返回后刷新最近检测；成分分析读取失败不渲染默认0分报告，编辑失败保留输入，缺分析草稿提供删除出口。首页当前方案读取失败时显示重试，并保留此前读取成功的方案；只有请求完成、没有错误且确实无方案时才显示空态。openPlan进入请求在Home首次接收时回调消费，父级@Prop更新为false不会撤销本次已进入分支的prepare，也不会在个人中心返回后重复执行。Builder插槽使用保留所属页面上下文的lambda。此处是所列调用链的源码行为说明，静态检查、接口测试与原生运行证据分别记录，不代表全仓所有负向状态或跨平台像素完全相同。

冷启动交互另补 `AuthSessionStore` 安全资产存储与 `AuthService.restoreSession()`：恢复后校验 `/users/me`，真实 401 清理，网络失败保留会话；启动状态和失败重试仍使用 `AISkinStateView`。退出/注销复用同一持久化清理协议，未新增“已看引导”逻辑。实现边界和测试类型见 [冷启动登录恢复对齐](auth-session-alignment.md)，不能从源码推断系统安全存储与设备冷启动已经验收通过。
