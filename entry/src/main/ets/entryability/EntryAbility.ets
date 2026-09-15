import { ApiConfig } from '../services/ApiConfig';
import { AuthSessionStore } from '../services/AuthSessionStore';
import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null;
  private activeWindowStage: window.WindowStage | null = null;
  private layoutFullScreen: boolean = false;
  private readonly avoidAreaChange = (_options: window.AvoidAreaOptions): void => {
    this.refreshSafeArea();
  };

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AuthSessionStore.getInstance().initialize(this.context.getApplicationContext());
    AppStorage.setOrCreate<boolean>('aiskinComponentPreview', ApiConfig.ENABLE_COMPONENT_PREVIEW && want.parameters?.['aiskinPreview'] === 'components');
    AppStorage.setOrCreate<boolean>('aiskinDark', this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    AppStorage.setOrCreate<boolean>('aiskinForeground', true);
    try {
      // Follow system appearance; every semantic token has base and dark resources.
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.activeWindowStage = windowStage;
    this.storeSafeArea(0, 0, 0, 0);
    this.initializeMainWindow(windowStage);
  }

  private async initializeMainWindow(windowStage: window.WindowStage): Promise<void> {
    try {
      this.mainWindow = windowStage.getMainWindowSync();
      await this.mainWindow.setWindowLayoutFullScreen(true);
      if (this.activeWindowStage !== windowStage) { return; }
      this.layoutFullScreen = true;
      // Publish insets before loading ArkUI. Index pads only its content layer;
      // AISkinBackground paints the whole window, including transparent bars.
      this.readSafeArea();
      this.mainWindow.on('avoidAreaChange', this.avoidAreaChange);
      this.updateSystemBars();
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to configure immersive window: %{public}s', JSON.stringify(err));
      // If inset discovery fails, preserve native avoidance instead of placing
      // controls beneath the system bars with an assumed zero inset.
      if (this.mainWindow) {
        try { await this.mainWindow.setWindowLayoutFullScreen(false); }
        catch (fallbackError) {
          hilog.error(DOMAIN, 'EntryAbility', 'Failed to restore window avoidance: %{public}s', JSON.stringify(fallbackError));
        }
      }
      this.layoutFullScreen = false;
      this.storeSafeArea(0, 0, 0, 0);
    }

    if (this.activeWindowStage !== windowStage) { return; }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      this.refreshSafeArea();
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    this.activeWindowStage = null;
    if (this.mainWindow) {
      try { this.mainWindow.off('avoidAreaChange', this.avoidAreaChange); }
      catch (err) {
        hilog.error(DOMAIN, 'EntryAbility', 'Failed to remove avoid-area listener: %{public}s', JSON.stringify(err));
      }
    }
    this.mainWindow = null;
    this.layoutFullScreen = false;
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onConfigurationUpdate(config: Configuration): void {
    AppStorage.setOrCreate<boolean>('aiskinDark', config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    this.updateSystemBars();
    this.refreshSafeArea();
  }

  onForeground(): void {
    AppStorage.setOrCreate<boolean>('aiskinForeground', true);
    this.updateSystemBars();
    this.refreshSafeArea();
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    AppStorage.setOrCreate<boolean>('aiskinForeground', false);
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private updateSystemBars(): void {
    const mainWindow = this.mainWindow;
    if (!mainWindow) { return; }
    try {
      // Resolve the current base/dark resource instead of caching a theme color.
      const textColor = this.context.resourceManager.getColorByNameSync('aiskin_text');
      const contentColor = `#${(textColor >>> 0).toString(16).padStart(8, '0')}`;
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: contentColor,
        navigationBarContentColor: contentColor
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'EntryAbility', 'Failed to update system bar appearance: %{public}s', JSON.stringify(err));
      });
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to resolve system bar text color: %{public}s', JSON.stringify(err));
    }
  }

  private storeSafeArea(top: number, bottom: number, left: number, right: number): void {
    AppStorage.setOrCreate<number>('aiskinSafeTopPx', top);
    AppStorage.setOrCreate<number>('aiskinSafeBottomPx', bottom);
    AppStorage.setOrCreate<number>('aiskinSafeLeftPx', left);
    AppStorage.setOrCreate<number>('aiskinSafeRightPx', right);
  }

  private readSafeArea(): void {
    const mainWindow = this.mainWindow;
    if (!mainWindow || !this.layoutFullScreen) { return; }
    const system = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    const cutout = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
    const navigation = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    // Window rectangles are pixels. Index uses explicit px lengths, so no
    // device-density assumption or duplicated padding conversion is required.
    this.storeSafeArea(
      Math.max(system.topRect.height, cutout.topRect.height, navigation.topRect.height),
      Math.max(system.bottomRect.height, cutout.bottomRect.height, navigation.bottomRect.height),
      Math.max(system.leftRect.width, cutout.leftRect.width, navigation.leftRect.width),
      Math.max(system.rightRect.width, cutout.rightRect.width, navigation.rightRect.width)
    );
  }

  private refreshSafeArea(): void {
    try { this.readSafeArea(); }
    catch (err) {
      // Retain the last valid insets if a window transition is temporarily busy.
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to refresh safe area: %{public}s', JSON.stringify(err));
    }
  }
}
