import { createRouter, createWebHistory } from 'vue-router'
import { authStore } from '@/stores/auth'
import ContractList from '@/views/ContractList.vue'
import ContractDetail from '@/views/ContractDetail.vue'
import ContractEdit from '@/views/ContractEdit.vue'
import ContractCreate from '@/views/ContractCreate.vue'
import Game from '@/views/Game.vue'
import Login from '@/views/Login.vue'

const routes = [
  {
    path: '/',
    redirect: '/back-office',
  },
  {
    path: '/login',
    name: 'login',
    component: Login,
    meta: { requiresAuth: false }
  },
  {
    path: '/back-office',
    name: 'contract-list',
    component: ContractList,
  },
  {
    path: '/back-office/contract/:id',
    name: 'contract-detail',
    component: ContractDetail,
    props: true,
    meta: { requiresAuth: true }
  },
  {
    path: '/back-office/contract/:id/edit',
    name: 'contract-edit',
    component: ContractEdit,
    props: true,
    meta: { requiresAuth: true }
  },
  {
    path: '/back-office/create',
    name: 'contract-create',
    component: ContractCreate,
    meta: { requiresAuth: true }
  },
  {
    path: '/game',
    name: 'game',
    component: Game,
    meta: { requiresAuth: false }
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

router.beforeEach((to, from, next) => {
  const requiresAuth = to.meta.requiresAuth !== false
  const isAuthenticated = authStore.isAuthenticated
  
  if (requiresAuth && !isAuthenticated) {
    next({
      path: '/login',
      query: { redirect: to.fullPath }
    })
  } else if (to.path === '/login' && isAuthenticated) {
    next('/back-office')
  } else {
    next()
  }
})

export default router
