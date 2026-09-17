# 鸿蒙上架整改复核（2026-09-16）

依据：[飞书整改清单](https://vrfi1sk8a0.feishu.cn/docx/EUOmdN2CdoZ1RCxdAytcmjC6nXF)。本次用户明确：安全评估材料尚未取得，先完成程序整改。

## 当前问题与处理

| 审核项 | 程序现状及本轮改动 | 尚缺的证据 |
| --- | --- | --- |
| AI 文本安全评估资质 | 用户确认未取得；发布检查要求真实报告与平台通过截图，并绑定送审 HAP | 真实主体材料，不能由代码生成 |
| AI 标识 | 成分与冲突报告的标识移至结果前；补齐每日方案、产品摘要、冲突历史、肌肤摘要的标识，继续复用统一说明组件 | 最终签名包截图、AGC 版权材料上传与 AI 功能声明 |
| 产品分析和肌肤检测功能深度 | 保留已有完整链路：上传/拍摄、成分目录、产品保存编辑、冲突检测与历史；肌肤明细、历史、状态编辑与方案联动；未新增无关产品功能 | 当前华为登录完成后，最终生产端到端验收；功能深度是否满足审核由华为判断 |
| READ_IMAGEVIDEO | 源码和 HAP 分别核对权限白名单；继续使用 PhotoViewPicker | 最终送审 HAP 复核 |
| 应用名称 | 安装标签、协议和隐私政策标题核对“析肤AI” | AGC 页面名称与开发者资料人工复核 |
| 报告截断 | 现有共用报告文字不限制行数，冲突结果按单页滚动完整呈现；新增截断/切片回归检查 | Mate 60 中文、大字号实际完整滚动验收 |
| 低对比度 | 发现仅比对纯底色遗漏光晕叠加；浅色辅助文字改为 #504658，强调色改为 #5B3E73，保持背景锁定值；深色资源保持不变 | Pura 80 Pro+、Mate X5 渲染检查 |
| 1024 图标 | AppScope 与 entry 的前后景图均保持 1024×1024；检查实际打包资源，避免只改源图却提交旧包 | 最终签名包和商店显示复核 |
| 深色模式 | 保留已有系统颜色跟随与共用语义色；新增 base/dark 资源完整性和颜色对比度检查 | 指定真机、文字放大后的交互复核 |

## 防止重复送审问题

统一入口：`./scripts/prepare-appgallery.sh`。依次执行审核源码检查、设计系统检查、业务回归、diff 检查、production 构建和包/材料检查。任何失败均返回非零退出码；不会上传或提交商店。

单独执行：

```sh
python3 scripts/check-appgallery.py
node --test scripts/tests/*.test.cjs
python3 scripts/check-appgallery.py --release --hap /path/to/final.hap --evidence /path/to/evidence.json
```

GitHub Actions 在 push / PR 上运行源码及回归检查；本机仍需 DevEco 构建、签名、真机和生产验收。CI 文件存在不代表远端检查已经执行，也不代表已配置受保护分支规则。

### 检查的准确边界

- 对比度按当前 AISkinBackground 的线性渐变及三层径向光晕，在手机和折叠屏比例网格采样，再叠加卡片等语义背景。普通文字目标 4.5:1；这不是所有设备真实像素或华为检测工具的结果。
- AI 标识与报告不截断属于源码契约检查；不会用静态断言冒充 ArkUI 布局、点击或大字号验收。新增结果入口须更新检查范围。
- HAP 检查读取实际 module.json、图标及字节码中的 API 地址；release 检查调用 DevEco 官方 `verify-app` 验证签名。证书是否匹配 AGC 及是否为发布用途仍需人工复核，不能只凭源码配置认定提交包正确。
- 图标源图要求 1024×1024；本机实际 HAP 中编译后为 512×512。已核对 [OpenHarmony restool ScaleImage 源码](https://github.com/openharmony/developtools_global_resource_tool/blob/9203d8530e4c7823690bb8906ce61ef808088884/src/compression_parser.cpp#L388)：图标编译存在固定 512×512 缩放步骤。因此检查区分源图与产物，允许编译后的 512，不能把正常编译缩放误报为“仍是旧图标”。
- evidence.json 必须绑定最终 HAP 的 SHA-256 和 `source_sha256`（通过 `python3 scripts/check-appgallery.py --fingerprint` 获取）。每项记录人工复核人、时间、材料文件路径及 SHA-256；文件记录格式为 `{"path":"相对于清单的文件路径","sha256":"真实文件的SHA-256"}`。缺文件、空文件、材料改变、换包或源码改变都会阻止通过。工具核对材料完整性，不判断报告真伪、法定有效性或代替华为审核。
- 当前没有 AI 生成文件导出功能。增加导出/下载时必须重新评估隐式标识和材料，不能沿用无导出声明。

## 验证记录

本轮变更在独立整改分支和当前华为登录工作区分别核对，不能把两者混作同一个送审包。

- 独立整改分支：62 项 Node 回归通过（其中包含 11 项 Python 故障注入）；production Release 构建通过，未签名。该分支沿用 PR #1 的手机号登录基线。源码检查与实际 HAP 内容检查通过。
- 当前华为登录工作区：同一批界面整改参与 local 构建并通过；production 缺少 Client ID，不能送审。华为原生登录改动仍保留在原工作区。

- 新增 11 项故障注入检查通过，覆盖权限、摘要标识、报告截断、原低对比度、图标、名称、深色资源、最终包与材料绑定。
- 设计系统结构检查通过；与 iOS 基准的 5 项颜色差异明确记录为对比度适配，不称为像素一致。
- 独立目录 `AIskin-AppGallery-Review-20260916` 的本地调试构建通过。该包使用本地 API、缺少 Account Kit Client ID、未签名，不能送审。
- production 构建因缺少 `AISKIN_HUAWEI_CLIENT_ID` 被阻止；这是有效阻断，不能记录成 release 验收通过。
- 本轮没有执行生产华为登录、指定机型视觉复核、部署、AGC 材料上传或提交。

## 联系地址

用户提供的新联系地址已更新至本地私有资料 `doc/release-private/appgallery-contact.md`。目录已被 Git 忽略，不把家庭地址写入公开仓库。此次尚未更新 AGC 在线表单。

## 私有材料清单格式

参见 `doc/release-evidence.example.json`。将副本及真实材料放入 `doc/release-private/` 等私有目录；只有人工实际完成相应验收后才填 `passed`。目录中的文件不要提交到 Git。
