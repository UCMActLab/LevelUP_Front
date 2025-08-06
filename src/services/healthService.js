import apiClient from '@/config/axios'

class HealthService {
  async checkHealth() {
    try {
      const response = await apiClient.get('/health')
      return {
        status: 'online',
        data: response.data,
        timestamp: new Date().toISOString()
      }
    } catch (error) {
      return {
        status: 'offline',
        error: error.message,
        timestamp: new Date().toISOString()
      }
    }
  }
  
  async ping() {
    const startTime = Date.now()
    try {
      await apiClient.get('/health')
      const endTime = Date.now()
      return {
        success: true,
        latency: endTime - startTime,
        timestamp: new Date().toISOString()
      }
    } catch (error) {
      return {
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      }
    }
  }
}

export default new HealthService()