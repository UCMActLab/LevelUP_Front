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
    
    <v-btn
      v-if="!showOverlay"
      :icon="isFullscreen ? 'mdi-fullscreen-exit' : 'mdi-fullscreen'"
      color="primary"
      variant="elevated"
      class="fullscreen-btn"
      @click="toggleFullscreen"
    >
    </v-btn>
    
    <v-overlay
      v-model="showOverlay"
      persistent
      class="align-center justify-center"
    >
      <v-card
        class="pa-6 text-center"
        rounded="lg"
        elevation="8"
      >
        <div v-if="loading">
          <v-progress-circular
            indeterminate
            size="80"
            width="6"
            color="primary"
          />
          <h2 class="mt-4 text-h5 font-weight-bold">Loading Unity Game...</h2>
          <p class="text-subtitle-1 text-grey mt-2">Please wait while we prepare your gaming experience</p>
        </div>

        <div v-else>
          <h2 class="text-h5 font-weight-bold mb-4">Game is Ready!</h2>
          <v-btn
            color="primary"
            size="x-large"
            prepend-icon="mdi-play"
            @click="startGame"
          >
            Play in Fullscreen
          </v-btn>
        </div>
      </v-card>
    </v-overlay>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const loading = ref(true)
const showOverlay = ref(true) // Controls the entire overlay
const unityBundlePath = ref('/Bundle/index.html')
const unityIframe = ref(null)
const gameWrapper = ref(null)
const isFullscreen = ref(false)

const onUnityLoaded = () => {
  // Stop loading, but DO NOT try to fullscreen yet
  loading.value = false
}

const startGame = async () => {
  // 1. Hide the overlay
  showOverlay.value = false
  // 2. We now have a trusted user click, so we can trigger fullscreen safely
  await toggleFullscreen()
}

const toggleFullscreen = async () => {
  const element = gameWrapper.value

  if (!element) return

  const isCurrentlyFullscreen = document.fullscreenElement ||
                                document.webkitFullscreenElement ||
                                document.mozFullScreenElement ||
                                document.msFullscreenElement

  if (!isCurrentlyFullscreen) {
    try {
      if (element.requestFullscreen) {
        await element.requestFullscreen()
      } else if (element.webkitRequestFullscreen) {
        await element.webkitRequestFullscreen()
      } else if (element.webkitEnterFullscreen) {
        await element.webkitEnterFullscreen()
      } else if (element.mozRequestFullScreen) {
        await element.mozRequestFullScreen()
      } else if (element.msRequestFullscreen) {
        await element.msRequestFullscreen()
      }
    } catch (err) {
      console.error('Error attempting to enable fullscreen:', err)
    }
  } else {
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

/* Optional: Make sure the floating button stays on top */
.fullscreen-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  z-index: 10; /* Ensures it sits above the iframe */
}
</style>