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
      <!-- Agregar -->
      <button
        @click="abrirNuevo"
        class="w-full bg-green-500 text-white py-3 rounded-xl font-semibold shadow-sm active:scale-95 transition flex items-center justify-center gap-2"
      >
        <span class="text-lg leading-none">+</span> Agregar producto
      </button>

      <div
        v-for="bowl in menuStore.bowls"
        :key="bowl.id"
        class="bg-white rounded-2xl border border-gray-200 p-4"
      >
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3 min-w-0">
            <span class="text-2xl">{{ bowl.emoji || '🍽️' }}</span>
            <div class="min-w-0">
              <p class="font-semibold text-gray-900 truncate">{{ bowl.nombre }}</p>
              <p class="text-xs text-gray-500">${{ bowl.price }} · {{ bowl.category === 'vegetal' ? 'Vegetal' : 'Animal' }}</p>
            </div>
          </div>
          <button
            @click="toggle(bowl.id)"
            :class="['text-xs font-medium px-3 py-1.5 rounded-full shrink-0', bowl.available ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500']"
          >
            {{ bowl.available ? 'Activo' : 'Inactivo' }}
          </button>
        </div>
        <div class="flex gap-2 mt-3">
          <button
            @click="abrirEditar(bowl)"
            class="flex-1 bg-gray-100 text-gray-700 py-2 rounded-xl text-sm font-medium active:scale-95 transition"
          >
            Editar
          </button>
          <button
            @click="confirmarBorrar(bowl)"
            class="flex-1 bg-red-50 text-red-600 py-2 rounded-xl text-sm font-medium active:scale-95 transition"
          >
            Borrar
          </button>
        </div>
      </div>

      <p v-if="menuStore.bowls.length === 0" class="text-gray-500 text-center py-8">
        No hay productos. Tocá "Agregar producto" para crear el primero.
      </p>
    </div>

    <!-- Modal Agregar / Editar -->
    <div v-if="showForm" class="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50" @click.self="cerrarForm">
      <div class="bg-white w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl p-4 max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-4">
          <h3 class="font-bold text-lg">{{ editId ? 'Editar producto' : 'Nuevo producto' }}</h3>
          <button @click="cerrarForm" class="w-8 h-8 flex items-center justify-center bg-gray-100 rounded-full text-gray-600">✕</button>
        </div>

        <div v-if="formError" class="bg-red-100 text-red-700 px-3 py-2 rounded-xl text-sm mb-3">{{ formError }}</div>

        <div class="space-y-3">
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Nombre *</label>
            <input v-model="form.nombre" class="input" placeholder="Ej: Pollo Power" />
          </div>
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="text-xs text-gray-500 mb-1 block">Precio ($) *</label>
              <input v-model.number="form.price" type="number" min="0" step="0.25" class="input" placeholder="3.50" />
            </div>
            <div>
              <label class="text-xs text-gray-500 mb-1 block">Emoji</label>
              <input v-model="form.emoji" class="input" placeholder="🍗" maxlength="4" />
            </div>
          </div>
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Categoría</label>
            <select v-model="form.category" class="input">
              <option value="animal">Proteína Animal</option>
              <option value="vegetal">Proteína Vegetal</option>
            </select>
          </div>
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Proteína (texto)</label>
            <input v-model="form.protein_grams" class="input" placeholder="30-40g" />
          </div>
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Descripción</label>
            <textarea v-model="form.descripcion" rows="2" class="input" placeholder="Qué lleva el plato"></textarea>
          </div>
          <label class="flex items-center gap-2 text-sm text-gray-700">
            <input type="checkbox" v-model="form.available" class="w-4 h-4 accent-green-500" />
            Disponible en la tienda
          </label>
        </div>

        <button
          @click="guardar"
          :disabled="saving"
          class="w-full mt-5 bg-green-500 text-white py-3 rounded-xl font-bold disabled:opacity-50 active:scale-95 transition"
        >
          {{ saving ? 'Guardando...' : (editId ? 'Guardar cambios' : 'Crear producto') }}
        </button>
      </div>
    </div>

    <!-- Confirmar borrado -->
    <div v-if="borrarBowl" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" @click.self="borrarBowl = null">
      <div class="bg-white w-full max-w-sm rounded-2xl p-5">
        <h3 class="font-bold text-lg mb-1">¿Borrar "{{ borrarBowl.nombre }}"?</h3>
        <p class="text-sm text-gray-500 mb-4">Se quita del menú para siempre. Si solo querés dejar de venderlo hoy, mejor usá "Inactivo".</p>
        <div v-if="borrarError" class="bg-red-100 text-red-700 px-3 py-2 rounded-xl text-sm mb-3">{{ borrarError }}</div>
        <div class="flex gap-2">
          <button @click="borrarBowl = null" class="flex-1 bg-gray-100 text-gray-700 py-2.5 rounded-xl font-medium">Cancelar</button>
          <button @click="borrar" :disabled="saving" class="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-bold disabled:opacity-50">Borrar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin'
})

