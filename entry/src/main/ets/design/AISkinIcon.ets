@Component
export struct AISkinIcon {
  @Prop name: string = 'home'
  @Prop selected: boolean = false
  @Prop iconSize: number = 24
  private source(): Resource {
    switch (this.name) {
      case 'home': return $r('app.media.icon_home')
      case 'cabinet': return $r('app.media.icon_cabinet')
      case 'plus': return $r('app.media.icon_plus')
      case 'back': return $r('app.media.icon_back')
      case 'plan': return $r('app.media.icon_plan')
      case 'conflict': return $r('app.media.icon_conflict')
      case 'skin': return $r('app.media.icon_skin')
      case 'profile': return $r('app.media.icon_profile')
      case 'history': return $r('app.media.icon_history')
      case 'photo': return $r('app.media.icon_photo')
      default: return $r('app.media.icon_home')
    }
  }
  build() {
    Image(this.source()).width(this.iconSize).height(this.iconSize).objectFit(ImageFit.Contain).opacity(this.selected ? 1 : 0.86)
  }
}
