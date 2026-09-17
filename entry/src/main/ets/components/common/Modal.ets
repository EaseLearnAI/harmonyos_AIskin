import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
import { AISkinLayout, AISkinSpacing, AISkinCardRole } from '../../design/Foundation/AISkinTokens'
import { AppHeader } from './AppHeader'
export enum AISkinModalPresentation { Content, Reading }

@Component
export struct Modal {
  @Prop show: boolean = false
  @Prop title: string = ''
  @Prop showCloseButton: boolean = true
  @Prop isBusy: boolean = false
  @Prop presentation: AISkinModalPresentation = AISkinModalPresentation.Content
  @BuilderParam content: () => void
  @BuilderParam footer: () => void = this.emptyFooter
  onClose?: () => void
  @Builder emptyFooter() {}
  build() {
    if (this.show) {
      Stack({ alignContent: Alignment.Center }) {
        Column().width('100%').height('100%').backgroundColor(AISkinColor.scrim)
          .onClick(() => { if (!this.isBusy) this.onClose?.() })
        Row() {
        Column({ space: AISkinSpacing.small }) {
          AppHeader({ title: this.title, showBackButton: this.showCloseButton,
            onBack: () => { if (!this.isBusy) this.onClose?.() } })
          if (this.presentation === AISkinModalPresentation.Reading) {
            Scroll() { this.content() }.width('100%').layoutWeight(1).scrollBar(BarState.Auto).align(Alignment.Top)
          } else { this.content() }
          this.footer()
        }.width('100%').height(this.presentation === AISkinModalPresentation.Reading ? AISkinLayout.modalMaxHeight : 'auto')
          .constraintSize({ maxWidth: AISkinLayout.modalMaxWidth, maxHeight: AISkinLayout.modalMaxHeight })
          .padding({ bottom: AISkinSpacing.cardPadding }).attributeModifier(new CardStyle(AISkinCardRole.Overlay))
          .onClick(() => {})
        }.width('100%').height(this.presentation === AISkinModalPresentation.Reading ? '100%' : 'auto')
          .padding(AISkinSpacing.screenEdge).justifyContent(FlexAlign.Center)
      }.width('100%').height('100%').zIndex(10000)
    }
  }
}
