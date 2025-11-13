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
          
          <v-data-table-server
            :headers="headers"
            :items="contractStore.contracts"
            :loading="contractStore.loading"
            :items-length="contractStore.totalItems"
            v-model:page="page"
            v-model:items-per-page="itemsPerPage"
            :items-per-page-options="itemsPerPageOptions"
            @update:page="handlePageUpdate"
            @update:items-per-page="handleItemsPerPageUpdate"
            hover
          >
            <template v-slot:no-data>
              <div class="text-center pa-4">
                <v-icon size="48" color="grey">mdi-file-document-outline</v-icon>
                <p class="text-h6 mt-2">No resources found</p>
              </div>
            </template>
            <template v-slot:item.Headline="{ item }">
              <div class="text-subtitle-1 font-weight-medium">
                {{ item.Headline }}
              </div>
              <div class="text-caption text-grey">
                {{ item.Body ? item.Body.substring(0, 100) + '...' : '' }}
              </div>
            </template>

            <template v-slot:item.Language="{ item }">
              <v-chip
                color="blue"
                variant="tonal"
                size="small"
              >
                <v-icon start size="16">mdi-translate</v-icon>
                {{ item.Language }}
              </v-chip>
            </template>

            <template v-slot:item.isTrue="{ item }">
              <v-chip
                :color="item.isTrue ? 'success' : 'error'"
                variant="tonal"
                size="small"
              >
                <v-icon start size="16">{{ item.isTrue ? 'mdi-check-circle' : 'mdi-close-circle' }}</v-icon>
                {{ item.isTrue ? 'True' : 'False' }}
              </v-chip>
            </template>

            <template v-slot:item.Source="{ item }">
              <v-chip
                color="purple"
                variant="tonal"
                size="small"
              >
                <v-icon start size="16">mdi-source-branch</v-icon>
                {{ item.Source }}
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
              <v-btn
                icon="mdi-delete"
                color="error"
                variant="tonal"
                size="small"
                class="ml-2"
                @click="openDeleteDialog(item)"
              >
              </v-btn>
            </template>
          </v-data-table-server>
        </v-card>
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
            <strong>{{ itemToDelete?.Headline }}</strong>
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
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { contractStore } from '@/stores/contracts'

const router = useRouter()
const route = useRoute()
const search = ref(route.query.search || '')
const page = ref(parseInt(route.query.page) || 1)
const itemsPerPage = ref(parseInt(route.query.itemsPerPage) || 10)
const deleteDialog = ref(false)
const itemToDelete = ref(null)
const deleting = ref(false)
const snackbar = ref(false)
const snackbarText = ref('')
const snackbarColor = ref('success')

const itemsPerPageOptions = [
  { value: 5, title: '5' },
  { value: 10, title: '10' },
  { value: 25, title: '25' },
  { value: 50, title: '50' },
  { value: 100, title: '100' }
]

const updateQueryParams = () => {
  const query = {
    page: page.value.toString(),
    itemsPerPage: itemsPerPage.value.toString()
  }
  if (search.value) {
    query.search = search.value
  }
  router.replace({ query })
}

const loadItems = async () => {
  const filters = search.value ? { search: search.value } : {}
  console.log('loadItems called with:', { page: page.value, itemsPerPage: itemsPerPage.value, filters })
  await contractStore.fetchContracts(page.value, itemsPerPage.value, filters)
  updateQueryParams()
}

const handlePageUpdate = async (newPage) => {
  console.log('Page updated to:', newPage)
  // v-model already updates page.value, just load items
  await loadItems()
}

const handleItemsPerPageUpdate = async (newItemsPerPage) => {
  console.log('Items per page updated to:', newItemsPerPage)
  // v-model already updates itemsPerPage.value
  page.value = 1 // Reset to first page when changing items per page
  await loadItems()
}

// Watch for search changes and reset to page 1
watch(search, () => {
  page.value = 1
  loadItems()
})

onMounted(async () => {
  await loadItems()
})

const headers = [
  { title: 'Resource', key: 'Headline', width: '35%' },
  { title: 'Language', key: 'Language', align: 'center' },
  { title: 'Status', key: 'isTrue', align: 'center' },
  { title: 'Source', key: 'Source', align: 'center' },
  { title: 'Actions', key: 'actions', sortable: false, align: 'center', width: '180px' }
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

const openDeleteDialog = (item) => {
  itemToDelete.value = item
  deleteDialog.value = true
}

const closeDeleteDialog = () => {
  deleteDialog.value = false
  itemToDelete.value = null
}

const confirmDelete = async () => {
  if (!itemToDelete.value) return

  deleting.value = true
  try {
    const id = getItemId(itemToDelete.value)
    await contractStore.deleteContract(id)

    snackbarText.value = 'Resource deleted successfully!'
    snackbarColor.value = 'success'
    snackbar.value = true

    closeDeleteDialog()

    // Reload the current page
    await loadItems()
  } catch (error) {
    console.error('Error deleting resource:', error)
    snackbarText.value = 'Error deleting resource. Please try again.'
    snackbarColor.value = 'error'
    snackbar.value = true
  } finally {
    deleting.value = false
  }
}
</script>
