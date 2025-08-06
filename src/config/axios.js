import axios from 'axios'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8079',
  timeout: parseInt(import.meta.env.VITE_API_TIMEOUT) || 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    if (import.meta.env.VITE_APP_ENV === 'development' || import.meta.env.VITE_APP_ENV === 'local') {
      console.log(`[${config.method.toUpperCase()}] ${config.url}`, config.data || config.params || '')
    }
    
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

apiClient.interceptors.response.use(
  (response) => {
    if (import.meta.env.VITE_APP_ENV === 'development' || import.meta.env.VITE_APP_ENV === 'local') {
      console.log(`[RESPONSE] ${response.config.url}:`, response.data)
    }
    return response
  },
  (error) => {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          localStorage.removeItem('auth_token')
          window.location.href = '/login'
          break
        case 403:
          console.error('Access denied')
          break
        case 404:
          console.error('Resource not found')
          break
        case 500:
          console.error('Server error')
          break
        default:
          console.error('API Error:', error.response.data?.message || error.message)
      }
    } else if (error.request) {
      console.error('Network error - no response received')
    } else {
      console.error('Error setting up request:', error.message)
    }
    
    return Promise.reject(error)
  }
)

export default apiClient