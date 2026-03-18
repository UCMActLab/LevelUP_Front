<template>
  <div ref="gameWrapper" class="game-wrapper">
    <iframe
      ref="unityIframe"
      :src="unityBundlePath"
      class="unity-iframe"
      allowfullscreen
      allow="fullscreen"
      @load="onUnityLoaded"
    />
    
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
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const loading = ref(true)
const unityBundlePath = ref('/Bundle/index.html')
const unityIframe = ref(null)
const gameWrapper = ref(null)
const isFullscreen = ref(false)

const onUnityLoaded = () => {
  loading.value = false
}

const toggleFullscreen = async () => {
  const element = gameWrapper.value

  if (!element) return

  // Check if we're currently in fullscreen
  const isCurrentlyFullscreen = document.fullscreenElement ||
                                  document.webkitFullscreenElement ||
                                  document.mozFullScreenElement ||
                                  document.msFullscreenElement

  if (!isCurrentlyFullscreen) {
    // Enter fullscreen
    try {
      if (element.requestFullscreen) {
        await element.requestFullscreen()
      } else if (element.webkitRequestFullscreen) {
        // iOS Safari
        await element.webkitRequestFullscreen()
      } else if (element.webkitEnterFullscreen) {
        // Older iOS devices
        await element.webkitEnterFullscreen()
      } else if (element.mozRequestFullScreen) {
        // Firefox
        await element.mozRequestFullScreen()
      } else if (element.msRequestFullscreen) {
        // IE/Edge
        await element.msRequestFullscreen()
      }
    } catch (err) {
      console.error('Error attempting to enable fullscreen:', err)
    }
  } else {
    // Exit fullscreen
    try {
      if (document.exitFullscreen) {
        await document.exitFullscreen()
      } else if (document.webkitExitFullscreen) {
        await document.webkitExitFullscreen()
      } else if (document.mozCancelFullScreen) {
        await document.mozCancelFullScreen()
      } else if (document.msExitFullscreen) {
        await document.msExitFullscreen()
      }
    } catch (err) {
      console.error('Error attempting to exit fullscreen:', err)
    }
  }
}

const handleFullscreenChange = () => {
  isFullscreen.value = !!(document.fullscreenElement ||
                           document.webkitFullscreenElement ||
                           document.mozFullScreenElement ||
                           document.msFullscreenElement)
}

onMounted(() => {
  document.addEventListener('fullscreenchange', handleFullscreenChange)
  document.addEventListener('webkitfullscreenchange', handleFullscreenChange)
  document.addEventListener('mozfullscreenchange', handleFullscreenChange)
  document.addEventListener('msfullscreenchange', handleFullscreenChange)
})

onUnmounted(() => {
  document.removeEventListener('fullscreenchange', handleFullscreenChange)
  document.removeEventListener('webkitfullscreenchange', handleFullscreenChange)
  document.removeEventListener('mozfullscreenchange', handleFullscreenChange)
  document.removeEventListener('msfullscreenchange', handleFullscreenChange)
})
</script>

<style scoped>
.game-wrapper {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 100vh;
  background-color: #000;
}

.unity-iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: none;
}
</style>