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

    <v-row>
      <v-col cols="12">
        <v-card
          elevation="2"
          rounded="lg"
        >
          <v-card-title class="bg-success pa-6">
            <div>
              <v-icon color="white" size="32" class="mr-3">mdi-plus-circle</v-icon>
              <span class="text-h4 text-white">Create New Resource</span>
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
                    placeholder="Enter the headline for this resource"
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
                    placeholder="Provide the main content of the resource"
                  ></v-textarea>
                </v-col>

                <v-col cols="12" md="6">
                  <v-select
                    v-model="formData.Language"
                    label="Language"
                    :items="languageOptions"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-translate"
                    density="comfortable"
                  ></v-select>
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

                <v-col cols="12">
                  <v-text-field
                    v-model="formData.Multimedia"
                    label="Multimedia"
                    variant="outlined"
                    prepend-inner-icon="mdi-image"
                    density="comfortable"
                    placeholder="e.g., image:1VzkETAxxY31FwQy3huUGs_NsVSm8-VFK"
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
                    placeholder="e.g., redes sociales"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formData.Links"
                    label="Links"
                    variant="outlined"
                    prepend-inner-icon="mdi-link"
                    density="comfortable"
                    placeholder="Enter relevant links"
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
            <v-btn
              color="error"
              variant="tonal"
              size="large"
              @click="cancel"
              class="mr-3"
              :disabled="loading"
            >
              Cancel
            </v-btn>
            <v-spacer></v-spacer>
            <v-btn
              color="success"
              variant="elevated"
              size="large"
              :disabled="!valid || loading"
              :loading="loading"
              prepend-icon="mdi-content-save"
              @click="createResource"
            >
              Create Resource
            </v-btn>
          </v-card-actions>
        </v-card>
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { contractStore } from '@/stores/contracts'

const router = useRouter()

const form = ref(null)
const valid = ref(false)
const loading = ref(false)
const snackbar = ref(false)
const snackbarText = ref('')
const snackbarColor = ref('success')
const conversationJson = ref('')

const formData = ref({
  Headline: '',
  Body: '',
  Language: 'es',
  isTrue: false,
  Multimedia: '',
  Source: '',
  Links: '',
  Conversation: []
})

const languageOptions = [
  { title: 'Español', value: 'es' },
  { title: 'English', value: 'en' },
  { title: 'Français', value: 'fr' },
  { title: 'Deutsch', value: 'de' }
]

const rules = {
  required: value => !!value || 'Field is required'
}

const createResource = async () => {
  if (!form.value.validate()) {
    return
  }

  loading.value = true

  try {
    // Parse conversation JSON if provided
    if (conversationJson.value) {
      try {
        formData.value.Conversation = JSON.parse(conversationJson.value)
      } catch (e) {
        snackbarText.value = 'Invalid JSON format for Conversation'
        snackbarColor.value = 'error'
        snackbar.value = true
        loading.value = false
        return
      }
    }

    const newResource = await contractStore.createContract(formData.value)

    snackbarText.value = 'Resource created successfully!'
    snackbarColor.value = 'success'
    snackbar.value = true

    setTimeout(() => {
      router.push('/back-office')
    }, 1500)
  } catch (error) {
    console.error('Error creating resource:', error)
    snackbarText.value = 'Error creating resource. Please try again.'
    snackbarColor.value = 'error'
    snackbar.value = true
  } finally {
    loading.value = false
  }
}

const cancel = () => {
  router.push('/back-office')
}
</script>

<style scoped>
.v-card-title {
  color: white;
}
</style>