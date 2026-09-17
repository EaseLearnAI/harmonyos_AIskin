import { DesignSystemGallery } from '../design/DesignSystemGallery'
import { AISkinStateView } from '../design/AISkinPrimitives'
import { AISkinStateKind } from '../design/Foundation/AISkinTokens'
import { AISkinColor } from '../design/AISkinTheme'
import { AISkinBackground } from '../design/AISkinTheme'
import { OnboardingView } from './OnboardingView'
import { HomeView } from './HomeView'
import { SkinStatusView } from './SkinStatusView'
import { ProductView } from './ProductView'
import { IngredientView } from './IngredientView'
import { ConflictHistoryView } from './ConflictHistoryView'
import { ConflictView } from './ConflictView'
import { ProfileView } from './ProfileView'
import { LoginView } from './LoginView'
import { RegisterView } from './RegisterView'
import { BottomNavigation } from '../components/common/BottomNavigation'
import { AuthService } from '../services/AuthService'
import { ConflictAnalysisData } from '../components/product/ConflictApiService'

@Entry
@Component
struct Index {
  @StorageLink('aiskinSafeTopPx') safeTopPx: number = 0
  @StorageLink('aiskinSafeBottomPx') safeBottomPx: number = 0
  @StorageLink('aiskinSafeLeftPx') safeLeftPx: number = 0
  @StorageLink('aiskinSafeRightPx') safeRightPx: number = 0
  @StorageLink('aiskinComponentPreview') componentPreview: boolean = false
  @State screenOverlay: boolean = false
  @State openPlan: boolean = false
  private homeBack: (() => boolean) | undefined = undefined
  private skinBack: (() => boolean) | undefined = undefined
  private productBack: (() => boolean) | undefined = undefined
  private ingredientBack: (() => boolean) | undefined = undefined
  private profileBack: (() => boolean) | undefined = undefined
  @State onboarding: boolean = true
  @State currentRoute: string = '/'
  @State ingredientProductId: string = ''
  @State ingredientEdit: boolean = false
  @State showIngredientView: boolean = false
  @StorageLink('aiskinAuthenticated') isAuthenticated: boolean = false
  @State showLoginView: boolean = false
  @State showRegisterView: boolean = false
  @State checkingAuth: boolean = true
  @State authRestoreError: string = ''
  private authCheckGeneration: number = 0
  @State productViewParams: ProductViewParams | null = null
  @State showConflictView: boolean = false
  @State conflictData: ConflictAnalysisData | null = null

  private authService: AuthService = AuthService.getInstance()

  aboutToAppear() {
    this.checkAuthStatus()
  }

  aboutToDisappear(): void { this.authCheckGeneration++ }

  async checkAuthStatus(): Promise<void> {
    const generation = ++this.authCheckGeneration
    this.checkingAuth = true
    this.authRestoreError = ''
    if (!this.componentPreview) {
      const response = await this.authService.restoreSession()
      if (generation !== this.authCheckGeneration) return
      if (response.retryRequired) this.authRestoreError = response.message || '安全登录信息读取失败，请重试'
    }
    this.isAuthenticated = this.authService.isAuthenticated()
    this.showLoginView = !this.isAuthenticated
    this.showRegisterView = false
    this.checkingAuth = false
  }

  handleNavigate(route: string, params?: ProductViewParams): void {
    // If navigating to a different route, hide ingredient view
    if (route !== this.currentRoute) {
      this.showIngredientView = false
      this.ingredientProductId = ''
    }
    this.currentRoute = route
    this.screenOverlay = false
    this.openPlan = false
    if (params) {
      this.productViewParams = params
    } else {
      this.productViewParams = null
    }
  }

  handleNavigateToIngredient(productId: string, edit: boolean = false): void {
    this.ingredientEdit = edit
    this.ingredientProductId = productId
    this.showIngredientView = true
  }

  handleBackFromIngredient(): void {
    this.showIngredientView = false
    this.ingredientProductId = ''
  }

  handleNavigateToConflict(conflictData: ConflictAnalysisData): void {
    this.conflictData = conflictData
    this.showConflictView = true
  }

  handleBackFromConflict(): void {
    this.showConflictView = false
    this.conflictData = null
  }

  handleLoginSuccess(): void {
    this.isAuthenticated = true
    this.showLoginView = false
    this.showRegisterView = false
    this.currentRoute = '/'
  }

  handleRegisterSuccess(): void {
    this.isAuthenticated = true
    this.showLoginView = false
    this.showRegisterView = false
    this.currentRoute = '/'
  }

  handleNavigateToRegister(): void {
    this.showLoginView = false
    this.showRegisterView = true
  }

  handleNavigateToLogin(): void {
    this.showLoginView = true
    this.showRegisterView = false
  }

  handleLogout(): void {
    console.log('===== 🚪 处理退出登录 =====')
    // Profile calls this only after durable logout/deletion succeeds.
    this.authCheckGeneration++
    this.isAuthenticated = false
    this.showLoginView = true
    this.showRegisterView = false
    this.currentRoute = '/'
  }

