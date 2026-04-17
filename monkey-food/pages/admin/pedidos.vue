<template>
  <!-- Pedidos Page -->
  <div class="px-4 pt-5">
    <!-- Filtro fecha -->
    <div class="flex gap-2 overflow-x-auto pb-1 mb-3 -mx-4 px-4 scrollbar-hide">
      <button
        v-for="filter in dateFilters"
        :key="filter.key"
        @click="dateFilter = filter.key"
        :class="['filter-btn', dateFilter === filter.key ? 'filter-btn-active' : 'filter-btn-inactive']"
      >
        {{ filter.label }}
      </button>
    </div>

    <!-- Filtro estado -->
    <div class="flex flex-wrap gap-2 mb-4">
      <button
        v-for="status in statusFilters"
        :key="status.value"
        @click="statusFilter = status.value"
        :class="['px-3 py-1 rounded-full text-xs font-medium border transition-colors',
          statusFilter === status.value ? 'bg-gray-800 text-white border-gray-800' : 'bg-white text-gray-500 border-gray-200']"
      >
        {{ status.label }}
      </button>
    </div>

    <!-- Buscador -->
    <div class="relative mb-4">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
        <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
      </svg>
      <input
        type="text"
        v-model="search"
        placeholder="Buscar por nombre..."
        class="input pl-9"
      />
    </div>

    <!-- Resumen -->
    <div v-if="filteredOrders.length > 0" class="flex justify-between items-center mb-3 text-sm text-gray-500">
      <span>{{ filteredOrders.length }} pedido{{ filteredOrders.length !== 1 ? 's' : '' }}</span>
      <span class="font-semibold text-green-700">${{ totalRevenue }}</span>
    </div>

    <!-- Lista -->
    <div v-if="filteredOrders.length === 0" class="empty-state">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2">
        <path d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
      </svg>
      <p class="font-medium">No hay pedidos con esos filtros</p>
    </div>

    <div v-else class="space-y-2">
      <div 
        v-for="order in filteredOrders" 
        :key="order.id"
        class="bg-white rounded-2xl border border-gray-200 px-4 py-3 flex items-center gap-3"
      >
        <div class="flex-1 min-w-0">
          <p class="font-semibold text-gray-900 truncate">{{ order.customer_name }}</p>
          <p class="text-xs text-gray-400">
            {{ formatDateTime(order.created_at) }}
            <span v-if="order.items?.length" class="ml-2 text-green-600 font-medium">{{ order.items.length }} bowls</span>
          </p>
        </div>
        <span :class="['status-badge', statusClass(order.status)]">
          {{ statusLabel(order.status) }}
        </span>
        <button
          @click="selectedOrder = order"
          class="shrink-0 text-xs font-semibold text-green-600 bg-green-50 rounded-xl px-3 py-1.5"
        >
          Ver
        </button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="selectedOrder" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" @click.self="selectedOrder = null">
      <div class="bg-white rounded-2xl w-full max-w-md p-4 max-h-[80vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-4">
          <h3 class="font-bold text-lg">Detalle del Pedido</h3>
          <button @click="selectedOrder = null" class="text-gray-400">✕</button>
        </div>
        
        <div class="space-y-3">
          <div class="flex justify-between">
            <span class="text-gray-500">Cliente:</span>
            <span class="font-medium">{{ selectedOrder.customer_name }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">WhatsApp:</span>
            <span class="font-medium">{{ selectedOrder.customer_phone }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">Dirección:</span>
            <span class="font-medium">{{ selectedOrder.customer_address }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">Estado:</span>
            <span :class="['status-badge', statusClass(selectedOrder.status)]">
              {{ statusLabel(selectedOrder.status) }}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">Total:</span>
            <span class="font-bold text-green-600">${{ selectedOrder.total }}</span>
          </div>
          <div v-if="selectedOrder.notes" class="flex justify-between">
            <span class="text-gray-500">Notas:</span>
            <span class="font-medium">{{ selectedOrder.notes }}</span>
          </div>
        </div>

        <div class="flex gap-2 mt-4">
          <button 
            v-if="selectedOrder.status === 'pending'"
            @click="updateStatus(selectedOrder.id, 'confirmed')"
            class="flex-1 bg-yellow-500 text-white py-2 rounded-xl font-medium"
          >
            Marcar Pendiente
          </button>
          <button 
            v-if="selectedOrder.status === 'confirmed'"
            @click="updateStatus(selectedOrder.id, 'preparing')"
            class="flex-1 bg-blue-500 text-white py-2 rounded-xl font-medium"
          >
            Marcar Entregado
          </button>
          <button 
            v-if="selectedOrder.status === 'preparing'"
            @click="updateStatus(selectedOrder.id, 'delivered')"
            class="flex-1 bg-green-500 text-white py-2 rounded-xl font-medium"
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
const dateFilter = ref('hoy')
const statusFilter = ref('todos')
const search = ref('')
const selectedOrder = ref<Pedido | null>(null)

const dateFilters = [
  { key: 'hoy', label: 'Hoy' },
  { key: 'ayer', label: 'Ayer' },
  { key: 'semana', label: 'Semana' }
]

const statusFilters = [
  { value: 'todos', label: 'Todos' },
  { value: 'pending', label: 'Pendiente' },
  { value: 'confirmed', label: 'Confirmado' },
  { value: 'preparing', label: 'Entregado' },
  { value: 'delivered', label: 'Cobrado' }
]

const filteredOrders = computed(() => {
  let result = [...menuStore.pedidos]
  
  // Filtro por fecha
  const now = new Date()
  if (dateFilter.value === 'hoy') {
    const hoy = now.toISOString().split('T')[0]
    result = result.filter(o => o.created_at.startsWith(hoy))
  } else if (dateFilter.value === 'ayer') {
    const ayer = new Date(now.getTime() - 86400000).toISOString().split('T')[0]
    result = result.filter(o => o.created_at.startsWith(ayer))
  } else if (dateFilter.value === 'semana') {
    const semanaAtras = new Date(now.getTime() - 7 * 86400000).toISOString()
    result = result.filter(o => o.created_at >= semanaAtras)
  }
  
  // Filtro por estado
  if (statusFilter.value !== 'todos') {
    result = result.filter(o => o.status === statusFilter.value)
  }
  
  // Buscador
  if (search.value.trim()) {
    result = result.filter(o => o.customer_name?.toLowerCase().includes(search.value.toLowerCase()))
  }
  
  return result.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
})

const totalRevenue = computed(() => filteredOrders.value.filter(o => o.status !== 'cancelled').reduce((sum, o) => sum + Number(o.total), 0))

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
    confirmed: 'status-confirmed',
    preparing: 'status-preparing',
    delivered: 'status-delivered',
    cancelled: 'status-cancelled'
  }
  return map[status] || 'bg-gray-100'
}

const updateStatus = async (orderId: string, newStatus: Pedido['status']) => {
  await menuStore.actualizarEstado(orderId, newStatus)
  if (selectedOrder.value) {
    selectedOrder.value.status = newStatus
  }
}

onMounted(async () => {
  await menuStore.initialize()
})
</script>