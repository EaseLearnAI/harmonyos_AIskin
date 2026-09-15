// Numeric visual values mirror ios_aiskin/AIskin/DesignSystem/Foundation @ 9f69aa9.
// HarmonyOS vp/fp are the native counterparts of iOS pt; semantic roles stay shared.
export class AISkinRadius {
  static readonly medium: number = 12
  static readonly card: number = 23
  static readonly actionCard: number = 17
  static readonly featureCard: number = 24
  static readonly routineCard: number = 28
  static readonly control: number = 24
  static readonly capsule: number = 999
}
export class AISkinSpacing {
  static readonly xxxSmall: number = 2
  static readonly xxSmall: number = 4
  static readonly xSmall: number = 8
  static readonly small: number = 12
  static readonly medium: number = 16
  static readonly large: number = 20
  static readonly xLarge: number = 24
  static readonly xxLarge: number = 32
  static readonly xxxLarge: number = 40
  static readonly screenEdge: number = 24
  static readonly sectionGap: number = 18
  static readonly cardPadding: number = 20
  static readonly homeCardPadding: number = 20
  static readonly routineRowPadding: number = 14
}
export class AISkinLayout {
  static readonly edge: number = AISkinSpacing.screenEdge
  static readonly gap: number = AISkinSpacing.small
  static readonly radius: number = AISkinRadius.card
  static readonly controlRadius: number = AISkinRadius.control
  static readonly tap: number = 44
  static readonly maxWidth: number = 600
  static readonly fieldHeight: number = 50
  static readonly formFieldHeight: number = 48
  static readonly noteHeight: number = 104
  static readonly headerHeight: number = 64
  static readonly iconSize: number = 20
  static readonly hairline: number = 1
  static readonly emphasisLine: number = 1.5
  static readonly tagHeight: number = 32
  static readonly regularTagHeight: number = 36
  static readonly tabIndicatorWidth: number = 24
  static readonly tabIndicatorHeight: number = 2
  static readonly regularUnderlineHeight: number = 56
  static readonly actionTileHeight: number = 104
  static readonly actionIconDiameter: number = 40
  static readonly routineCheckDiameter: number = 18
  static readonly routineRowHeight: number = 76
  static readonly productThumbnailCabinet: number = 56
  static readonly productThumbnailDetail: number = 96
  static readonly productCardMinimumHeight: number = 112
  static readonly captureGuideDiameter: number = 184
  static readonly captureGuideInnerDiameter: number = 148
  static readonly processingRing: number = 83
  static readonly processingPanelWidth: number = 330
  static readonly progressStroke: number = 3
  static readonly modalMaxWidth: number = 440
  static readonly modalMaxHeight: string = '85%'
  static readonly tabHeight: number = 60
  static readonly bottomClearance: number = 96
}
export enum AISkinTextRole {
  ScreenTitle, FeatureTitle, SectionTitle, CardTitle, Body, BodyEmphasized,
  Callout, Caption, Disclosure, Button, CompactButton, HeroMetric,
  ProcessingTitle, ProcessingPercentage, CompactCaption, EmptyTitle,
  RoutineTitle, HomeHeading, ReportTab, ProductTitle, FeatureSubtitle,
  SegmentedLabel, ReportBody, TabLabel, Icon
}
export class AISkinTypography {
  static size(role: AISkinTextRole): number {
    switch (role) {
      case AISkinTextRole.ScreenTitle: case AISkinTextRole.ProcessingPercentage: return 22
      case AISkinTextRole.HeroMetric: return 28
      case AISkinTextRole.EmptyTitle: return 30
      case AISkinTextRole.HomeHeading: return 18
      case AISkinTextRole.Callout: case AISkinTextRole.ProductTitle: return 16
      case AISkinTextRole.Caption: case AISkinTextRole.ReportTab: return 12
      case AISkinTextRole.CompactCaption: return 11
      case AISkinTextRole.TabLabel: return 10
      case AISkinTextRole.CompactButton: return 14
      case AISkinTextRole.Disclosure: case AISkinTextRole.FeatureSubtitle: return 13
      case AISkinTextRole.ReportBody: case AISkinTextRole.SegmentedLabel: case AISkinTextRole.ProcessingTitle: return 15
      case AISkinTextRole.Icon: return 20
      default: return 17
    }
  }
  static weight(role: AISkinTextRole): number | FontWeight {
    switch (role) {
      case AISkinTextRole.SectionTitle: case AISkinTextRole.HeroMetric: return FontWeight.Bold
      case AISkinTextRole.ScreenTitle: case AISkinTextRole.FeatureTitle: case AISkinTextRole.HomeHeading: case AISkinTextRole.ProductTitle: return 600
      case AISkinTextRole.CardTitle:
      case AISkinTextRole.BodyEmphasized: case AISkinTextRole.Button: case AISkinTextRole.CompactButton:
      case AISkinTextRole.ProcessingTitle: return FontWeight.Medium
      default: return FontWeight.Normal
    }
  }
}
export class AISkinMotion {
  static readonly pressedOpacity: number = 0.82
  static readonly disabledOpacity: number = 0.45
  static readonly pressedScale: number = 0.98
  static readonly standard: number = 300
  static readonly processingInterval: number = 100
}
export enum AISkinCardRole { Content, Feature, Routine, Overlay, Action }
export enum AISkinCardState { Normal, Selected }
export enum AISkinCardInset { None, Regular }
export enum AISkinButtonVariant { Primary, Secondary, Surface, Destructive, Plain }
export enum AISkinButtonLayout { FullWidth, Compact }
export enum AISkinTone { Primary, Secondary, Accent, Success, Warning, Destructive, OnAccent }
export enum AISkinFieldVariant { Standard, Form }
export enum AISkinFieldState { Normal, Focused, Loading, Error }
export enum AISkinTagState { Normal, Selected, Disabled }
export enum AISkinTagVariant { Badge, SelectionCell, SelectionPill }
export enum AISkinTabVariant { Underline, Segmented }
export enum AISkinStateKind { Loading, Empty, Error }
