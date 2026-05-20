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
        <p class="mt-4 text-h6">Loading resource for editing...</p>
      </v-col>
    </v-row>
    
    <v-row v-else-if="contract">
      <v-col cols="12">
        <v-card
          elevation="2"
          rounded="lg"
        >
          <v-card-title class="bg-warning pa-6">
            <div>
              <v-icon color="white" size="32" class="mr-3">mdi-pencil</v-icon>
              <span class="text-h4 text-white">Edit Question</span>
            </div>
          </v-card-title>
          
          <v-card-text class="pa-6">
            <v-form ref="form" v-model="valid">
              <v-row>
                <v-col cols="12">
                  <v-text-field
                    v-model="formData.Headline"
                    label="Headline"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-format-title"
                    density="comfortable"
                  ></v-text-field>
                </v-col>

                <v-col cols="12">
                  <v-textarea
                    v-model="formData.Body"
                    label="Body"
                    :rules="[rules.required]"
                    variant="outlined"
                    rows="4"
                    prepend-inner-icon="mdi-text"
                    density="comfortable"
                  ></v-textarea>
                </v-col>

                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formData.Language"
                    label="Language"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-translate"
                    density="comfortable"
                    placeholder="es, en, pt, etc"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="6">
                  <v-switch
                    v-model="formData.isTrue"
                    label="Is this information true?"
                    color="success"
                    inset
                    hide-details
                  ></v-switch>
                </v-col>
               <v-col cols="12" md="6">
                <v-select
                  v-model="formData.Themes"
                  label="Theme"
                  :rules="[rules.required]"
                  variant="outlined"
                  prepend-inner-icon="mdi-tag-outline"
                  density="comfortable"
                  :items="themeOptions"
                  item-title="label"
                  item-value="value"
                ></v-select>
              </v-col>

                <v-col cols="12">
                  <v-combobox
                    v-model="formData.ImmediateFeedbacks"
                    label="Immediate Feedbacks"
                    variant="outlined"
                    prepend-inner-icon="mdi-message-text-fast"
                    density="comfortable"
                    placeholder="Type a feedback and press Enter"
                    multiple
                    chips
                    closable-chips
                  ></v-combobox>
                </v-col>

                <v-col cols="12">
                  <v-text-field
                    v-model="formData.Multimedia"
                    label="Multimedia"
                    variant="outlined"
                    prepend-inner-icon="mdi-image"
                    density="comfortable"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formData.Source"
                    label="Source"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-source-branch"
                    density="comfortable"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formData.Links"
                    label="Links"
                    variant="outlined"
                    prepend-inner-icon="mdi-link"
                    density="comfortable"
                  ></v-text-field>
                </v-col>

                <v-col cols="12">
                  <v-textarea
                    v-model="conversationJson"
                    label="Conversation (JSON Format)"
                    variant="outlined"
                    rows="6"
                    prepend-inner-icon="mdi-message-text"
                    placeholder='[{"Messages": [{"Sender": "Sandra", "MessageList": ["..."]}]}]'
                  ></v-textarea>
                </v-col>
              </v-row>
            </v-form>
          </v-card-text>
          
          <v-card-actions class="pa-6 bg-grey-lighten-5">
            <v-spacer></v-spacer>
            <v-btn
              color="error"
              variant="tonal"
              size="large"
              @click="cancel"
              class="mr-3"
            >
              Cancel
            </v-btn>
            <v-btn
              color="success"
              variant="elevated"
              size="large"
              :disabled="!valid"
              prepend-icon="mdi-content-save"
              @click="saveContract"
            >
              Save Changes
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

const form = ref(null)
const valid = ref(false)
const snackbar = ref(false)
const snackbarText = ref('')
const snackbarColor = ref('success')
const contract = ref(null)
const loading = ref(true)

const conversationJson = ref('')
const themeOptions = [
  'General Disinformation',
  'Science, Climate, and Health',
  'Scams and online security',
  'Conspiracy theories',
  'Artificial Intelligence',
]
const formData = ref({
  Headline: '',
  Body: '',
  Language: '',
  isTrue: false,
  Themes: '',
  ImmediateFeedbacks: [],
  Multimedia: '',
  Source: '',
  Links: '',
  Conversation: []
})

const rules = {
  required: value => !!value || 'Field is required'
}

onMounted(async () => {
  loading.value = true
  try {
    contract.value = await contractStore.getContractById(props.id)
    if (contract.value) {
      formData.value = { ...contract.value }
      // Ensure ImmediateFeedbacks is always an array
      if (!Array.isArray(formData.value.ImmediateFeedbacks)) {
        formData.value.ImmediateFeedbacks = []
      }
      // Convert Conversation array to JSON string for editing
      if (contract.value.Conversation && Array.isArray(contract.value.Conversation)) {
        conversationJson.value = JSON.stringify(contract.value.Conversation, null, 2)
      }
    }
  } catch (error) {
    console.error('Error loading contract:', error)
  } finally {
    loading.value = false
  }
})

const saveContract = async () => {
  if (form.value.validate()) {
    try {
      // Parse conversation JSON if provided
      if (conversationJson.value) {
        try {
          formData.value.Conversation = JSON.parse(conversationJson.value)
        } catch (e) {
          snackbarText.value = 'Invalid JSON format for Conversation'
          snackbarColor.value = 'error'
          snackbar.value = true
          return
        }
      }

      await contractStore.updateContract(props.id, formData.value)
      snackbarText.value = 'Resource updated successfully!'
      snackbarColor.value = 'success'
      snackbar.value = true

      setTimeout(() => {
        router.push({ name: 'contract-detail', params: { id: props.id } })
      }, 1500)
    } catch (error) {
      snackbarText.value = 'Error updating resource'
      snackbarColor.value = 'error'
      snackbar.value = true
    }
  }
}

const cancel = () => {
  router.back()
}
</script>
