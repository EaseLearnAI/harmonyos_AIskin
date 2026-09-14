import { AISkinColor, PrimaryButtonStyle } from '../design/AISkinTheme'
import { DocumentModal } from '../components/common/DocumentModal'
import { DocumentContent } from '../utils/DocumentContent'

interface OnboardingPage { number: string; title: string; accent: string; detail: string; image: Resource }
@Component
export struct OnboardingView {
  @StorageProp('aiskinDark') dark: boolean = false
  @StorageProp('aiskinForeground') foreground: boolean = true
  @State page: number = 0
  @State legal: string = ''
  onContinue: () => void = () => {}
  private controller: SwiperController = new SwiperController()
  private pages: OnboardingPage[] = [
    { number: '01', title: '肌肤有哪些问题？', accent: '拍一下，看看。', detail: '拍下清晰的正面照片，\n查看泛红、痘痘、毛孔等肤况分析。', image: $r('app.media.onboarding_skin') },
    { number: '02', title: '这几瓶混着用，', accent: '会不会「烂脸」？', detail: '担心混用出问题？\n上脸前，先查成分搭配中的潜在冲突。', image: $r('app.media.onboarding_conflict') },
    { number: '03', title: '拍一下成分表，', accent: '功效、风险一起看。', detail: '基于成分，了解主要功效与潜在风险。\n不只听宣传，多一份判断依据。', image: $r('app.media.onboarding_ingredient') }
  ]
  build() {
    Stack() {
      Column() {
        Swiper(this.controller) {
          ForEach(this.pages, (item: OnboardingPage) => {
            Scroll() {
              Column() {
                Text(item.number).fontSize(13).letterSpacing(1).fontColor(AISkinColor.accent).margin({ bottom: 20 })
                Text(item.title).fontSize(29).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text).textAlign(TextAlign.Center)
                Text(item.accent).fontSize(29).fontWeight(FontWeight.Medium).fontColor(AISkinColor.accent).textAlign(TextAlign.Center).margin({ top: 7 })
                Text(item.detail).fontSize(12).lineHeight(20).fontColor(AISkinColor.secondary).textAlign(TextAlign.Center).margin({ top: 14 })
                Stack() {
                  Image(item.image).objectFit(ImageFit.Contain).width('100%').height('100%').accessibilityText(item.title + item.accent)
                  Column().width('100%').height('100%').linearGradient({ angle: 180, colors: [['#00000000',0], ['#FF000000',0.05], ['#FF000000',0.89], ['#00000000',1]] }).blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
                  Column().width('100%').height('100%').linearGradient({ angle: 90, colors: [['#00000000',0], ['#FF000000',0.05], ['#FF000000',0.95], ['#00000000',1]] }).blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
                }.width('100%').constraintSize({ maxWidth: 372 }).aspectRatio(1).blendMode(this.dark ? BlendMode.SRC_OVER : BlendMode.MULTIPLY).margin({ top: 16 }).renderGroup(true)

              }.width('100%').padding({ top: 31, left: 20, right: 20 })
            }.width('100%').height('100%').scrollBar(BarState.Off)
          }, (item: OnboardingPage) => item.number)
        }.index(this.page).loop(true).autoPlay(this.legal === '' && this.foreground).interval(5000).indicator(false).layoutWeight(1)
          .onChange((index: number) => { this.page = index })
        Row() {
          ForEach(this.pages, (item: OnboardingPage, index: number) => {
            Button() {
              Circle().width(6).height(6).fill(this.page === index ? AISkinColor.accent : AISkinColor.divider)
            }.width(44).height(44).backgroundColor(Color.Transparent)
              .accessibilityText(`第${index + 1}页：${item.title}`)
              .onClick(() => { this.controller.changeIndex(index, true) })
          })
        }.margin({ bottom: 14 })
        Button('登录 / 注册').width('100%').attributeModifier(new PrimaryButtonStyle()).onClick(this.onContinue)
        Row() {
          Button('使用条款').fontSize(12).fontColor(AISkinColor.secondary).backgroundColor(Color.Transparent)
            .height(44).onClick(() => { this.legal = '使用条款' })
          Text('·').fontColor(AISkinColor.secondary)
          Button('隐私政策').fontSize(12).fontColor(AISkinColor.secondary).backgroundColor(Color.Transparent)
            .height(44).onClick(() => { this.legal = '隐私政策' })
        }
      }.width('100%').constraintSize({ maxWidth: 430 }).height('100%').padding({ left: 20, right: 20, bottom: 8 })
      DocumentModal({ show: this.legal !== '', title: this.legal,
        content: this.legal === '隐私政策' ? DocumentContent.getPrivacyPolicy() : DocumentContent.getTermsOfUse(),
        onClose: () => { this.legal = '' } })
    }.width('100%').height('100%')
  }
}
