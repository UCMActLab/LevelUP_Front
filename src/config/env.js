const env = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8079',
  environment: import.meta.env.VITE_APP_ENV || 'local',
  appName: import.meta.env.VITE_APP_NAME || 'LevelUP',
  apiTimeout: parseInt(import.meta.env.VITE_API_TIMEOUT) || 30000,
  isDevelopment: import.meta.env.VITE_APP_ENV === 'development' || import.meta.env.VITE_APP_ENV === 'local',
  isProduction: import.meta.env.VITE_APP_ENV === 'production'
}

export default env