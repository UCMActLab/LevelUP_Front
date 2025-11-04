import { reactive } from 'vue'
import resourceService from '@/services/resourceService'

export const contractStore = reactive({
  contracts: [],
  loading: false,
  error: null,
  totalItems: 0,
  currentPage: 1,
  itemsPerPage: 10,

  async fetchContracts(page = 1, limit = 10, filters = {}) {
    this.loading = true
    this.error = null
    try {
      const response = await resourceService.getResources(filters, page, limit)
      console.log('Full API Response:', response)
      console.log('Response structure:', {
        hasData: !!response.data,
        hasPagination: !!response.pagination,
        dataType: Array.isArray(response.data) ? 'array' : typeof response.data,
        paginationContent: response.pagination
      })

      // Handle different response formats
      // Structure: response.data.data = array, response.data.pagination = pagination info
      if (response.data?.data && Array.isArray(response.data.data)) {
        this.contracts = response.data.data
        this.totalItems = response.data.pagination?.totalItems || response.data.data.length || 0
      } else if (response.data && Array.isArray(response.data)) {
        // Fallback: data directly in response.data
        this.contracts = response.data
        this.totalItems = response.pagination?.totalItems || response.data.length || 0
      } else if (Array.isArray(response)) {
        // Fallback: data directly in response
        this.contracts = response
        this.totalItems = response.length || 0
      } else {
        // Error: unexpected format
        this.contracts = []
        this.totalItems = 0
        console.error('Unexpected response format - data is not an array:', response)
      }

      console.log('Store state after update:', {
        contractsCount: this.contracts.length,
        totalItems: this.totalItems,
        currentPage: this.currentPage,
        loading: this.loading
      })

      this.currentPage = page
      this.itemsPerPage = limit
    } catch (error) {
      console.error('Error fetching resources:', error)
      this.error = error.message
      this.contracts = []
      this.totalItems = 0
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
