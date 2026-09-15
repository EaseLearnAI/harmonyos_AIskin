# 前端业务状态回归

`flow-regression.test.cjs` 包含 34 项检查：方案与年龄 16 项、肌肤报告竞态 12 项、首页加载与方案入口 6 项。它读取当前检出的 `.ets` 业务方法，使用受控 Promise 验证返回顺序、失败、取消、重复操作和页面销毁；不会访问服务端、账号、设备或相册，也不会改写业务源码。

`image-picker-regression.test.cjs` 包含 8 项拍照临时资源检查，`auth-session-regression.test.cjs` 包含 19 项安全会话检查；三个文件合计 61 项。

## 运行

需要 Node.js 20 或更新版本，以及已经安装的 TypeScript。测试使用 Node 自带的 `node:test`，无需额外测试框架。

在仓库根目录运行全部检查：

```sh
node --test scripts/tests/*.test.cjs
```

只运行其中一组：

```sh
node --test --test-name-pattern='plan / age:' scripts/tests/flow-regression.test.cjs
node --test --test-name-pattern='skin race:' scripts/tests/flow-regression.test.cjs
node --test --test-name-pattern='home:' scripts/tests/flow-regression.test.cjs
node --test scripts/tests/image-picker-regression.test.cjs
node --test scripts/tests/auth-session-regression.test.cjs
```

源码路径相对于脚本所在的仓库解析，不取决于启动命令的工作目录。可以从其他目录向 `node --test` 传入本脚本的路径。

TypeScript 的查找顺序：

1. `AISKIN_TYPESCRIPT_PATH` 指定的编译器文件。显式路径无效会报错，不会静默回退。
2. 从当前仓库可以解析到的 `typescript` 模块。
3. macOS DevEco Studio 自带的编译器，应用位置取 `DEVECO_STUDIO_HOME`，默认 `/Applications/DevEco-Studio.app`，与现有构建脚本一致。

自定义 DevEco Studio 位置：

```sh
DEVECO_STUDIO_HOME='/path/to/DevEco-Studio.app' node --test scripts/tests/flow-regression.test.cjs
```

其他系统或独立安装的 TypeScript：

```sh
AISKIN_TYPESCRIPT_PATH='/path/to/typescript/lib/typescript.js' node --test scripts/tests/flow-regression.test.cjs
```

脚本不下载依赖，不依赖临时目录中的文件。执行时会输出实际使用的 TypeScript 版本。任何断言失败、源码提取失败或超时都会返回非零退出码；每项检查有 5 秒超时。

本次迁入时使用 Node.js 26.0.0、TypeScript 4.9.5，61 项全部通过。这是当时的执行记录，后续以重新运行结果为准。

## 如何执行真实业务方法

共享适配器 `business-component.cjs` 从以下当前源码读取组件字段与业务方法：

- `entry/src/main/ets/components/home/PersonalizedRoutineModal.ets`
- `entry/src/main/ets/pages/SkinStatusView.ets`
- `entry/src/main/ets/pages/HomeView.ets`

适配器将 `export struct` 改为普通类，移除 `@State`、`@Prop`、`@Watch` 声明，在第一个 `build()` 或 `@Builder` / `@LocalBuilder` 之前停止提取，再用 TypeScript 转译并放进独立 VM 上下文执行。测试不维护一份复制出来的业务实现。组件边界、必需方法或已知装饰器约定改变时会报错，需要明确更新适配器。

测试替换 `AuthService`、`PlanApiService`、`ProductApiService`、`SkinAnalysisService`、`SkinAnalysisApiService`，返回内存中的固定用户、记录或手动完成的 Promise。`Scroller` 是空桩；`AlertDialog.show` 只记录调用；父组件回调记录参数，消费 `openPlan` 的回调模拟同步回写属性。生命周期由测试直接调用。

服务测试由 `extractBusinessService` 使用 TypeScript 解析器选取当前 `ImagePickerService.ets`、`AuthSessionStore.ets`、`AuthService.ets` 中的实际类，忽略 import 并转译完整类。拍照测试的文件、句柄、cameraPicker、fileUri 和日志均为内存桩；不会访问真实相机或文件系统。

