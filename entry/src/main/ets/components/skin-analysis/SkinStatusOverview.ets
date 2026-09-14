import { AISkinColor, CardStyle } from '../../design/AISkinTheme'
@Component
export struct SkinStatusOverview {
  @Prop blackheads: BlackheadsData = {}
  @Prop acne: AcneData = {}
  @Prop pores: PoresData = {}
  @Prop skinToneEvenness: SkinToneData = {}
  @Prop redness: RednessData = {}
  @Prop hyperpigmentation: HyperpigmentationData = {}
  @Prop fineLines: FineLinesData = {}
  @Prop sensitivity: SensitivityData = {}
  status(exists: boolean | undefined, severity: string | undefined): string {
    if (exists === false) return '未见'
    return severity || (exists === true ? '有记录' : '未记录')
  }
  build() {
    Column({ space: 16 }) {
      Text('肌肤观察').fontSize(18).fontWeight(FontWeight.Medium).fontColor(AISkinColor.text)
      this.observation('泛红', this.status(this.redness.exists, this.redness.severity), this.redness.description || '', this.redness.distribution || [])
      this.observation('毛孔', this.status(this.pores.enlarged, this.pores.severity), this.pores.description || '', this.pores.distribution || [])
      this.observation('痘痘', this.status(this.acne.exists, this.acne.count), [this.acne.description || '', (this.acne.types || []).join('、')].filter(item => item.length > 0).join(' · '), this.acne.distribution || [])
      this.observation('黑头', this.status(this.blackheads.exists, this.blackheads.severity), this.blackheads.description || '', this.blackheads.distribution || [])
      this.observation('色素沉着', this.status(this.hyperpigmentation.exists, this.hyperpigmentation.severity), this.hyperpigmentation.description || '', this.hyperpigmentation.distribution || [])
      this.observation('细纹', this.status(this.fineLines.exists, this.fineLines.severity), this.fineLines.description || '', this.fineLines.distribution || [])
      this.observation('敏感观察', this.status(this.sensitivity.exists, this.sensitivity.severity), this.sensitivity.description || '', this.sensitivity.signs || [])
      this.observation('肤色均匀度', this.skinToneEvenness.score === undefined ? '未记录' : `${this.skinToneEvenness.score} 分`, this.skinToneEvenness.description || '', [])
    }.width('100%').padding(20).alignItems(HorizontalAlign.Start).attributeModifier(new CardStyle())
  }
  @Builder
  observation(title: string, status: string, detail: string, distribution: string[]) {
    Column({ space: 10 }) {
      Row() {
        Text(title).fontSize(16).fontColor(AISkinColor.text).layoutWeight(1)
        Text(status).fontSize(12).fontColor(AISkinColor.accent).padding(6).backgroundColor(AISkinColor.selected).borderRadius(8)
      }.width('100%')
      if (detail) { Text(detail).fontSize(14).lineHeight(23).fontColor(AISkinColor.text) }
      if (distribution.length) { Text(`记录部位或表现：${distribution.join('、')}`).fontSize(13).lineHeight(21).fontColor(AISkinColor.secondary) }
      Divider().color(AISkinColor.divider)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
// Data Models
interface BlackheadsData {
  description?: string
  exists?: boolean
  severity?: string
  distribution?: string[]
}

interface AcneData {
  description?: string
  exists?: boolean
  count?: string
  types?: string[]
  distribution?: string[]
}

interface PoresData {
  description?: string
  enlarged?: boolean
  severity?: string
  distribution?: string[]
}

interface SkinToneData {
  score?: number
  description?: string
}

interface RednessData {
  exists?: boolean
  severity?: string
  description?: string
  distribution?: string[]
}

interface HyperpigmentationData {
  exists?: boolean
  severity?: string
  description?: string
  types?: string[]
  distribution?: string[]
}

interface FineLinesData {
  exists?: boolean
  severity?: string
  description?: string
  distribution?: string[]
}

interface SensitivityData {
  exists?: boolean
  severity?: string
  description?: string
  signs?: string[]
}






