import { createRouter, createWebHistory } from 'vue-router'
import ContractList from '@/views/ContractList.vue'
import ContractDetail from '@/views/ContractDetail.vue'
import ContractEdit from '@/views/ContractEdit.vue'
import Game from '@/views/Game.vue'

const routes = [
  {
    path: '/',
    redirect: '/back-office'
  },
  {
    path: '/back-office',
    name: 'contract-list',
    component: ContractList
  },
  {
    path: '/back-office/contract/:id',
    name: 'contract-detail',
    component: ContractDetail,
    props: true
  },
  {
    path: '/back-office/contract/:id/edit',
    name: 'contract-edit',
    component: ContractEdit,
    props: true
  },
  {
    path: '/game',
    name: 'game',
    component: Game
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router