会话测试使用实际 AuthService 与实际 AuthSessionStore，替换的是 Asset API、Preferences、AppStorage、编码器及认证 API。Preferences 桩分开保存进程缓存与模拟持久层，分别注入 put/flush 后的状态，模拟重新创建服务和冷启动。测试不访问真实安全资产或已登录账户。

## 方案与年龄：16 项

| 检查 | 直接验证的行为 |
| --- | --- |
| 年龄回显与复用 | 保存过的年龄进入表单；未变化时不调用年龄更新 |
| 非法年龄 | 12、121、小数、空值阻止保存和生成 |
| 保存顺序与重复点击 | 年龄保存完成后才能生成；等待期间重复生成不发第二次请求 |
| 年龄保存失败 | 不继续生成，保留错误并释放忙碌状态 |
| 年龄回包不一致 | 服务返回的年龄与请求不同则拒绝继续 |
| 保存阶段取消 | 取消后不进入生成，原请求结束前不能重复提交 |
| 生成阶段取消 | 取消后的迟到方案不进入预览 |
| 三个阶段的异常 | 读取来源、保存年龄、生成方案抛错均释放状态并显示错误 |
| 页面离开 | 年龄保存期间销毁页面，迟到响应不再触发生成 |
| 生成期间换账号 | 旧账号的迟到方案不进入当前预览 |
| 来源回调 | 回调携带读取到的记录，并根据它格式化元数据 |
| 来源已删除 | 生成前发现无检测记录，不更新年龄、不创建方案 |
| 读取来源期间换账号 | 不把旧表单年龄写入新账号 |
| 年龄编辑器 | 取消保留原值；保存后生成复用更新结果 |
| 个人状态 | 周期天数 8 被拒绝；第 3 天及用户备注进入请求，目标进入 requirement |
| 正在采用 | `isAdopting=true` 时阻止返回、清空预览和再次生成 |

## 肌肤报告竞态：12 项

| 检查 | 直接验证的行为 |
| --- | --- |
| 删除锁 | 删除中阻止选记录、编辑、再次删除、检测和返回；回调持续要求显示覆盖层；成功后清除记录和草稿 |
| 删除前的旧读取 | 旧历史响应不能恢复已经删除的记录 |
| 读取乱序 | 只有最新请求可更新历史、错误和 loading |
| 删除失败 | 保留当前记录与错误，刷新历史不会清掉删除错误 |
| 删除成功但刷新失败 | 已删记录不恢复；单独呈现历史错误 |
| 编辑记录绑定 | A 的草稿不能向 B 的 ID 发请求 |
| 编辑中的保存锁 | 草稿数组不污染原记录；保存中阻止返回及并发操作；失败保留草稿 |
| 保存成功 | 应用服务返回的同一条记录，并清空编辑器 |
| 回包记录不一致 | 返回其他记录 ID 时保留原记录并报错 |
| 页面销毁 | load/remove/saveContext 的迟到成功和失败都不能更新状态或发起刷新 |
| 网络异常 | 三类请求抛错后释放相应忙碌状态，保留错误 |
| 状态区分 | 空历史成功、历史失败、分析失败及编辑错误相互独立 |

## 首页加载与方案入口：6 项

| 检查 | 直接验证的行为 |
| --- | --- |
| 首次读取失败 | 停止 loading 并保存错误；另以源码断言检查空态排除错误及重试回调接到 load |
| 失败后重试 | 应用成功返回的方案并清除错误 |
| 保留旧方案 | 失败响应或抛错不能清空之前有效的方案 |
| 请求乱序 | 较旧请求的成功或失败均不能覆盖最近重试结果 |
| 确认空态 | 成功返回 plan=null 时清除旧方案及错误 |
| 入口消费一次 | 父回调同步将 openPlan 置 false 仍执行首次 prepare；再出现不重复执行。另以源码断言检查 Index 消费回调 |

Home 检查继承原有 6 项方法回归；其中重试按钮、空态分支和 Index 属性消费的连接只检查源码形状，未在 ArkUI 中执行。

## 拍照临时资源：8 项

