import api from './api'
import apiClient from '@/config/axios'

class AuthService {
  /**
   * Login with username and password
   * POST /login - No authentication required
   */
  async login(username, password) {
    try {
      // Use apiClient directly for login (no auth required)
      const response = await apiClient.post('/login', { user: username, password })
      const { token, user } = response.data.data
      
      if (token) {
        localStorage.setItem('auth_token', token)
        localStorage.setItem('user', JSON.stringify(user))
      }
      
      return { token, user }
    } catch (error) {
      if (error.response?.status === 401) {
        throw new Error('Invalid username or password')
      }
      if (error.response?.status === 400) {
        throw new Error('Invalid request format')
      }
      throw error
    }
  }
  
  async logout() {
    try {
      await api.post('/auth/logout')
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      localStorage.removeItem('auth_token')
      localStorage.removeItem('user')
    }
  }
  
  async register(userData) {
    const response = await api.post('/auth/register', userData)
    const { token, user } = response
    
    if (token) {
      localStorage.setItem('auth_token', token)
      localStorage.setItem('user', JSON.stringify(user))
    }
    
    return { token, user }
  }
  
  async refreshToken() {
    try {
      const response = await api.post('/auth/refresh')
      const { token } = response
      
      if (token) {
        localStorage.setItem('auth_token', token)
      }
      
      return token
    } catch (error) {
      this.clearAuth()
      throw error
    }
  }
  
  async validateToken() {
    const token = this.getToken()
    if (!token) return false
    
    try {
      const response = await api.get('/auth/validate')
      return response.valid === true
    } catch (error) {
      return false
    }
  }
  
  async forgotPassword(email) {
    return await api.post('/auth/forgot-password', { email })
  }
  
  async resetPassword(token, newPassword) {
    return await api.post('/auth/reset-password', { token, newPassword })
  }
  
  getToken() {
    return localStorage.getItem('auth_token') || sessionStorage.getItem('auth_token')
  }
  
  getUser() {
    const userStr = localStorage.getItem('user') || sessionStorage.getItem('user')
    try {
      return userStr ? JSON.parse(userStr) : null
    } catch {
      return null
    }
  }
  
  isAuthenticated() {
    return !!this.getToken()
  }
  
  clearAuth() {
    localStorage.removeItem('auth_token')
    localStorage.removeItem('user')
    sessionStorage.removeItem('auth_token')
    sessionStorage.removeItem('user')
  }
}

export default new AuthService()
