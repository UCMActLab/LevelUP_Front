/**
 * Central export point for all API services
 * This file aggregates all service modules for easy import
 */

import authService from './authService'
import resourceService from './resourceService'
import contractService from './contractService'
import healthService from './healthService'
import api from './api'

// Export individual services
export {
  authService,
  resourceService,
  contractService,
  healthService,
  api
}

// Export as default for convenience
export default {
  auth: authService,
  resources: resourceService,
  contracts: contractService,
  health: healthService,
  api
}

/**
 * API Routes Summary:
 * 
 * PUBLIC ROUTES (No authentication required):
 * - GET  /health          - Health check endpoint
 * - POST /login           - User login
 * 
 * PROTECTED ROUTES (Authentication required):
 * - GET  /resources       - Get all resources
 * - GET  /resources/:id   - Get specific resource by ID
 * - POST /resources       - Create new resource
 * 
 * Note: Protected routes require 'genericAuth' middleware
 * Token should be sent in Authorization header as: Bearer <token>
 */