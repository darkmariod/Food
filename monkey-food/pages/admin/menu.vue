<template>
  <!-- Menu Page -->
  <div class="px-4 pt-5">
    <!-- Tabs -->
    <div class="flex gap-2 mb-5">
      <button
        @click="tab = 'config'"
        :class="['flex-1 py-2 rounded-xl text-sm font-medium capitalize', tab === 'config' ? 'bg-green-500 text-white shadow-sm' : 'bg-white text-gray-500 border border-gray-200']"
      >
        Config
      </button>
      <button
        @click="tab = 'productos'"
        :class="['flex-1 py-2 rounded-xl text-sm font-medium capitalize', tab === 'productos' ? 'bg-green-500 text-white shadow-sm' : 'bg-white text-gray-500 border border-gray-200']"
      >
        Productos
      </button>
    </div>

    <!-- Config Tab -->
    <div v-if="tab === 'config'" class="space-y-4">
      <div class="bg-white rounded-2xl border border-gray-200 p-4">
        <h3 class="font-semibold text-gray-800 mb-4">Configuración del día</h3>
        
        <div class="space-y-4">
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Bowls disponibles hoy</label>
            <input 
              v-model.number="bowlsDisponibles"
              type="number"
              min="0"
              max="100"
              class="input"
              @change="saveConfig"
            />
            <p class="text-xs text-gray-400 mt-1">Cantidad de bowls que se pueden pedir hoy</p>
          </div>

          <div>
            <label class="text-xs text-gray-500 mb-1 block">Hora de cierre de pedidos</label>
            <select v-model="horaCierre" class="input" @change="saveConfig">
              <option value="12PM">12:00 PM</option>
              <option value="1PM">1:00 PM</option>
              <option value="2PM">2:00 PM</option>
              <option value="3PM">3:00 PM</option>
            </select>
            <p class="text-xs text-gray-400 mt-1">Los pedidos se cierran a esta hora</p>
          </div>

          <div>
            <label class="text-xs text-gray-500 mb-1 block">WhatsApp para pedidos</label>
            <input 
              v-model="whatsappNumber"
              type="tel"
              class="input"
              @change="saveConfig"
            />
          </div>
        </div>

        <button 
          @click="resetDia"
          class="w-full mt-4 bg-gray-100 text-gray-600 py-2 rounded-xl text-sm font-medium"
        >
          Reiniciar día (nueva tanda)
        </button>
      </div>

      <!-- Stats rápidos -->
      <div class="grid grid-cols-2 gap-3">
        <div class="bg-white rounded-2xl border border-gray-200 p-4 text-center">
          <p class="text-2xl font-bold text-green-600">{{ bowlsDisponibles }}</p>
          <p class="text-xs text-gray-500">Bowls disponibles</p>
        </div>
        <div class="bg-white rounded-2xl border border-gray-200 p-4 text-center">
          <p class="text-2xl font-bold text-green-600">{{ pedidosVendidos }}</p>
          <p class="text-xs text-gray-500">Bowls vendidos</p>
        </div>
      </div>
    </div>

    <!-- Productos Tab -->
    <div v-if="tab === 'productos'" class="space-y-3">
      <div 
        v-for="bowl in menuStore.bowls" 
        :key="bowl.id"
        class="bg-white rounded-2xl border border-gray-200 p-4 flex items-center justify-between"
      >
        <div class="flex items-center gap-3">
          <span class="text-2xl">{{ bowl.emoji }}</span>
          <div>
            <p class="font-semibold text-gray-900">{{ bowl.nombre }}</p>
            <p class="text-xs text-gray-500">${{ bowl.price }}</p>
          </div>
        </div>
        <button 
          @click="toggleAvailable(bowl.id)"
          :class="['text-xs font-medium px-3 py-1.5 rounded-full', bowl.available ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500']"
        >
          {{ bowl.available ? 'Activo' : 'Inactivo' }}
        </button>
      </div>

      <p v-if="menuStore.bowls.length === 0" class="text-gray-500 text-center py-8">
        No hay productos
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin'
})

import { ref, onMounted } from 'vue'
import { useMenuStore } from '~/stores/menu'

const menuStore = useMenuStore()
const tab = ref('config')

const bowlsDisponibles = ref(10)
const horaCierre = ref('2PM')
const whatsappNumber = ref('593968464331')
const pedidosVendidos = ref(0)

const loadConfig = () => {
  if (typeof window === 'undefined') return
  
  const config = localStorage.getItem('monkey-admin-config')
  if (config) {
    const data = JSON.parse(config)
    bowlsDisponibles.value = data.bowlsDisponibles || 10
    horaCierre.value = data.horaCierre || '2PM'
    whatsappNumber.value = data.whatsappNumber || '593968464331'
  }
  
  // Calcular vendidos
  const pedidos = JSON.parse(localStorage.getItem('monkey-food-pedidos') || '[]')
  const hoy = new Date().toISOString().split('T')[0]
  const pedidosHoy = pedidos.filter((p: any) => p.created_at?.startsWith(hoy))
  pedidosVendidos.value = pedidosHoy.reduce((sum: number, p: any) => sum + (p.items?.length || 0), 0)
}

const saveConfig = () => {
  const config = {
    bowlsDisponibles: bowlsDisponibles.value,
    horaCierre: horaCierre.value,
    whatsappNumber: whatsappNumber.value
  }
  localStorage.setItem('monkey-admin-config', JSON.stringify(config))
}

const toggleAvailable = (id: string) => {
  const bowl = menuStore.bowls.find(b => b.id === id)
  if (bowl) {
    bowl.available = !bowl.available
    localStorage.setItem('monkey-food-bowls', JSON.stringify(menuStore.bowls))
  }
}

const resetDia = () => {
  bowlsDisponibles.value = 10
  saveConfig()
  alert('Dia reiniciado! Bowls disponibles: 10')
}

onMounted(async () => {
  await menuStore.initialize()
  loadConfig()
})
</script>