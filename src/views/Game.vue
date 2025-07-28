<template>
  <v-container fluid class="pa-0 game-container">
    <v-row no-gutters>
      <v-col cols="12" class="d-flex align-center">
        <iframe
          ref="unityIframe"
          :src="unityBundlePath"
          class="unity-iframe"
          allowfullscreen
          allow="fullscreen"
          @load="onUnityLoaded"
        />
        <v-btn
          v-if="!loading"
          :icon="isFullscreen ? 'mdi-fullscreen-exit' : 'mdi-fullscreen'"
          color="primary"
          variant="elevated"
          class="fullscreen-btn"
          @click="toggleFullscreen"
        >
        </v-btn>
      </v-col>
    </v-row>
    
    <v-overlay
      v-model="loading"
      persistent
      class="align-center justify-center"
    >
      <v-card
        class="pa-6 text-center"
        rounded="lg"
        elevation="8"
      >
        <v-progress-circular
          indeterminate
          size="80"
          width="6"
          color="primary"
        />
        <h2 class="mt-4 text-h5 font-weight-bold">Loading Unity Game...</h2>
        <p class="text-subtitle-1 text-grey mt-2">Please wait while we prepare your gaming experience</p>
      </v-card>
    </v-overlay>
  </v-container>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const loading = ref(true)
const unityBundlePath = ref('/Bundle/index.html')
const unityIframe = ref(null)
const isFullscreen = ref(false)

const onUnityLoaded = () => {
  loading.value = false
}

const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    if (unityIframe.value.requestFullscreen) {
      unityIframe.value.requestFullscreen()
    } else if (unityIframe.value.webkitRequestFullscreen) {
      unityIframe.value.webkitRequestFullscreen()
    } else if (unityIframe.value.msRequestFullscreen) {
      unityIframe.value.msRequestFullscreen()
    }
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen()
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen()
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen()
    }
  }
}

const handleFullscreenChange = () => {
  isFullscreen.value = !!document.fullscreenElement
}

onMounted(() => {
  document.addEventListener('fullscreenchange', handleFullscreenChange)
  document.addEventListener('webkitfullscreenchange', handleFullscreenChange)
  document.addEventListener('msfullscreenchange', handleFullscreenChange)
})

onUnmounted(() => {
  document.removeEventListener('fullscreenchange', handleFullscreenChange)
  document.removeEventListener('webkitfullscreenchange', handleFullscreenChange)
  document.removeEventListener('msfullscreenchange', handleFullscreenChange)
})
</script>

<style scoped>
.game-container {
  height: calc(100vh - 64px);
  position: relative;
}

.unity-iframe {
  width: 100%;
  height: 100%;
  border: none;
}

.fullscreen-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 10;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}
</style>