// Central glyph geometry. Paint always resolves AISkinColor at runtime.
export class AISkinIconTokens {
  static readonly viewport: number = 24
  static readonly stroke: number = 1.6
  static readonly detailStroke: number = 1.7
  static isFilled(name: string): boolean {
    return name === 'homeFilled' || name === 'cabinetFilled' || name === 'planFilled' ||
      name === 'checkCircle' || name === 'ellipsis' || name === 'more'
  }
  static detailPath(name: string): string {
    switch (name) {
      case 'checkCircle': return 'M7.5 12L10.5 15L16.5 8.5'
      case 'cabinetFilled': return 'M3 7L12 11L21 7M12 11V22M7.5 4.5L16.5 8.5'
      default: return ''
    }
  }
  static path(name: string): string {
    switch (name) {
      case 'sun': return 'M16 12A4 4 0 1 1 8 12A4 4 0 1 1 16 12M12 1V4M12 20V23M1 12H4M20 12H23M4 4L6 6M18 18L20 20M20 4L18 6M6 18L4 20'
      case 'moon': return 'M20.7 14.3A9 9 0 0 1 9.7 3.3A9 9 0 1 0 20.7 14.3Z'
      case 'more':
      case 'ellipsis': return 'M6.5 12A1.5 1.5 0 1 1 3.5 12A1.5 1.5 0 1 1 6.5 12ZM13.5 12A1.5 1.5 0 1 1 10.5 12A1.5 1.5 0 1 1 13.5 12ZM20.5 12A1.5 1.5 0 1 1 17.5 12A1.5 1.5 0 1 1 20.5 12Z'
      case 'layers': return 'M12 2L22 8L12 14L2 8ZM3 12L12 18L21 12M3 16L12 22L21 16'
      case 'circle':
      case 'checkCircle': return 'M21 12A9 9 0 1 1 3 12A9 9 0 1 1 21 12Z'
      case 'drop': return 'M12 2C10 5 5 10 5 15A7 7 0 0 0 19 15C19 10 14 5 12 2Z'
      case 'close': return 'M6 6L18 18M18 6L6 18'
      case 'back': return 'M15 5L8 12L15 19'
      case 'cabinet': return 'M3 7L12 3L21 7V19L12 23L3 19ZM3 7L12 11L21 7M12 11V23M8 5L17 9'
      case 'cabinetFilled': return 'M12 2L22 6.5V18.5L12 23L2 18.5V6.5Z'
      case 'conflict': return 'M12 2L21 6V12Q20 19 12 23Q4 19 3 12V6ZM8 12L11 15L17 9'
      case 'history': return 'M3 4V10H9M3 10A9 9 0 112 15M12 7V13L16 15'
      case 'home': return 'M3 10L12 3L21 10V21H15V14H9V21H3Z'
      case 'homeFilled': return 'M1 10.5L12 1.5L23 10.5L21.5 12.3L19.5 10.7V22H14.5V15H9.5V22H4.5V10.7L2.5 12.3Z'
      case 'photo': return 'M3 5H21V21H3ZM3 16L8 11L13 16L16 13L21 18M14 9H15'
      case 'plan': return 'M12 2L15 9L22 12L15 15L12 22L9 15L2 12L9 9ZM20 2V6M18 4H22'
      case 'planFilled': return 'M14 5C15 12 16 13 23 14C16 15 15 16 14 23C13 16 12 15 5 14C12 13 13 12 14 5ZM5 3C5.5 6.5 6 7 9.5 7.5C6 8 5.5 8.5 5 12C4.5 8.5 4 8 .5 7.5C4 7 4.5 6.5 5 3ZM18 0C18.3 2.2 18.8 2.7 21 3C18.8 3.3 18.3 3.8 18 6C17.7 3.8 17.2 3.3 15 3C17.2 2.7 17.7 2.2 18 0Z'
      case 'plus': return 'M12 4V20M4 12H20'
      case 'profile': return 'M16 7A4 4 0 118 7A4 4 0 1116 7M3 22V20Q3 14 12 14Q21 14 21 20V22'
      case 'skin': return 'M8 3H4A1 1 0 003 4V8M16 3H20A1 1 0 0121 4V8M3 16V20A1 1 0 004 21H8M21 16V20A1 1 0 0120 21H16M8 9V11M16 9V11M9 16Q12 18 15 16'
      case 'trash': return 'M3 6h18M9 6V4h6v2M5 6l1 14h12l1-14M10 10v6M14 10v6'
      default: return 'M3 10L12 3L21 10V21H15V14H9V21H3Z'
    }
  }
}
