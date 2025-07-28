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

    <v-row v-if="contract">
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
                    v-model="formData.title"
                    label="Question Title"
                    :rules="[rules.required]"
                    variant="outlined"
                    prepend-inner-icon="mdi-help-circle"
                    density="comfortable"
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
                    density="comfortable"
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
                  ></v-text-field>
                </v-col>
                
                <v-col cols="12">
                  <v-expansion-panels class="mb-4">
                    <v-expansion-panel>
                      <v-expansion-panel-title>
                        <v-icon class="mr-2">mdi-comment-check</v-icon>
                        Answers (JSON Format)
                      </v-expansion-panel-title>
                      <v-expansion-panel-text>
                        <v-textarea
                          v-model="formData.answers"
                          label="Answers"
                          variant="outlined"
                          rows="5"
                          class="mt-4"
                        ></v-textarea>
                      </v-expansion-panel-text>
                    </v-expansion-panel>
                    
                    <v-expansion-panel>
                      <v-expansion-panel-title>
                        <v-icon class="mr-2">mdi-folder-open</v-icon>
                        Resources (JSON Format)
                      </v-expansion-panel-title>
                      <v-expansion-panel-text>
                        <v-textarea
                          v-model="formData.resources"
                          label="Resources"
                          variant="outlined"
                          rows="4"
                          class="mt-4"
                        ></v-textarea>
                      </v-expansion-panel-text>
                    </v-expansion-panel>
                  </v-expansion-panels>
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
          Contract not found
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
import { ref, computed, onMounted } from 'vue'
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

const contract = computed(() => {
  return contractStore.getContractById(props.id)
})

const formData = ref({
  title: '',
  description: '',
  country: '',
  conversationRef: '',
  answers: '',
  resources: ''
})

const rules = {
  required: value => !!value || 'Field is required'
}

onMounted(() => {
  if (contract.value) {
    formData.value = { ...contract.value }
  }
})

const saveContract = async () => {
  if (form.value.validate()) {
    contractStore.updateContract(props.id, formData.value)
    snackbarText.value = 'Contract updated successfully!'
    snackbarColor.value = 'success'
    snackbar.value = true
    
    setTimeout(() => {
      router.push({ name: 'contract-detail', params: { id: props.id } })
    }, 1500)
  }
}

const cancel = () => {
  router.push({ name: 'contract-detail', params: { id: props.id } })
}
</script>