import { ref, reactive, onMounted } from 'vue'
import { useMenuStore, type Bowl, type ProductoInput } from '~/stores/menu'

const menuStore = useMenuStore()
const tab = ref('productos')

// --- Config (localStorage, igual que antes) ---
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
  pedidosVendidos.value = menuStore.configDiaria.bowls_vendidos || 0
}

const saveConfig = () => {
  localStorage.setItem('monkey-admin-config', JSON.stringify({
    bowlsDisponibles: bowlsDisponibles.value,
    horaCierre: horaCierre.value,
    whatsappNumber: whatsappNumber.value
  }))
}

const resetDia = () => {
  bowlsDisponibles.value = 10
  saveConfig()
  alert('Día reiniciado. Bowls disponibles: 10')
}

// --- CRUD productos (Supabase) ---
const showForm = ref(false)
const editId = ref<string | null>(null)
const saving = ref(false)
const formError = ref('')

const emptyForm = (): ProductoInput => ({
  nombre: '',
  descripcion: '',
  price: 3.5,
  category: 'animal',
  protein_grams: '30-40g',
  emoji: '🍽️',
  available: true
})
const form = reactive<ProductoInput>(emptyForm())

const setForm = (v: ProductoInput) => {
  form.nombre = v.nombre
  form.descripcion = v.descripcion
  form.price = v.price
  form.category = v.category
  form.protein_grams = v.protein_grams
  form.emoji = v.emoji
  form.available = v.available
}

const abrirNuevo = () => {
  editId.value = null
  formError.value = ''
  setForm(emptyForm())
  showForm.value = true
}

const abrirEditar = (bowl: Bowl) => {
  editId.value = bowl.id
  formError.value = ''
  setForm({
    nombre: bowl.nombre,
    descripcion: bowl.descripcion,
    price: bowl.price,
    category: bowl.category,
    protein_grams: bowl.protein_grams,
    emoji: bowl.emoji,
    available: bowl.available
  })
  showForm.value = true
}

const cerrarForm = () => { showForm.value = false }

const guardar = async () => {
  formError.value = ''
  if (!form.nombre.trim()) { formError.value = 'Poné un nombre'; return }
  if (form.price === null || form.price === undefined || isNaN(form.price) || form.price < 0) {
    formError.value = 'Poné un precio válido'; return
  }
  saving.value = true
  try {
    const payload: ProductoInput = { ...form }
    if (editId.value) {
      await menuStore.actualizarProducto(editId.value, payload)
    } else {
      await menuStore.crearProducto(payload)
    }
    showForm.value = false
  } catch (e: any) {
    formError.value = 'No se pudo guardar. Revisá los permisos de la base (RLS).'
  } finally {
    saving.value = false
  }
}

const toggle = async (id: string) => {
  try {
    await menuStore.toggleDisponible(id)
  } catch (e) {
    alert('No se pudo cambiar. Revisá los permisos de la base (RLS).')
  }
}

// --- Borrado ---
const borrarBowl = ref<Bowl | null>(null)
const borrarError = ref('')
const confirmarBorrar = (bowl: Bowl) => { borrarBowl.value = bowl; borrarError.value = '' }
const borrar = async () => {
  if (!borrarBowl.value) return
  saving.value = true
  borrarError.value = ''
  try {
    await menuStore.eliminarProducto(borrarBowl.value.id)
    borrarBowl.value = null
  } catch (e: any) {
    borrarError.value = 'No se pudo borrar (puede tener pedidos asociados). Marcalo como "Inactivo" en su lugar.'
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await menuStore.initialize()
  loadConfig()
})
</script>
