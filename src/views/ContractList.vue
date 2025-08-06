<template>
  <v-container class="py-8">
    <v-row>
      <v-col cols="12">
        <div class="d-flex align-center justify-space-between mb-6">
          <div class="d-flex align-center">
            <v-icon color="primary" size="40" class="mr-3">mdi-help-circle-outline</v-icon>
            <h1 class="text-h3 font-weight-bold">Resources</h1>
          </div>
          <v-btn
            color="success"
            size="large"
            variant="elevated"
            prepend-icon="mdi-plus"
            @click="createResource"
          >
            Create Resource
          </v-btn>
        </div>
      </v-col>
    </v-row>
    
    <v-row>
      <v-col cols="12">
        <v-card
          elevation="2"
          rounded="lg"
        >
          <v-card-title class="pa-6 bg-grey-lighten-5">
            <v-text-field
              v-model="search"
              prepend-inner-icon="mdi-magnify"
              label="Search resources..."
              single-line
              hide-details
              variant="outlined"
              density="compact"
              class="mb-2"
            ></v-text-field>
          </v-card-title>
          
          <v-data-table
            :headers="headers"
            :items="contractStore.contracts"
            :search="search"
            :items-per-page="10"
            hover
          >
            <template v-slot:item.title="{ item }">
              <div class="text-subtitle-1 font-weight-medium">
                {{ item.title }}
              </div>
              <div class="text-caption text-grey">
                {{ item.description.substring(0, 100) }}...
              </div>
            </template>
            
            <template v-slot:item.createdAt="{ item }">
              <v-chip
                color="blue-grey"
                variant="tonal"
                size="small"
              >
                {{ formatDate(item.createdAt) }}
              </v-chip>
            </template>
            
            <template v-slot:item.country="{ item }">
              <v-chip
                color="green"
                variant="tonal"
                size="small"
              >
                <v-icon start size="16">mdi-map-marker</v-icon>
                {{ item.country }}
              </v-chip>
            </template>
            
            <template v-slot:item.actions="{ item }">
              <v-btn
                icon="mdi-eye"
                color="info"
                variant="tonal"
                size="small"
                @click="viewContract(getItemId(item))"
              >
              </v-btn>
              <v-btn
                icon="mdi-pencil"
                color="warning"
                variant="tonal"
                size="small"
                class="ml-2"
                @click="editContract(getItemId(item))"
              >
              </v-btn>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { contractStore } from '@/stores/contracts'

const router = useRouter()
const search = ref('')

onMounted(async () => {
  await contractStore.fetchContracts()
})

const headers = [
  { title: 'Resource', key: 'title', width: '40%' },
  { title: 'Country', key: 'country', align: 'center' },
  { title: 'Reference', key: 'conversationRef', align: 'center' },
  { title: 'Created', key: 'createdAt', align: 'center' },
  { title: 'Actions', key: 'actions', sortable: false, align: 'center', width: '120px' }
]

const getItemId = (item) => {
  if (typeof item._id === 'string') return item._id
  if (item._id?.$oid) return item._id.$oid
  return null
}

const formatDate = (dateObj) => {
  if (dateObj?.$date) {
    return new Date(dateObj.$date).toLocaleDateString()
  }
  return ''
}

const viewContract = (id) => {
  router.push({ name: 'contract-detail', params: { id } })
}

const editContract = (id) => {
  router.push({ name: 'contract-edit', params: { id } })
}

const createResource = () => {
  router.push({ name: 'contract-create' })
}
</script>