<template>
  <v-container class="py-8">
    <v-row>
      <v-col cols="12">
        <v-btn
          color="primary"
          variant="tonal"
          prepend-icon="mdi-arrow-left"
          @click="$router.back()"
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
              <span class="text-h4 text-white">{{ contract.Headline }}</span>
            </div>
          </v-card-title>

          <v-card-text class="pa-6">
            <v-alert
              color="blue-grey"
              variant="tonal"
              class="mb-6"
            >
              <div class="text-body-1">{{ contract.Body }}</div>
            </v-alert>

            <v-row>
              <v-col cols="12" md="4">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="blue" class="mr-2">mdi-translate</v-icon>
                    <span class="text-subtitle-2 text-grey">Language</span>
                  </div>
                  <div class="text-h6">{{ contract.Language }}</div>
                </v-card>
              </v-col>

              <v-col cols="12" md="4">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon :color="contract.isTrue ? 'success' : 'error'" class="mr-2">
                      {{ contract.isTrue ? 'mdi-check-circle' : 'mdi-close-circle' }}
                    </v-icon>
                    <span class="text-subtitle-2 text-grey">Status</span>
                  </div>
                  <div class="text-h6">{{ contract.isTrue ? 'True' : 'False' }}</div>
                </v-card>
              </v-col>

              <v-col cols="12" md="4">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="purple" class="mr-2">mdi-source-branch</v-icon>
                    <span class="text-subtitle-2 text-grey">Source</span>
                  </div>
                  <div class="text-h6">{{ contract.Source }}</div>
                </v-card>
              </v-col>

              <v-col cols="12" md="6" v-if="contract.Multimedia">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="orange" class="mr-2">mdi-image</v-icon>
                    <span class="text-subtitle-2 text-grey">Multimedia</span>
                  </div>
                  <div class="text-body-2">{{ contract.Multimedia }}</div>
                </v-card>
              </v-col>

              <v-col cols="12" md="6" v-if="contract.Links">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="indigo" class="mr-2">mdi-link</v-icon>
                    <span class="text-subtitle-2 text-grey">Links</span>
                  </div>
                  <a :href="contract.Links" target="_blank" class="text-body-2">{{ contract.Links }}</a>
                </v-card>
              </v-col>

              <v-col cols="12" md="6">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="teal" class="mr-2">mdi-calendar-plus</v-icon>
                    <span class="text-subtitle-2 text-grey">Created</span>
                  </div>
                  <div class="text-h6">{{ formatDate(contract.createdAt) }}</div>
                </v-card>
              </v-col>

              <v-col cols="12" md="6">
                <v-card variant="outlined" class="pa-4">
                  <div class="d-flex align-center mb-3">
                    <v-icon color="amber" class="mr-2">mdi-calendar-edit</v-icon>
                    <span class="text-subtitle-2 text-grey">Last Updated</span>
                  </div>
                  <div class="text-h6">{{ formatDate(contract.updatedAt) }}</div>
                </v-card>
              </v-col>
            </v-row>

            <v-divider class="my-6"></v-divider>

            <div v-if="contract.Conversation && contract.Conversation.length > 0">
              <div class="d-flex align-center mb-4">
                <v-icon color="success" size="28" class="mr-2">mdi-message-text</v-icon>
                <h3 class="text-h5">Conversation</h3>
              </div>
              <v-expansion-panels>
                <v-expansion-panel
                  v-for="(conversation, idx) in contract.Conversation"
                  :key="idx"
                >
                  <v-expansion-panel-title>
                    <v-icon class="mr-2">mdi-forum</v-icon>
                    Conversation {{ idx + 1 }}
                  </v-expansion-panel-title>
                  <v-expansion-panel-text>
                    <v-card
                      v-for="(message, msgIdx) in conversation.Messages"
                      :key="msgIdx"
                      class="mb-3"
                      variant="outlined"
                    >
                      <v-card-title class="bg-grey-lighten-4 py-2">
                        <v-icon size="20" class="mr-2">mdi-account</v-icon>
                        {{ message.Sender }}
                      </v-card-title>
                      <v-card-text class="pa-3">
                        <ul>
                          <li v-for="(msg, listIdx) in message.MessageList" :key="listIdx">
                            {{ msg }}
                          </li>
                        </ul>
                      </v-card-text>
                    </v-card>
                  </v-expansion-panel-text>
                </v-expansion-panel>
              </v-expansion-panels>
            </div>
          </v-card-text>
          
          <v-card-actions class="pa-6 bg-grey-lighten-5">
            <v-btn
              color="error"
              variant="tonal"
              size="large"
              prepend-icon="mdi-delete"
              @click="openDeleteDialog"
            >
              Delete
            </v-btn>
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

    <v-dialog
      v-model="deleteDialog"
      max-width="500"
    >
      <v-card>
        <v-card-title class="bg-error pa-6">
          <div class="d-flex align-center">
            <v-icon color="white" size="32" class="mr-3">mdi-alert-circle</v-icon>
            <span class="text-h5 text-white">Confirm Delete</span>
          </div>
        </v-card-title>
        <v-card-text class="pa-6">
          <p class="text-h6 mb-2">Are you sure you want to delete this resource?</p>
          <p class="text-body-1">
            <strong>{{ contract?.Headline }}</strong>
          </p>
          <p class="text-body-2 text-grey mt-2">This action cannot be undone.</p>
        </v-card-text>
        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn
            color="grey"
            variant="text"
            @click="closeDeleteDialog"
            :disabled="deleting"
          >
            Cancel
          </v-btn>
          <v-btn
            color="error"
            variant="elevated"
            @click="confirmDelete"
            :loading="deleting"
          >
            Delete
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar
      v-model="snackbar"
      :color="snackbarColor"
      rounded="pill"
      location="top"
    >
      {{ snackbarText }}
      <template v-slot:actions>
        <v-btn
          variant="text"
          @click="snackbar = false"
        >
          Close
        </v-btn>
      </template>
    </v-snackbar>
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
const deleteDialog = ref(false)
const deleting = ref(false)
const snackbar = ref(false)
const snackbarText = ref('')
const snackbarColor = ref('success')

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

const openDeleteDialog = () => {
  deleteDialog.value = true
}

const closeDeleteDialog = () => {
  deleteDialog.value = false
}

const confirmDelete = async () => {
  deleting.value = true
  try {
    await contractStore.deleteContract(props.id)

    snackbarText.value = 'Resource deleted successfully!'
    snackbarColor.value = 'success'
    snackbar.value = true

    closeDeleteDialog()

    // Redirect to list after successful deletion
    setTimeout(() => {
      router.push('/back-office')
    }, 1500)
  } catch (error) {
    console.error('Error deleting resource:', error)
    snackbarText.value = 'Error deleting resource. Please try again.'
    snackbarColor.value = 'error'
    snackbar.value = true
    deleting.value = false
  }
}
</script>
