<template>
  <v-container class="py-8">
    <v-row>
      <v-col cols="12">
        <v-btn
          color="primary"
          variant="tonal"
          prepend-icon="mdi-arrow-left"
          @click="$router.push('/back-office')"
          class="mb-6"
        >
          Back to Questions
        </v-btn>
      </v-col>
    </v-row>

    <v-row v-if="loading">
      <v-col cols="12" class="text-center">
        <v-progress-circular
          indeterminate
          color="primary"
          size="64"
        ></v-progress-circular>
        <p class="mt-4 text-h6">Loading resource details...</p>
      </v-col>
    </v-row>
    
    <v-row v-else-if="contract">
      <v-col cols="12">
        <v-card
          elevation="2"
          rounded="lg"
        >
          <v-card-title class="bg-primary pa-6">
            <div>
              <v-icon color="white" size="32" class="mr-3">mdi-help-circle</v-icon>
              <span class="text-h4 text-white">{{ contract.title }}</span>
            </div>
          </v-card-title>
          
          <v-card-text class="pa-6">
            <v-alert
              color="blue-grey"
              variant="tonal"
              class="mb-6"
            >
              <div class="text-body-1">{{ contract.description }}</div>
            </v-alert>
            
            <v-row>
              <v-col cols="12" md="6">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="green" class="mr-2">mdi-map-marker</v-icon>
                    <span class="text-subtitle-2 text-grey">Country</span>
                  </div>
                  <div class="text-h6">{{ contract.country }}</div>
                </v-card>
              </v-col>
              
              <v-col cols="12" md="6">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="blue" class="mr-2">mdi-message-text</v-icon>
                    <span class="text-subtitle-2 text-grey">Conversation Reference</span>
                  </div>
                  <div class="text-h6">{{ contract.conversationRef }}</div>
                </v-card>
              </v-col>
              
              <v-col cols="12" md="6">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="orange" class="mr-2">mdi-calendar-plus</v-icon>
                    <span class="text-subtitle-2 text-grey">Created</span>
                  </div>
                  <div class="text-h6">{{ formatDate(contract.createdAt) }}</div>
                </v-card>
              </v-col>
              
              <v-col cols="12" md="6">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="purple" class="mr-2">mdi-calendar-edit</v-icon>
                    <span class="text-subtitle-2 text-grey">Last Updated</span>
                  </div>
                  <div class="text-h6">{{ formatDate(contract.updatedAt) }}</div>
                </v-card>
              </v-col>
            </v-row>
            
            <v-divider class="my-6"></v-divider>
            
            <div v-if="contract.answers">
              <div class="d-flex align-center mb-4">
                <v-icon color="success" size="28" class="mr-2">mdi-comment-check</v-icon>
                <h3 class="text-h5">Answers</h3>
              </div>
              <v-card color="green-lighten-5" variant="flat" class="pa-4">
                <pre class="text-body-2" style="white-space: pre-wrap; font-family: inherit;">{{ contract.answers }}</pre>
              </v-card>
            </div>
            
            <div v-if="contract.resources" class="mt-6">
              <div class="d-flex align-center mb-4">
                <v-icon color="info" size="28" class="mr-2">mdi-folder-open</v-icon>
                <h3 class="text-h5">Resources</h3>
              </div>
              <v-card color="blue-lighten-5" variant="flat" class="pa-4">
                <pre class="text-body-2" style="white-space: pre-wrap; font-family: inherit;">{{ contract.resources }}</pre>
              </v-card>
            </div>
          </v-card-text>
          
          <v-card-actions class="pa-6 bg-grey-lighten-5">
            <v-spacer></v-spacer>
            <v-btn
              color="warning"
              variant="elevated"
              size="large"
              prepend-icon="mdi-pencil"
              @click="editContract"
            >
              Edit Question
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    
    <v-row v-else>
      <v-col cols="12">
        <v-alert type="error">
          Resource not found or failed to load
        </v-alert>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { contractStore } from '@/stores/contracts'

const router = useRouter()
const route = useRoute()

const props = defineProps({
  id: {
    type: String,
    required: true
  }
})

const contract = ref(null)
const loading = ref(true)

onMounted(async () => {
  loading.value = true
  try {
    contract.value = await contractStore.getContractById(props.id)
  } catch (error) {
    console.error('Error loading contract:', error)
  } finally {
    loading.value = false
  }
})

const formatDate = (dateObj) => {
  if (dateObj?.$date) {
    return new Date(dateObj.$date).toLocaleString()
  }
  if (dateObj) {
    return new Date(dateObj).toLocaleString()
  }
  return ''
}

const editContract = () => {
  router.push({ name: 'contract-edit', params: { id: props.id } })
}
</script>
