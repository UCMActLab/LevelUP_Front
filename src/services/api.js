import apiClient from '@/config/axios'

class ApiService {
  async get(endpoint, params = {}) {
    try {
      const response = await apiClient.get(endpoint, { params })
      return response.data
    } catch (error) {
      this.handleError(error)
      throw error
    }
  }

  async post(endpoint, data = {}) {
    try {
      const response = await apiClient.post(endpoint, data)
      return response.data
    } catch (error) {
      this.handleError(error)
      throw error
    }
  }

  async put(endpoint, data = {}) {
    try {
      const response = await apiClient.put(endpoint, data)
      return response.data
    } catch (error) {
      this.handleError(error)
      throw error
    }
  }

  async patch(endpoint, data = {}) {
    try {
      const response = await apiClient.patch(endpoint, data)
      return response.data
    } catch (error) {
      this.handleError(error)
      throw error
    }
  }

  async delete(endpoint) {
    try {
      const response = await apiClient.delete(endpoint)
      return response.data
    } catch (error) {
      this.handleError(error)
      throw error
    }
  }

  handleError(error) {
    const errorMessage = error.response?.data?.message || error.message || 'An error occurred'
    console.error('API Service Error:', errorMessage)
  }
}

export default new ApiService()