  onBackPress(): boolean {
    if (this.showConflictView) { this.handleBackFromConflict(); return true }
    if (this.showIngredientView) { if (!this.ingredientBack?.()) this.handleBackFromIngredient(); return true }
    if (this.showRegisterView) { this.handleNavigateToLogin(); return true }
    if (!this.isAuthenticated && !this.onboarding) { this.onboarding = true; return true }
    if (this.currentRoute === '/' && this.homeBack?.()) return true
    if ((this.currentRoute === '/skinstatus' || this.currentRoute === '/skin-history') && this.skinBack?.()) return true
    if (this.currentRoute === '/product' && this.productBack?.()) return true
    if (this.currentRoute === '/profile' && this.profileBack?.()) return true
    if (this.currentRoute === '/skin-history' || this.currentRoute === '/conflict-history') { this.handleNavigate('/profile'); return true }
    if (this.currentRoute !== '/') { this.handleNavigate('/'); return true }
    return false
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      AISkinBackground()
      Stack({ alignContent: Alignment.Bottom }) {
      if (this.componentPreview) { DesignSystemGallery() } else if (this.checkingAuth) { AISkinStateView({ title: '检查登录状态', kind: AISkinStateKind.Loading })
      } else if (this.authRestoreError) {
        AISkinStateView({ title: '登录恢复失败', message: this.authRestoreError, kind: AISkinStateKind.Error,
          onRetry: (): void => { this.checkAuthStatus() } })
      } else if (!this.isAuthenticated) {
        // Show login or register view
        if (this.onboarding) {
          OnboardingView({ onContinue: () => { this.onboarding = false } })
        } else if (this.showRegisterView) {
          RegisterView({
            onRegisterSuccess: () => {
              this.handleRegisterSuccess()
            },
            onNavigateToLogin: () => {
              this.handleNavigateToLogin()
            }
          })
          .width('100%')
          .height('100%')
        } else {
          LoginView({
            onLoginSuccess: () => {
              this.handleLoginSuccess()
            },
            onNavigateToRegister: () => {
              this.handleNavigateToRegister()
            }
          })
          .width('100%')
          .height('100%')
        }
      } else {
        // Show main app content
        // Main Content Area
        if (this.showConflictView) {
          // Show Conflict View (overlay on top)
          ConflictView({
            conflictData: this.conflictData,
            onBack: () => {
              this.handleBackFromConflict()
            }
          })
          .width('100%')
          .height('100%')
        } else if (this.showIngredientView) {
          // Show Ingredient View (overlay on top)
          IngredientView({
            registerBackHandler: (handler: () => boolean) => { this.ingredientBack = handler },
            productIdParam: this.ingredientProductId, initialEditMode: this.ingredientEdit,
            onNavigateToConflictSelection: (productId: string) => { this.showIngredientView = false; this.handleNavigate('/product', { autoEnableConflictMode: true, initialSelectedProductId: productId }) },
            onBack: () => {
              this.handleBackFromIngredient()
            }
          })
          .width('100%')
          .height('100%')
        } else if (this.currentRoute === '/conflict-history') {
          ConflictHistoryView({ onStart: () => this.handleNavigate('/product',{autoEnableConflictMode:true}), onBack: () => { this.currentRoute = '/profile' },
            onOpen: (report: ConflictAnalysisData) => this.handleNavigateToConflict(report) })
        } else if (this.currentRoute === '/skinstatus' || this.currentRoute === '/skin-history') {
          SkinStatusView({
            registerBackHandler: (handler: () => boolean) => { this.skinBack = handler },
            openHistory: this.currentRoute === '/skin-history',
            onProfile: () => { this.currentRoute = '/profile' },
            onReportVisibility: (visible: boolean) => { this.screenOverlay = visible },
            onCreatePlan: () => { this.currentRoute = '/'; this.openPlan = true },
            onBack: () => { this.handleNavigate(this.currentRoute === '/skin-history' ? '/profile' : '/') }
          })
        } else if (this.currentRoute === '/product') {
          ProductView({
            registerBackHandler: (handler: () => boolean) => { this.productBack = handler },
            onOverlay: (visible: boolean) => { this.screenOverlay = visible },
            onProfile: () => { this.currentRoute = '/profile' },
            onEditProduct: (productId: string) => { this.handleNavigateToIngredient(productId,true) },
            initialSelectedProductId: this.productViewParams?.initialSelectedProductId || '',
            autoEnableConflictMode: this.productViewParams?.autoEnableConflictMode || false,
            onNavigateToIngredient: (productId: string) => {
              this.handleNavigateToIngredient(productId)
            },
            onNavigateToConflict: (conflictData: ConflictAnalysisData) => {
              this.handleNavigateToConflict(conflictData)
            },
            onBack: () => {
              this.currentRoute = '/'
              this.productViewParams = null
            }
          })
        } else if (this.currentRoute === '/profile') {
          ProfileView({
            registerBackHandler: (handler: () => boolean) => { this.profileBack = handler },
            onBack: () => { this.currentRoute = '/' },
            onNavigate: (route: string) => this.handleNavigate(route),
            onLogout: () => {
              this.handleLogout()
            }
          })
        } else {
          HomeView({
            registerBackHandler: (handler: () => boolean) => { this.homeBack = handler },
            openPlan: this.openPlan, onOverlay: (value: boolean) => { this.screenOverlay = value },
            onConsumeOpenPlan: () => { this.openPlan = false },
            onProfile: () => { this.currentRoute = '/profile' },
            onNavigate: (route: string, params?: ProductViewParams) => {
              this.handleNavigate(route, params)
            }
          })
        }

        // Bottom Navigation (only show when not in ingredient view or conflict view)
        if (!this.screenOverlay && !this.showIngredientView && !this.showConflictView && this.currentRoute !== '/profile' && this.currentRoute !== '/skin-history' && this.currentRoute !== '/conflict-history') {
          BottomNavigation({
            currentRoute: this.currentRoute,
            onNavigate: (route: string) => {
              this.handleNavigate(route)
            }
          })
          .width('92%')
        }
      }
      }.width('100%').height('100%').padding({ top: `${this.safeTopPx}px`, bottom: `${this.safeBottomPx}px`, left: `${this.safeLeftPx}px`, right: `${this.safeRightPx}px` })
    }
    .width('100%')
    .height('100%')
  }
}

// Data Models
interface ProductViewParams {
  initialSelectedProductId?: string
  autoEnableConflictMode?: boolean
}
