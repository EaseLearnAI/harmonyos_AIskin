# 析肤AI HarmonyOS 前端规则

## 依据与范围

本规则适用于 `entry/src/main/ets` 中的页面、业务组件、DesignSystem，以及主题资源。视觉和组件接口基准是 `EaseLearnAI/ios_AIskin3` 的 `9f69aa9`：`AGENTS.md`、`AIskin/DesignSystem`、`AIskin/Components` 和 `AIskin/Views`。不得只看某张原型截图而自行改版。

SwiftUI 组件不能直接在 ArkUI 导入；迁移时必须对应相同职责、语义参数、状态和内容插槽。平台特有能力使用真实 HarmonyOS 系统 API。手机号登录、系统选择器、系统文字渲染、Tab 材质与新增深色适配须单独标明，不能当作已经逐像素相同。

用户请求优先。没有明确要求时，不改变接口、业务数据流、导航关系和页面信息结构。

## 背景锁定

所有完整页面只使用 `design/AISkinTheme.ets` 的 `AISkinBackground`，由根页面提供；覆盖根页的独立整页可以复用同一个背景。不得在业务页创建白底、纯色底或新渐变。

基准：左上光晕 rgba(233,162,221,0.74)，中心14%/9%，32%淡出；右上 rgba(194,169,239,0.68)，91%/13%，34%淡出；中下 rgba(238,198,230,0.58)，65%/54%，42%淡出。底色 #EEE9F8 → #F6EFF7(58%) → #F9F8FB。组件调整不得改动这些锁定值。

## 强制复用：一处修改，全局生效

- `design/Foundation` 是数字 Token、字体角色、间距、圆角和动效的唯一来源。`base/dark/element/color.json` 的同名语义资源和 `AISkinColor` 是颜色唯一来源；图标的笔画颜色也必须读取这个 Token，不能藏在 SVG 中。
- `design` 是通用外观和基础组件接口的唯一来源。`components` 仅组合这些组件并绑定业务；`pages` 仅组织页面、路由和业务状态。
- 普通卡片只使用 `AISkinCard` / `CardStyle(role,state,inset)`。按钮只使用 `AISkinButton(variant,layout,isLoading,isEnabled,onAction)`；字段使用 `AISkinField`；标签使用 `AISkinTag`；目录和分段选择使用 `AISkinTabs`；状态使用 `AISkinStateView`；标题栏和底栏使用 `AISkinHeader` / `AISkinTabBar`。不能新建 New/Custom/V2 或页面私有副本。
- 通用 Text 使用 `TextStyle(role,tone)`；特殊业务报告的字体仍由对应 Foundation Token 及设计层组件集中实现。业务文件禁止裸字号、字重、颜色、圆角和阴影链。
- `components/common/AppHeader`、`Modal`、`ProcessingPanel` 等是约束明确的公共适配层。业务弹层必须复用 `Modal(content,footer,presentation,isBusy)`，不得重新实现遮罩/卡片容器；AI 处理统一使用 `AISkinProcessingScreen`。
- 同职责只保留一个实现。两处以上重复的品牌外观必须下沉；新增前先搜索 `design` 与 `components`。不直接暴露 RGB、圆角或阴影参数给业务调用方。
- 真实成功、警告、错误可用小面积语义色并同时给出文字/图标。禁止给普通产品分类、普通 Tab 或装饰分配蓝绿黄橙红色。
- 所有基础组件覆盖正常、按下、选中、禁用、加载和错误等适用状态。点击区域至少44 vp，保留长文滚动和无障碍标签；错误不得伪装成空数据或成功。
- 网络/平台 API 放在 service，不在设计层请求服务。预览样本必须明确标注，不得作为登录、真实模型或生产验证证据。

## 修改顺序与验收

1. 先盘点全页面重复实现，建立「iOS 组件 → 鸿蒙组件 → 调用位置」映射，写明当前差异。
2. 先改 Foundation 和共享组件，再一次性迁移所有调用页面；删除被替代的实现。
3. 运行 `python3 scripts/check-design-system.py`、`node --test scripts/tests/*.test.cjs`、`git diff --check` 和 `./scripts/build-local.sh production`，检查源码复用与 Release 包。
4. 使用 `./scripts/build-local.sh preview` 可在独立构建副本开启组件验收页；通过 `hdc shell aa start -a EntryAbility -b com.example.aiskin3 --ps aiskinPreview components` 打开。此开关在正式源码和 production 包始终为 false；不能用它替代真实页面验收。
5. 对照同一 iOS 提交，在本机模拟器逐页检查空、加载、有数据、错误，以及选择、保存、返回、弹层、深色。不能用编译成功代替运行检查。
6. 临时改一个颜色 Token 和一个基础卡片样式，验证组件验收页及多个实际业务页面同步变化，无需改业务文件；截图、记录后恢复，再构建复核。
7. 列明检查过的页面、未检查的页面、平台差异和失败项。未逐项验证不能说「全部检查」「一模一样」「完成1:1」。

## 本地运行及提交

启动服务前先检查现有进程和端口，只清理确认属于本项目的残留实例。优先复用已启动且版本/配置一致的服务；不在生产库放验收数据。Chrome 使用用户桌面已登录浏览器，不启动无头浏览器。

主分支已明确为 `main`。拉取最新 main 后在 `codex/` 分支提交并推送，更新 GitHub PR：英文标题、中文描述、完整影响面和验证证据。不得把构建产物、签名材料、账号密码或本地环境写入 Git；不得擅自合并、部署或提交应用商店。
