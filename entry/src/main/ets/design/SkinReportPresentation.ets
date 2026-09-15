import { SkinAnalysisData } from '../services/SkinAnalysisApiService'
export interface SkinObservation { id: string; title: string; status: string; details: string; isConcern: boolean }
export function skinObservations(data: SkinAnalysisData): SkinObservation[] {
  const rows: SkinObservation[] = []
  const add = (id: string, title: string, exists: boolean | undefined, status: string | undefined, description: string | undefined, distribution: string[] | undefined): void => {
    if (exists === undefined && !status && !description && !distribution?.length) return
    const recorded = status || (exists === true ? '有' : '未记录程度')
    const concern = exists !== false && (exists === true || ['轻微','轻度','少量','少许','中度','较明显','明显','重度','严重','较多','大量'].includes(recorded))
    const details = [description || '', distribution?.length ? `记录部位：${distribution.join('、')}` : '', exists === false && status && status !== '未见' ? `原始程度记录：${status}` : ''].filter(value => value.length > 0).join('\n')
    rows.push({ id: id, title: title, status: exists === false ? '未见' : recorded, details: details || '本次仅记录了上述结果，未提供具体部位或详细说明。', isConcern: concern })
  }
  const other = data.otherIssues
  add('redness','泛红',other?.redness?.exists,other?.redness?.severity,other?.redness?.description,other?.redness?.distribution)
  add('pores','毛孔',data.pores?.enlarged,data.pores?.severity,data.pores?.description,data.pores?.distribution)
  add('acne','痘痘',data.acne?.exists,data.acne?.count,[data.acne?.description || '', (data.acne?.types || []).join('、')].filter(value => value.length > 0).join('\n'),data.acne?.distribution)
  add('blackheads','黑头',data.blackheads?.exists,data.blackheads?.severity,data.blackheads?.description,data.blackheads?.distribution)
  add('pigment','色素沉着',other?.hyperpigmentation?.exists,other?.hyperpigmentation?.severity,[other?.hyperpigmentation?.description || '',(other?.hyperpigmentation?.types || []).join('、')].filter(value => value.length > 0).join('\n'),other?.hyperpigmentation?.distribution)
  add('lines','细纹',other?.fineLines?.exists,other?.fineLines?.severity,other?.fineLines?.description,other?.fineLines?.distribution)
  add('sensitivity','敏感观察',other?.sensitivity?.exists,other?.sensitivity?.severity,[other?.sensitivity?.description || '',(other?.sensitivity?.signs || []).join('、')].filter(value => value.length > 0).join('\n'),[])
  add('tone','肤色均匀度',undefined,other?.skinToneEvenness?.score !== undefined ? `${other.skinToneEvenness.score} 分` : undefined,other?.skinToneEvenness?.description,[])
  return rows
}
