import { reactive } from 'vue'
import authService from '@/services/authService'

export const authStore = reactive({
  user: null,
  token: null,
  isAuthenticated: false,
  loading: false,
  
  init() {
    // Check both localStorage and sessionStorage
    let token = localStorage.getItem('auth_token') || sessionStorage.getItem('auth_token')
    let userStr = localStorage.getItem('user') || sessionStorage.getItem('user')
    
    if (token && userStr) {
      try {
        const user = JSON.parse(userStr)
        this.token = token
        this.user = user
        this.isAuthenticated = true
      } catch (error) {
        console.error('Error parsing user data:', error)
        this.isAuthenticated = false
      }
    }
  },
  
  async login(username, password, rememberMe = false) {
    this.loading = true
    try {
      const { user, token } = await authService.login(username, password)
      this.user = user
      this.token = token
      this.isAuthenticated = true
      
      if (rememberMe) {
        localStorage.setItem('auth_token', token)
        localStorage.setItem('user', JSON.stringify(user))
      } else {
        sessionStorage.setItem('auth_token', token)
        sessionStorage.setItem('user', JSON.stringify(user))
      }
      
      return { user, token }
    } catch (error) {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      throw error
    } finally {
      this.loading = false
    }
  },
  
  async logout() {
    this.loading = true
    try {
      await authService.logout()
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      localStorage.removeItem('auth_token')
      localStorage.removeItem('user')
      sessionStorage.removeItem('auth_token')
      sessionStorage.removeItem('user')
      this.loading = false
    }
  },
  
  async register(userData) {
    this.loading = true
    try {
      const { user, token } = await authService.register(userData)
      this.user = user
      this.token = token
      this.isAuthenticated = true
      return { user, token }
    } catch (error) {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      throw error
    } finally {
      this.loading = false
    }
  },
  
  async validateToken() {
    if (!this.token) return false
    
    try {
      const isValid = await authService.validateToken()
      if (!isValid) {
        this.logout()
      }
      return isValid
    } catch (error) {
      this.logout()
      return false
    }
  },
  
  hasRole(role) {
    return this.user?.role === role
  },
  
  hasAnyRole(roles) {
    return roles.includes(this.user?.role)
  }
})

authStore.init()