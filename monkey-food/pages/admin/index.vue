<template>
  <!-- Dashboard / Caja -->
  <div class="px-4 pt-5">
    <!-- Alerta de nuevo pedido -->
    <div v-if="newOrderAlert" class="mb-4 bg-green-500 text-white rounded-2xl px-4 py-3 flex items-center gap-2 animate-pulse shadow-lg">
      <span class="font-semibold">Nuevo pedido recibido!</span>
    </div>

    <!-- Cards resumen -->
    <div class="grid grid-cols-3 gap-2 mb-4">
      <div class="bg-yellow-50 rounded-2xl p-3 text-center border border-yellow-200">
        <p class="text-2xl font-bold text-yellow-600">{{ pendientesCount }}</p>
        <p class="text-xs text-gray-600">Pendientes</p>
      </div>
      <div class="bg-blue-50 rounded-2xl p-3 text-center border border-blue-200">
        <p class="text-2xl font-bold text-blue-600">{{ entregadosCount }}</p>
        <p class="text-xs text-gray-600">Entregados</p>
      </div>
      <div class="bg-green-50 rounded-2xl p-3 text-center border border-green-200">
        <p class="text-2xl font-bold text-green-600">${{ todayRevenue }}</p>
        <p class="text-xs text-gray-600">Cobrado</p>
      </div>
    </div>

    <!-- Bowls disponibles -->
    <div class="bg-white rounded-2xl p-3 mb-4 flex justify-between items-center">
      <span class="text-sm text-gray-600">Bowls disponibles</span>
      <span class="text-lg font-bold text-green-600">{{ bowlsDisponibles }}</span>
    </div>

    <!-- Lista pedidos -->
    <div class="flex items-center justify-between mb-3">
      <h2 class="font-bold text-gray-800">Pedidos de hoy</h2>
      <span class="text-xs text-gray-400">{{ orders.length }} en total</span>
    </div>

    <div v-if="orders.length === 0" class="empty-state">
      <p class="font-medium">Todavia no hay pedidos hoy</p>
    </div>

    <div v-else class="space-y-2">
      <div 
        v-for="order in orders" 
        :key="order.id"
        class="bg-white rounded-2xl border border-gray-200 px-4 py-3"
      >
        <div class="flex justify-between items-start mb-2">
          <div class="flex-1 min-w-0">
            <p class="font-semibold text-gray-900 truncate">{{ order.customer_name || 'Sin cliente' }}</p>
            <p class="text-xs text-gray-400">
              {{ formatDateTime(order.created_at) }}
              <span class="ml-2 text-green-600 font-medium">{{ order.items?.length || 0 }} bowls</span>
            </p>
          </div>
          <span :class="['status-badge', statusClass(order.status)]">
            {{ statusLabel(order.status) }}
          </span>
        </div>

        <p class="text-sm text-gray-600 mb-2 truncate">
          {{ order.customer_address }}
        </p>
        
        <p class="text-xs text-gray-500 mb-2">
          {{ order.customer_phone }} | {{ order.customer_phone }}
        </p>

        <div class="flex justify-between items-center mb-2">
          <div class="text-sm text-gray-600">
            <span v-for="(item, idx) in order.items" :key="idx">
              {{ item.product?.nombre || 'Producto' }} x{{ item.quantity }}
              <span v-if="idx < order.items.length - 1">, </span>
            </span>
          </div>
          <span class="font-bold text-green-600 text-sm">${{ order.total }}</span>
        </div>

        <!-- Acciones de estado -->
        <div class="flex gap-2 mt-2">
          <button 
            @click="updateStatus(order.id, 'confirmed')"
            v-if="order.status === 'pending'"
            class="flex-1 bg-yellow-500 text-white py-2 rounded-xl text-xs font-medium"
          >
            Pendiente
          </button>
          <button 
            @click="updateStatus(order.id, 'preparing')"
            v-if="order.status === 'confirmed'"
            class="flex-1 bg-blue-500 text-white py-2 rounded-xl text-xs font-medium"
          >
            Entregar
          </button>
          <button 
            @click="updateStatus(order.id, 'delivered')"
            v-if="order.status === 'preparing'"
            class="flex-1 bg-green-500 text-white py-2 rounded-xl text-xs font-medium"
          >
            Cobrado
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin'
})

import { ref, computed, onMounted } from 'vue'
import { useMenuStore, type Pedido } from '~/stores/menu'

const menuStore = useMenuStore()
const newOrderAlert = ref(false)

const orders = computed(() => menuStore.pedidos)
const orderCount = computed(() => orders.value.filter(o => o.status !== 'cancelled').length)
const todayRevenue = computed(() => orders.value.filter(o => o.status === 'delivered').reduce((sum, o) => sum + Number(o.total), 0))

const pendientesCount = computed(() => orders.value.filter(o => o.status === 'pending' || o.status === 'confirmed').length)
const entregadosCount = computed(() => orders.value.filter(o => o.status === 'preparing' || o.status === 'delivered').length)

const bowlsDisponibles = computed(() => {
  if (typeof window === 'undefined') return 10
  const config = localStorage.getItem('monkey-admin-config')
  if (config) {
    return JSON.parse(config).bowlsDisponibles || 10
  }
  return 10
})

const formatDateTime = (iso: string) => {
  return new Date(iso).toLocaleString('es-EC', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })
}

const statusLabel = (status: string) => {
  const labels: Record<string, string> = {
    pending: 'Pendiente',
    confirmed: 'Confirmado',
    preparing: 'Entregado',
    delivered: 'Cobrado',
    cancelled: 'Cancelado'
  }
  return labels[status] || status
}

const statusClass = (status: string) => {
  const map: Record<string, string> = {
    pending: 'status-pending',
    confirmed: 'status-pending',
    preparing: 'status-confirmed',
    delivered: 'status-delivered',
    cancelled: 'status-cancelled'
  }
  return map[status] || 'bg-gray-100'
}

const updateStatus = async (orderId: string, newStatus: Pedido['status']) => {
  await menuStore.actualizarEstado(orderId, newStatus)
}

onMounted(async () => {
  await menuStore.initialize()
})
</script>