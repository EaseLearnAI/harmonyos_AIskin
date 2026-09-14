# 原生模拟器验证截图

2026-09-15，HarmonyOS 6 / API 20，1320×2856。所有图片直接来自系统截图；深色由系统设置实际开启。本地服务端使用 main d17ebf0、一次性测试账号与仓库测试图片，OCR、成分、冲突、肌肤、方案由真实模型返回。

- onboarding：iOS 插画复用、暗色主题。
- home / cabinet：功能入口、真实护肤柜、采用方案后的每日任务。
- ingredient：成分报告和目录；conflict / conflict-advice：冲突报告两个标签。
- skin-report / skin-context：肌肤报告、照片与拍摄状态保存回显。
- plan-preview：原生生成方案预览；processing：带「预估」说明的进度环。
- ai-notice：人工智能说明及反馈方式。

这些是开发验证证据，不是 Mate 60 / Pura 80 Pro+ / Mate X5 真机截图，也不是 AGC 通过证明。截图拍摄于最终小幅调整辅助文字颜色、关闭按钮尺寸及移除方案按钮装饰符之前；主要布局、数据链路和 AI 标识与最终源码一致。最终签名发布包仍需重新取证。

登录预填只存在于临时调试副本，未纳入源码和正式包，含账号的登录截图未复制到这里。

`onboarding-release-light.jpeg` 和 `login-release-light.jpeg` 是最终未签名 Release 包安装启动后的截图，登录输入框均为空。
