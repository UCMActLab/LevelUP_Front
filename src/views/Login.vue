<template>
  <v-container fluid class="fill-height login-container">
    <v-row align="center" justify="center" class="fill-height">
      <v-col cols="12" sm="8" md="6" lg="4">
        <v-card elevation="8" rounded="lg" class="pa-4">
          <v-card-title class="text-center">
            <v-icon color="primary" size="48" class="mb-4">mdi-controller</v-icon>
            <h1 class="text-h4 font-weight-bold">LevelUP</h1>
            <p class="text-subtitle-1 text-grey mt-2">Sign in to your account</p>
          </v-card-title>
          
          <v-card-text>
            <v-form ref="loginForm" v-model="isFormValid" @submit.prevent="handleLogin">
              <v-text-field
                v-model="credentials.username"
                :rules="usernameRules"
                label="Username"
                type="text"
                variant="outlined"
                prepend-inner-icon="mdi-account"
                class="mb-3"
                required
              />
              
              <v-text-field
                v-model="credentials.password"
                :rules="passwordRules"
                :type="showPassword ? 'text' : 'password'"
                label="Password"
                variant="outlined"
                prepend-inner-icon="mdi-lock"
                :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                @click:append-inner="showPassword = !showPassword"
                class="mb-3"
                required
              />
              
              <v-checkbox
                v-model="rememberMe"
                label="Remember me"
                color="primary"
                class="mb-3"
              />
              
              <v-alert
                v-if="errorMessage"
                type="error"
                variant="tonal"
                closable
                @click:close="errorMessage = ''"
                class="mb-4"
              >
                {{ errorMessage }}
              </v-alert>
              
              <v-btn
                type="submit"
                block
                color="primary"
                size="large"
                :loading="isLoading"
                :disabled="!isFormValid || isLoading"
                class="mb-3"
              >
                Sign In
              </v-btn>
              
              <v-divider class="my-4" />
              
              <div class="text-center">
                <p class="text-body-2 text-grey">
                  Don't have an account? 
                  <a href="#" class="text-primary text-decoration-none">Sign up</a>
                </p>
                <p class="text-body-2 mt-2">
                  <a href="#" class="text-primary text-decoration-none">Forgot password?</a>
                </p>
              </div>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { authStore } from '@/stores/auth'

const router = useRouter()
const loginForm = ref(null)
const isFormValid = ref(false)
const isLoading = ref(false)
const showPassword = ref(false)
const rememberMe = ref(false)
const errorMessage = ref('')

const credentials = ref({
  username: '',
  password: ''
})

const usernameRules = [
  v => !!v || 'Username is required',
  v => v.length >= 3 || 'Username must be at least 3 characters'
]

const passwordRules = [
  v => !!v || 'Password is required',
  v => v.length >= 6 || 'Password must be at least 6 characters'
]

const handleLogin = async () => {
  if (!isFormValid.value) return
  
  isLoading.value = true
  errorMessage.value = ''
  
  try {
    await authStore.login(credentials.value.username, credentials.value.password, rememberMe.value)
    
    const redirectTo = router.currentRoute.value.query.redirect || '/back-office'
    router.push(redirectTo)
  } catch (error) {
    errorMessage.value = error.message || 'Invalid username or password'
  } finally {
    isLoading.value = false
  }
}

</script>

<style scoped>
.login-container {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}
</style>
