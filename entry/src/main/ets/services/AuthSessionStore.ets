import { asset } from '@kit.AssetStoreKit'
import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { ApiConfig } from './ApiConfig'
import { UserData } from './AuthService'

export interface AuthStoredSession {
  version: number
  token: string
  user: UserData
}

// Credentials and the small offline user snapshot live together in the system
// encrypted asset. Preferences contain only a non-secret signed-out barrier.
export class AuthSessionStore {
  private static instance: AuthSessionStore | null = null
  private context: common.Context | null = null
  private blockedInProcess: boolean = false
  private readonly alias: string = `aiskin.session.v1:${ApiConfig.getBaseUrl()}`
  private readonly blockedKey: string = `signed_out:${ApiConfig.getBaseUrl()}`

  static getInstance(): AuthSessionStore {
    if (AuthSessionStore.instance === null) AuthSessionStore.instance = new AuthSessionStore()
    return AuthSessionStore.instance
  }

  initialize(context: common.Context): void { this.context = context }

  private state(): preferences.Preferences {
    if (!this.context) throw new Error('安全登录存储尚未初始化')
    return preferences.getPreferencesSync(this.context, { name: 'aiskin_auth_state' })
  }

  private setBlocked(blocked: boolean): void {
    if (blocked) this.blockedInProcess = true
    const state = this.state()
    state.putSync(this.blockedKey, blocked)
    state.flushSync()
    this.blockedInProcess = blocked
  }

  private query(): asset.AssetMap {
    const query: asset.AssetMap = new Map<asset.Tag, asset.Value>()
    query.set(asset.Tag.ALIAS, new util.TextEncoder().encodeInto(this.alias))
    return query
  }

  read(): AuthStoredSession | null {
    if (this.blockedInProcess || this.state().getSync(this.blockedKey, false) === true) return null
    const query = this.query()
    query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL)
    query.set(asset.Tag.RETURN_LIMIT, 1)
    let matches: Array<asset.AssetMap>
    try { matches = asset.querySync(query) }
    catch (error) {
      if ((error as BusinessError).code === asset.ErrorCode.NOT_FOUND) return null
      throw new Error('安全登录信息读取失败，请重试')
    }
    if (matches.length === 0) return null
    const secret = matches[0].get(asset.Tag.SECRET)
    if (!(secret instanceof Uint8Array)) { this.clear(); return null }
    let session: AuthStoredSession
    try { session = JSON.parse(new util.TextDecoder('utf-8').decodeWithStream(secret)) as AuthStoredSession }
    catch (error) { this.clear(); return null }
    if (!session || session.version !== 1 || typeof session.token !== 'string' || !session.token.trim() ||
      !session.user || typeof session.user.id !== 'string' || !session.user.id) {
      this.clear()
      return null
    }
    return session
  }

  private write(user: UserData, token: string): void {
    if (!token.trim() || !user.id) throw new Error('登录信息不完整，请重新登录')
    const snapshot: UserData = { id: user.id, name: user.name, phone: user.phone, gender: user.gender, age: user.age }
    const session: AuthStoredSession = { version: 1, token: token, user: snapshot }
    const encoder = new util.TextEncoder()
    let secret = encoder.encodeInto(JSON.stringify(session))
    // Asset SECRET is limited to 1024 bytes. A long optional name must not turn
    // a valid credential into an invalid platform request; /me fills it again.
    if (secret.length > 1024) {
      session.user = { id: user.id }
      secret = encoder.encodeInto(JSON.stringify(session))
    }
    if (secret.length > 1024) throw new Error('登录凭据过长，无法安全保存')
    const attributes = this.query()
    attributes.set(asset.Tag.SECRET, secret)
    attributes.set(asset.Tag.ACCESSIBILITY, asset.Accessibility.DEVICE_FIRST_UNLOCKED)
    attributes.set(asset.Tag.SYNC_TYPE, asset.SyncType.NEVER)
    attributes.set(asset.Tag.CONFLICT_RESOLUTION, asset.ConflictResolution.OVERWRITE)
    // IS_PERSISTENT means retention after uninstall, not normal cold startup.
    // Leave it unset: signing out/uninstalling should not retain credentials.
    asset.addSync(attributes)
  }

  save(user: UserData, token: string): void {
    // Publish neither memory nor a recoverable credential before both writes
    // succeed. A crash/failure midway keeps the signed-out barrier in place.
    this.setBlocked(true)
    try {
      this.write(user, token)
      this.setBlocked(false)
    } catch (error) {
      // Also handle an uncertain final flush: remove the newly written asset
      // and restore the barrier before exposing the failed login to the UI.
      try { this.clear() } catch (cleanupError) { console.error('Unable to finish secure login rollback') }
      throw new Error('无法安全保存登录信息，请重试')
    }
  }

  update(user: UserData, token: string): void {
    // Refreshing the same session does not alter its signed-out barrier.
    this.write(user, token)
  }

  clear(): void {
    let blocked = false
    let removed = false
    try { this.setBlocked(true); blocked = true } catch (error) { /* Try secure deletion as the other durable barrier. */ }
    try { asset.removeSync(this.query()); removed = true }
    catch (error) { removed = (error as BusinessError).code === asset.ErrorCode.NOT_FOUND }
    if (!blocked && !removed) throw new Error('安全退出未完成，请重试')
  }
}