| 检查 | 直接验证的行为 |
| --- | --- |
| 成功拍摄返回 | 创建句柄在启动相机前 close，返回后文件仍可供上传读取 |
| 等待及取消 | 相机 Promise 未结束前保留文件；取消完成后仅清理一次 |
| 启动相机失败 | 异常码 2097152 进入诊断，清理文件，不输出错误中的路径或令牌 |
| 缺少返回 URI | 即使 resultCode=0 也视为未完成拍摄并清理空文件 |
| URI 转换失败 | 已创建的句柄被关闭、目标被清理，不启动相机 |
| 创建失败 | 不启动相机，不删除未获得所有权的路径 |
| 清理失败 | 保留最初的失败结果，追加安全的数字错误码诊断 |
| 缺少上下文 | 不创建文件，不启动相机 |

这些桩验证资源调用顺序与所有权移交，不证明 HarmonyOS 相机能力可用。当前模拟器缺少相机应用的情况需要明确保留为运行环境限制；相机成功路径仍需可用设备验证。

## 安全会话：19 项

| 检查 | 直接验证的行为 |
| --- | --- |
| 资产内容及策略 | 单条资产保存 token 与必要资料；Preferences 仅写布尔值；设置首次解锁可读、不同步 |
| 环境隔离 | 不同 API 地址不能读取同一会话 |
| 删除失败后的退出 | 持久墓碑阻止冷恢复 |
| 两道退出屏障 | Preferences 失败时安全删除仍可完成退出；两者均失败则抛错 |
| 资产写入失败 | 不暴露可恢复的新登录 |
| 解除墓碑失败 | flush 失败时，进程内及模拟冷启动都不能恢复未成功的登录 |
| 读取被拒绝 | 明确报错，不伪装成没有会话 |
| 冷恢复校验 | 使用保存的 token 调用 /me，更新资料快照 |
| 离线保留 | 断网、抛错、服务端错误保留会话；错误文案中出现 401 不触发退出 |
| 真实 401 | 清除内存会话并阻止冷恢复 |
| 安全存储不可读 | 要求重试，不发布已登录状态 |
| 旧资料响应 | 退出后旧响应不得恢复会话；使用同一 token 重新登录也不能被旧响应覆盖 |
| 旧登录响应 | 退出后迟到的登录或注册响应失效 |
| 登录保存失败 | 不返回登录或注册成功 |
| 退出未持久完成 | 两道清理均失败时抛错并保留可见会话，不能谎称已退出 |
| 资料缓存刷新失败 | 不撤销已经通过 /me 校验的有效凭据 |
| 超长可选资料 | 缩减为必要用户 ID，保证 SECRET 不超过 1024 字节 |
| 无效 payload | null、非法 JSON、缺失字段、空 token、错误字节类型安全清理后回到未登录状态 |
| 401 后清理失败 | 同一进程离线重试仍保持被拒绝状态；清理能力恢复后完成退出 |

上述冷启动是用内存资产及模拟持久层重新创建对象，不能证明设备 Asset 加密、系统密钥保管、签名权限或真实重启行为。401 在两个持久屏障均不可用时的检查只覆盖同一进程重试，不声称此时已经完成持久退出。

## 覆盖边界

- `transpileModule` 不提供完整 ArkTS 类型检查，不能替代 DevEco/Hvigor 构建。
- 没有执行 ArkUI 渲染、装饰器响应式逻辑、`@Watch` 自动触发、`@BuilderParam` 绑定、父子属性传播、焦点、手势或系统返回事件分发。
- `.enabled()`、按钮 loading、底部栏显隐、布局、文字、动画、图片、颜色和可访问性没有在这里实际渲染。覆盖层检查只证明组件发出的回调值正确。
- 年龄更新、认证和检测 API 是桩；通过不代表真实 HTTP schema、鉴权、设备持久化、照片上传、AI 输出或云端可用性通过。真实接口联调需要单独执行。
- 未执行 Home/Index 的完整页面树，因此来源页面往返是否保留实例、采用状态是否传到子页面仍需要原生集成验证。
- 这里按上述具体输入和异步顺序检查，不是业务全量覆盖、设备验收或 iOS 视觉一致性证明。
