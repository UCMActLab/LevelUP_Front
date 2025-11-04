import api from './api'

class ResourceService {
  /**
   * Get all resources (requires authentication)
   * @param {Object} filters - Optional filters for the resources
   * @param {Number} page - Page number (1-indexed)
   * @param {Number} limit - Number of items per page
   * @returns {Promise} Object with data and pagination info
   */
  async getResources(filters = {}, page = 1, limit = 10) {
    const params = {
      ...filters,
      page,
      limit
    }
    return await api.get('/resources', params)
  }

  /**
   * Get a specific resource by ID (requires authentication)
   * @param {String} id - Resource ID
   * @returns {Promise} Resource object
   */
  async getResource(id) {
    return await api.get(`/resources/${id}`)
  }

  /**
   * Create a new resource (requires authentication)
   * @param {Object} resourceData - Resource data to create
   * @returns {Promise} Created resource
   */
  async createResource(resourceData) {
    return await api.post('/resources', resourceData)
  }

  /**
   * Update an existing resource (requires authentication)
   * @param {String} id - Resource ID
   * @param {Object} resourceData - Updated resource data
   * @returns {Promise} Updated resource
   */
  async updateResource(id, resourceData) {
    return await api.put(`/resources/${id}`, resourceData)
  }

  /**
   * Delete a resource (requires authentication)
   * @param {String} id - Resource ID
   * @returns {Promise} Deletion confirmation
   */
  async deleteResource(id) {
    return await api.delete(`/resources/${id}`)
  }

  /**
   * Search resources by keyword (requires authentication)
   * @param {String} searchTerm - Search term
   * @returns {Promise} Array of matching resources
   */
  async searchResources(searchTerm) {
    return await api.get('/resources', { search: searchTerm })
  }

  /**
   * Get resources by type (requires authentication)
   * @param {String} type - Resource type (PHOTO, VIDEO, AUDIO)
   * @returns {Promise} Array of resources of the specified type
   */
  async getResourcesByType(type) {
    return await api.get('/resources', { type })
  }

  /**
   * Upload a resource file (requires authentication)
   * @param {File} file - File to upload
   * @param {Object} metadata - Additional metadata for the resource
   * @returns {Promise} Uploaded resource information
   */
  async uploadResource(file, metadata = {}) {
    const formData = new FormData()
    formData.append('file', file)
    
    Object.keys(metadata).forEach(key => {
      formData.append(key, metadata[key])
    })

    return await api.post('/resources', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  }
}

export default new ResourceService()