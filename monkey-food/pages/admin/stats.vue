<template>
  <!-- Stats Page -->
  <div class="px-4 pt-5 pb-8">
    <!-- Filtros -->
    <div class="flex gap-2 mb-3">
      <button
        v-for="p in periods"
        :key="p.key"
        @click="setPeriod(p.key)"
        :class="['flex-1 py-2 rounded-xl text-sm font-medium transition-colors', period === p.key ? 'bg-green-500 text-white shadow-sm' : 'bg-white text-gray-500 border border-gray-200']"
      >
        {{ p.label }}
      </button>
    </div>

    <!-- Fechas personalizadas -->
    <div class="flex gap-2 mb-5">
      <div class="flex-1">
        <label class="text-xs text-gray-400 mb-1 block">Desde</label>
        <input type="date" v-model="fromDate" class="input" />
      </div>
      <div class="flex-1">
        <label class="text-xs text-gray-400 mb-1 block">Hasta</label>
        <input type="date" v-model="toDate" class="input" />
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-2 gap-3 mb-6">
      <div class="bg-white rounded-2xl p-4 shadow-sm">
        <p class="text-xs text-gray-500 mb-1">Ingresos - {{ periodLabel }}</p>
        <p class="text-2xl font-bold text-green-600">${{ stats.revenue }}</p>
      </div>
      <div class="bg-white rounded-2xl p-4 shadow-sm">
        <p class="text-xs text-gray-500 mb-1">Pedidos - {{ periodLabel }}</p>
        <p class="text-2xl font-bold text-green-600">{{ stats.orderCount }}</p>
      </div>
    </div>

    <!-- Top bowls -->
    <div class="bg-white rounded-2xl border border-gray-200 p-4 mb-4">
      <h3 class="font-bold text-gray-800 mb-3">🏆 bowls más pedidos</h3>
      <div class="space-y-2">
        <div v-for="(item, idx) in topBowls" :key="idx" class="flex justify-between items-center">
          <span class="text-sm text-gray-600">{{ item.name }}</span>
          <span class="font-medium text-green-600">{{ item.quantity }}</span>
        </div>
        <p v-if="topBowls.length === 0" class="text-sm text-gray-400">Sin datos</p>
      </div>
    </div>

    <!-- Pedidos por día -->
    <div class="bg-white rounded-2xl border border-gray-200 p-4">
      <h3 class="font-bold text-gray-800 mb-3">📊 Pedidos por día</h3>
      <div class="flex items-end justify-between gap-1 h-24">
        <div v-for="(day, idx) in dayStats" :key="idx" class="flex-1 flex flex-col items-center">
          <div 
            class="w-full bg-green-500 rounded-t transition-all"
            :style="{ height: day.max ? (day.count / day.max * 100) + '%' : '0%', minHeight: day.count > 0 ? '4px' : '0' }"
          ></div>
          <span class="text-[10px] text-gray-400 mt-1">{{ day.label }}</span>
          <span class="text-xs font-medium">{{ day.count }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin'
})

import { ref, computed, onMounted, watch } from 'vue'
import { useMenuStore } from '~/stores/menu'

const menuStore = useMenuStore()

const today = new Date().toISOString().split('T')[0]
const period = ref('mes')
const fromDate = ref(new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0])
const toDate = ref(today)

const periods = [
  { key: 'hoy', label: 'Hoy' },
  { key: 'semana', label: 'Semana' },
  { key: 'mes', label: 'Mes' }
]

const periodLabel = computed(() => {
  const p = periods.find(p => p.key === period.value)
  return p?.label || 'Custom'
})

const setPeriod = (key: string) => {
  period.value = key
  const now = new Date()
  if (key === 'hoy') {
    fromDate.value = today
    toDate.value = today
  } else if (key === 'semana') {
    fromDate.value = new Date(now.getTime() - 7 * 86400000).toISOString().split('T')[0]
    toDate.value = today
  } else if (key === 'mes') {
    fromDate.value = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().split('T')[0]
    toDate.value = today
  }
}

const filteredOrders = computed(() => {
  return menuStore.pedidos.filter(o => {
    const date = o.created_at.split('T')[0]
    return date >= fromDate.value && date <= toDate.value && o.status !== 'cancelled'
  })
})

const stats = computed(() => ({
  revenue: filteredOrders.value.reduce((sum, o) => sum + Number(o.total), 0),
  orderCount: filteredOrders.value.length
}))

const topBowls = computed(() => {
  const counts: Record<string, number> = {}
  filteredOrders.value.forEach(order => {
    order.items?.forEach(item => {
      const name = item.product?.nombre || 'Producto'
      counts[name] = (counts[name] || 0) + item.quantity
    })
  })
  return Object.entries(counts)
    .map(([name, quantity]) => ({ name, quantity }))
    .sort((a, b) => b.quantity - a.quantity)
    .slice(0, 3)
})

const dayStats = computed(() => {
  const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
  const counts = [0, 0, 0, 0, 0, 0, 0]
  
  filteredOrders.value.forEach(order => {
    const day = new Date(order.created_at).getDay()
    counts[day]++
  })
  
  const max = Math.max(...counts, 1)
  return days.map((label, idx) => ({ label, count: counts[idx], max }))
})

onMounted(async () => {
  await menuStore.initialize()
})
</script>