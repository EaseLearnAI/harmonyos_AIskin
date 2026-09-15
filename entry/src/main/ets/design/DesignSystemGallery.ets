import { AISkinColor, CardStyle, TextStyle } from './AISkinTheme'
import { AISkinHeader, AISkinButton, AISkinField, AISkinTag, AISkinTabs, AISkinStateView } from './AISkinPrimitives'
import { AISkinActionTile, AISkinChecklistRow } from './AISkinJourneyComponents'
import { AISkinLayout, AISkinSpacing, AISkinTextRole, AISkinTone, AISkinButtonVariant, AISkinButtonLayout, AISkinCardRole, AISkinCardState, AISkinCardInset, AISkinTagState, AISkinTabVariant, AISkinStateKind } from './Foundation/AISkinTokens'
@Component
export struct DesignSystemGallery {
  @State section: number = 0
  @State selected: number = 0
  @State checked: boolean = false
  onNavigate?: (route: string) => void
  build() {
    Column() {
      AISkinHeader({ title: '组件验收', subtitle: '仅本地预览 · 不代表真实账号数据' })
      AISkinTabs({ items: ['按钮卡片','字段状态','入口任务'], selection: this.section, onSelect: (index: number) => { this.section = index } })
      Scroll() {
        Column({ space: AISkinSpacing.medium }) {
          if (this.section === 0) {
            ForEach([AISkinCardRole.Content,AISkinCardRole.Feature,AISkinCardRole.Routine,AISkinCardRole.Action], (role: AISkinCardRole) => {
              Column({ space: AISkinSpacing.small }) {
                Text(['内容卡片','功能卡片','任务卡片','弹层','操作卡片'][role]).attributeModifier(new TextStyle(AISkinTextRole.CardTitle))
                Text('卡片圆角、表面、边框由 CardStyle 一处控制').attributeModifier(new TextStyle(AISkinTextRole.Caption,AISkinTone.Secondary))
              }.width('100%').attributeModifier(new CardStyle(role,AISkinCardState.Normal,AISkinCardInset.Regular))
            })
            AISkinButton({ title: '主要操作' })
            AISkinButton({ title: '次要操作', variant: AISkinButtonVariant.Secondary })
            AISkinButton({ title: '禁用状态', isEnabled: false })
            AISkinButton({ title: '加载状态', isLoading: true })
            AISkinButton({ title: '删除记录', variant: AISkinButtonVariant.Destructive })
          } else if (this.section === 1) {
            AISkinField({ placeholder: '普通输入框' })
            AISkinField({ value: '错误内容', error: '请检查填写内容' })
            AISkinField({ value: '读取中', isLoading: true })
            AISkinField({ value: 'password', isPassword: true })
            Row({ space: AISkinSpacing.small }) { AISkinTag({ title: '未选择' }); AISkinTag({ title: '已选择',state: AISkinTagState.Selected }); AISkinTag({ title: '已禁用',state: AISkinTagState.Disabled }) }
            AISkinTabs({ items:['早间','晚间'],selection:this.selected,variant:AISkinTabVariant.Segmented,onSelect:(index:number)=>{this.selected=index} })
            AISkinStateView({ title:'加载失败',message:'这里检查错误信息与重试按钮',kind:AISkinStateKind.Error,onRetry:()=>{} })
            AISkinStateView({ title:'暂无记录',message:'这里检查空状态' })
          } else {
            Row({space:AISkinSpacing.small}) { AISkinActionTile({title:'护肤柜',subtitle:'收纳产品 · 查看成分',icon:'cabinet'}).layoutWeight(1); AISkinActionTile({title:'肌肤检测',subtitle:'分析当前面部肤况',icon:'skin'}).layoutWeight(1) }
            AISkinChecklistRow({title:'洁面',message:'使用温和洁面产品',isCompleted:this.checked,onAction:()=>{this.checked=!this.checked}})
            AISkinChecklistRow({title:'涂抹保湿精华',message:'长文本在任务摘要中省略，完整方案中展示原文',number:2,isCompleted:true})
          }
        }.width('100%').padding(AISkinSpacing.screenEdge)
      }.width('100%').layoutWeight(1).align(Alignment.Top)
    }.width('100%').height('100%')
  }
}
