import { HomeView } from './HomeView'
import { SkinStatusView } from './SkinStatusView'
import { ProductView } from './ProductView'
import { IngredientView } from './IngredientView'
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
  @State currentRoute: string = '/'
  @State ingredientProductId: string = ''
  @State showIngredientView: boolean = false
  @State isAuthenticated: boolean = false
  @State showLoginView: boolean = false
  @State showRegisterView: boolean = false
  @State checkingAuth: boolean = true
  @State productViewParams: ProductViewParams | null = null
  @State showConflictView: boolean = false
  @State conflictData: ConflictAnalysisData | null = null

  private authService: AuthService = AuthService.getInstance()

  aboutToAppear() {
    this.checkAuthStatus()
  }

  checkAuthStatus() {
    this.checkingAuth = true
    // Check authentication status
    this.isAuthenticated = this.authService.isAuthenticated()
    this.showLoginView = !this.isAuthenticated
    this.showRegisterView = false
    this.checkingAuth = false
  }

  handleNavigate(route: string, params?: ProductViewParams) {
    // If navigating to a different route, hide ingredient view
    if (route !== this.currentRoute) {
      this.showIngredientView = false
      this.ingredientProductId = ''
    }
    this.currentRoute = route
    if (params) {
      this.productViewParams = params
    } else {
      this.productViewParams = null
    }
  }

  handleNavigateToIngredient(productId: string) {
    this.ingredientProductId = productId
    this.showIngredientView = true
  }

  handleBackFromIngredient() {
    this.showIngredientView = false
    this.ingredientProductId = ''
  }

  handleNavigateToConflict(conflictData: ConflictAnalysisData) {
    this.conflictData = conflictData
    this.showConflictView = true
  }

  handleBackFromConflict() {
    this.showConflictView = false
    this.conflictData = null
  }

  handleLoginSuccess() {
    this.isAuthenticated = true
    this.showLoginView = false
    this.showRegisterView = false
    this.currentRoute = '/'
  }

  handleRegisterSuccess() {
    this.isAuthenticated = true
    this.showLoginView = false
    this.showRegisterView = false
    this.currentRoute = '/'
  }

  handleNavigateToRegister() {
    this.showLoginView = false
    this.showRegisterView = true
  }

  handleNavigateToLogin() {
    this.showLoginView = true
    this.showRegisterView = false
  }

  handleLogout() {
    console.log('===== 🚪 处理退出登录 =====')
    this.authService.logout()
    this.isAuthenticated = false
    this.showLoginView = true
    this.showRegisterView = false
    this.currentRoute = '/'
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.checkingAuth) {
        // Show loading while checking auth
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#F8BBD0')
            .margin({ bottom: 16 })

          Text('检查登录状态...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#fff9fb')
      } else if (!this.isAuthenticated) {
        // Show login or register view
        if (this.showRegisterView) {
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
            productIdParam: this.ingredientProductId,
            onBack: () => {
              this.handleBackFromIngredient()
            }
          })
          .width('100%')
          .height('100%')
        } else if (this.currentRoute === '/skinstatus') {
          SkinStatusView({
            onBack: () => {
              this.currentRoute = '/'
            }
          })
        } else if (this.currentRoute === '/product') {
          ProductView({
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
            onLogout: () => {
              this.handleLogout()
            }
          })
        } else {
          HomeView({
            onNavigate: (route: string, params?: ProductViewParams) => {
              this.handleNavigate(route, params)
            }
          })
        }

        // Bottom Navigation (only show when not in ingredient view or conflict view)
        if (!this.showIngredientView && !this.showConflictView) {
          BottomNavigation({
            currentRoute: this.currentRoute,
            onNavigate: (route: string) => {
              this.handleNavigate(route)
            }
          })
          .width('100%')
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}

// Data Models
interface ProductViewParams {
  autoEnableConflictMode?: boolean
}