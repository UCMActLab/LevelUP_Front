import api from './api'

class ContractService {
  async getContracts(filters = {}) {
    return await api.get('/contracts', filters)
  }

  async getContract(id) {
    return await api.get(`/contracts/${id}`)
  }

  async createContract(contract) {
    return await api.post('/contracts', contract)
  }

  async updateContract(id, contract) {
    return await api.put(`/contracts/${id}`, contract)
  }

  async deleteContract(id) {
    return await api.delete(`/contracts/${id}`)
  }

  async getContractsByStatus(status) {
    return await api.get('/contracts', { status })
  }

  async searchContracts(searchTerm) {
    return await api.get('/contracts/search', { q: searchTerm })
  }

  async getContractStats() {
    return await api.get('/contracts/stats')
  }
}

export default new ContractService()