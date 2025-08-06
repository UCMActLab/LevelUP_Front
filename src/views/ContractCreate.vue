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
                    v-model="formData.title"
                    label="Resource Title"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-help-circle"
                    density="comfortable"
                    placeholder="Enter the title for your resource"
                  ></v-text-field>
                </v-col>
                
                <v-col cols="12">
                  <v-textarea
                    v-model="formData.description"
                    label="Description"
                    :rules="[rules.required]"
                    variant="outlined"
                    rows="3"
                    prepend-inner-icon="mdi-text"
                    placeholder="Provide a detailed description of the resource"
                  ></v-textarea>
                </v-col>
                
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formData.country"
                    label="Country"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-map-marker"
                    density="comfortable"
                    placeholder="e.g., España"
                  ></v-text-field>
                </v-col>
                
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formData.conversationRef"
                    label="Conversation Reference"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-message-text"
                    density="comfortable"
                    placeholder="e.g., QUESTION1"
                  ></v-text-field>
                </v-col>
                
                <v-col cols="12">
                  <v-textarea
                    v-model="formData.answers"
                    label="Answers"
                    variant="outlined"
                    rows="4"
                    prepend-inner-icon="mdi-comment-check"
                    placeholder="Provide answers or solutions related to this resource"
                  ></v-textarea>
                </v-col>
                
                <v-col cols="12">
                  <v-textarea
                    v-model="formData.resources"
                    label="Additional Resources"
                    variant="outlined"
                    rows="3"
                    prepend-inner-icon="mdi-folder-open"
                    placeholder="List any additional resources, links, or references"
                  ></v-textarea>
                </v-col>

                <v-col cols="12">
                  <v-select
                    v-model="formData.type"
                    label="Resource Type"
                    :items="resourceTypes"
                    variant="outlined"
                    prepend-inner-icon="mdi-tag"
                    density="comfortable"
                    placeholder="Select resource type"
                  ></v-select>
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

const formData = ref({
  title: '',
  description: '',
  country: '',
  conversationRef: '',
  answers: '',
  resources: '',
  type: ''
})

const resourceTypes = [
  { title: 'Question', value: 'QUESTION' },
  { title: 'Answer', value: 'ANSWER' },
  { title: 'Photo', value: 'PHOTO' },
  { title: 'Video', value: 'VIDEO' },
  { title: 'Audio', value: 'AUDIO' },
  { title: 'Document', value: 'DOCUMENT' },
  { title: 'Other', value: 'OTHER' }
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