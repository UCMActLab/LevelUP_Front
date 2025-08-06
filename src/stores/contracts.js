import { reactive } from 'vue'
import resourceService from '@/services/resourceService'

export const contractStore = reactive({
  contracts: [],
  loading: false,
  error: null,

  async fetchContracts() {
    this.loading = true
    this.error = null
    try {
      const response = await resourceService.getResources()
      this.contracts = response.data?.data || response || []
    } catch (error) {
      console.error('Error fetching resources:', error)
      this.error = error.message
      this.contracts = []
    } finally {
      this.loading = false
    }
  },

  async getContractById(id) {
    try {
      const contract = await resourceService.getResource(id)
      return contract.data || contract
    } catch (error) {
      console.error('Error fetching resource:', error)
      this.error = error.message
      return null
    }
  },

  async createContract(contractData) {
    this.loading = true
    this.error = null
    try {
      const newContract = await resourceService.createResource(contractData)
      this.contracts.push(newContract)
      return newContract
    } catch (error) {
      console.error('Error creating resource:', error)
      this.error = error.message
      throw error
    } finally {
      this.loading = false
    }
  },

  async updateContract(id, data) {
    this.loading = true
    this.error = null
    try {
      const updatedContract = await resourceService.updateResource(id, data)
      const index = this.contracts.findIndex(c => c._id === id || (c._id?.$oid && c._id.$oid === id))
      if (index !== -1) {
        this.contracts[index] = updatedContract
      }
      return updatedContract
    } catch (error) {
      console.error('Error updating resource:', error)
      this.error = error.message
      throw error
    } finally {
      this.loading = false
    }
  },

  async deleteContract(id) {
    this.loading = true
    this.error = null
    try {
      await resourceService.deleteResource(id)
      this.contracts = this.contracts.filter(c => c._id !== id && (!c._id?.$oid || c._id.$oid !== id))
      return true
    } catch (error) {
      console.error('Error deleting resource:', error)
      this.error = error.message
      throw error
    } finally {
      this.loading = false
    }
  },

  async searchContracts(searchTerm) {
    this.loading = true
    this.error = null
    try {
      const results = await resourceService.searchResources(searchTerm)
      return results
    } catch (error) {
      console.error('Error searching resources:', error)
      this.error = error.message
      return []
    } finally {
      this.loading = false
    }
  }
})
