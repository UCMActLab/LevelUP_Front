<template>
  <v-app>
    <v-btn
      v-if="authStore.isAuthenticated && !isLoginPage"
      icon="mdi-logout"
      color="error"
      variant="elevated"
      class="logout-btn"
      @click="handleLogout"
      title="Logout"
    />
    <v-main class="grey lighten-4">
      <router-view />
    </v-main>
  </v-app>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()

const isLoginPage = computed(() => route.name === 'login')

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>

<style>
.v-application {
  font-family: 'Roboto', sans-serif !important;
}

.logout-btn {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}
</style>