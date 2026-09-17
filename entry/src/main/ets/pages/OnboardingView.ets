import accessibility from '@ohos.accessibility'
import { AISkinOnboardingSlide, AISkinPageControl, AISkinAuthFooter } from '../design/AISkinOnboardingComponents'
import { AISkinOnboardingTokens } from '../design/Foundation/AISkinOnboardingTokens'
import { DocumentModal } from '../components/common/DocumentModal'
import { DocumentContent } from '../utils/DocumentContent'
interface OnboardingPage { number: string; title: string; accent: string; detail: string; image: Resource; imageDescription: string }
@Component
export struct OnboardingView {
  @StorageProp('aiskinForeground') foreground: boolean = true
  @State page: number = 0
  @State legal: string = ''
  @State dragging: boolean = false
  @State screenReader: boolean = false
  onContinue: () => void = () => {}
  private controller: SwiperController = new SwiperController()
  private timer: number = -1
  private lastInteraction: number = Date.now()
  private readerChanged: (enabled: boolean) => void = (enabled: boolean) => { this.screenReader = enabled; this.lastInteraction = Date.now() }
  private pages: OnboardingPage[] = [
    { number: '01', title: '肌肤有哪些问题？', accent: '拍一下，看看。', detail: '拍下清晰的正面照片，\n查看泛红、痘痘、毛孔等肤况分析。', image: $r('app.media.onboarding_skin'), imageDescription: '拍照取景中的卡通人物，两颊泛红、鼻部毛孔和下巴痘痘均被圈出并标注' },
    { number: '02', title: '这几瓶混着用，', accent: '会不会「烂脸」？', detail: '担心混用出问题？\n上脸前，先查成分搭配中的潜在冲突。', image: $r('app.media.onboarding_conflict'), imageDescription: '精华与面霜汇聚到同一块脸颊，出现泛红与起痘的混用风险示意' },
    { number: '03', title: '拍一下成分表，', accent: '功效、风险一起看。', detail: '基于成分，了解主要功效与潜在风险。\n不只听宣传，多一份判断依据。', image: $r('app.media.onboarding_ingredient'), imageDescription: '手机正在拍摄长方体护肤品包装盒上的成分列表' }
  ]
  aboutToAppear() {
    this.lastInteraction = Date.now()
    try { this.screenReader = accessibility.isScreenReaderOpenSync(); accessibility.on('screenReaderStateChange', this.readerChanged) } catch (_error) {}
    this.timer = setInterval(() => {
      if (!this.foreground || this.legal || this.dragging || this.screenReader) { this.lastInteraction = Date.now(); return }
      if (Date.now() - this.lastInteraction >= AISkinOnboardingTokens.autoAdvanceInterval) { this.lastInteraction = Date.now(); this.controller.changeIndex((this.page + 1) % this.pages.length, true) }
    }, AISkinOnboardingTokens.autoAdvanceCheckInterval)
  }
  aboutToDisappear() {
    if (this.timer !== -1) clearInterval(this.timer)
    try { accessibility.off('screenReaderStateChange', this.readerChanged) } catch (_error) {}
  }
  build() {
    Stack() {
      Column() {
        Swiper(this.controller) {
          ForEach(this.pages, (item: OnboardingPage) => {
            AISkinOnboardingSlide({ number: item.number, title: item.title, accentTitle: item.accent, detail: item.detail, artwork: item.image, imageDescription: item.imageDescription, animationsEnabled: !this.screenReader })
          }, (item: OnboardingPage) => item.number)
        }.index(this.page).loop(true).autoPlay(false).indicator(false).layoutWeight(1)
          .onChange((index: number) => { this.page = index; this.lastInteraction = Date.now() })
          .onTouch((event: TouchEvent) => { this.dragging = event.type === TouchType.Down || event.type === TouchType.Move; this.lastInteraction = Date.now() })
        AISkinPageControl({ labels: this.pages.map(item => item.title), selection: this.page, onSelect: (index: number) => { this.lastInteraction = Date.now(); this.controller.changeIndex(index, !this.screenReader) } }).margin({ bottom: AISkinOnboardingTokens.footerGap })
        AISkinAuthFooter({ onContinue: this.onContinue, onLegalDocument: (title: string) => { this.legal = title } })
      }.width('100%').constraintSize({ maxWidth: AISkinOnboardingTokens.contentMaxWidth }).height('100%')
      DocumentModal({ show: this.legal !== '', title: this.legal, content: this.legal === '隐私政策' ? DocumentContent.getPrivacyPolicy() : DocumentContent.getTermsOfUse(), onClose: () => { this.legal = ''; this.lastInteraction = Date.now() } })
    }.width('100%').height('100%')
  }
}
