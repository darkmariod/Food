<script setup>
import { ref, onMounted, computed } from 'vue'

const productos = ref([])
const eventos = ref([])
const degustaciones = ref([])
const whatsapp = localStorage.getItem('fitmeals_whatsapp') || '5491112345678'

const SB_URL = 'https://almfsjxrajxmyfygrtdj.supabase.co'
const SB_KEY = 'sb_publishable_5wCGWfuWq5Y8JOMM8sVT5w_f_4YvogO'
const SB_HEADERS = { 'apikey': SB_KEY, 'Authorization': `Bearer ${SB_KEY}`, 'Content-Type': 'application/json' }

const cargando = ref(true)
const error = ref(null)
const pedidoDirecto = ref({ nombre: '', telefono: '' })
const mostrarModal = ref(false)
const productoSeleccionado = ref(null)

onMounted(async () => {
  try {
    const [resProd, resEv, resDeg] = await Promise.all([
      fetch(`${SB_URL}/rest/v1/productos?activo=eq.true&order=nombre.asc`, { headers: SB_HEADERS }),
      fetch(`${SB_URL}/rest/v1/eventos?activo=eq.true&order=fecha.asc`, { headers: SB_HEADERS }),
      fetch(`${SB_URL}/rest/v1/degustaciones?activo=eq.true&order=fecha.asc`, { headers: SB_HEADERS })
    ])
    if (!resProd.ok) throw new Error('Error del servidor')
    productos.value = await resProd.json()
    eventos.value = await resEv.json()
    degustaciones.value = await resDeg.json()
  } catch (e) {
    error.value = e.message
  } finally {
    cargando.value = false
  }
})

const animal = computed(() => productos.value.filter(p => p.categoria === 'animal'))
const vegetal = computed(() => productos.value.filter(p => p.categoria === 'vegetal'))

function getWhatappMensaje(item, tipo) {
  const msg = `Hola! Me interesa el ${tipo}: ${encodeURIComponent(item.titulo)}`
  return `https://wa.me/${whatsapp}?text=${msg}`
}

async function crearPedido() {
  if (!pedidoDirecto.value.nombre || !pedidoDirecto.value.telefono) {
    alert('Completá nombre y teléfono')
    return
  }
  const pedido = {
    cliente_nombre: pedidoDirecto.value.nombre,
    cliente_telefono: pedidoDirecto.value.telefono,
    items: [productoSeleccionado.value.nombre],
    total: productoSeleccionado.value.precio,
    estado: 'pendiente'
  }
  const res = await fetch(`${SB_URL}/rest/v1/pedidos`, {
    method: 'POST',
    headers: { ...SB_HEADERS, 'Prefer': 'return=representation' },
    body: JSON.stringify(pedido)
  })
  if (res.ok) {
    alert('✅ Pedido creado! Te contactaremos pronto.')
    mostrarModal.value = false
    pedidoDirecto.value = { nombre: '', telefono: '' }
    productoSeleccionado.value = null
  } else {
    alert('Error al crear pedido')
  }
}

function abrirModal(producto) {
  productoSeleccionado.value = producto
  mostrarModal.value = true
}
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-gradient-to-r from-emerald-600 to-emerald-500 text-white py-4 px-5 flex justify-between items-center shadow-lg">
      <div>
        <h1 class="text-xl font-bold">FitMeals</h1>
        <p class="text-emerald-100 text-xs opacity-90">Comida fitness</p>
      </div>
      <router-link to="/admin" class="bg-white/20 backdrop-blur-sm px-4 py-2 rounded-lg text-sm font-medium">
        Admin
      </router-link>
    </header>

    <!-- Banner -->
    <div class="bg-gradient-to-r from-emerald-500 to-emerald-400 text-white py-6 px-5 text-center">
      <h2 class="text-2xl font-bold mb-1">🥗 Almuerzos Fit</h2>
      <p class="text-emerald-50 text-sm">Alta proteína • Bajos grasa • Caseros</p>
    </div>

    <!-- Main Content -->
    <main class="px-4 py-4 -mt-3">
      <!-- Loading -->
      <div v-if="cargando" class="flex flex-col items-center justify-center py-16">
        <div class="w-12 h-12 border-4 border-emerald-200 border-t-emerald-500 rounded-full animate-spin"></div>
        <p class="text-gray-500 mt-4">Cargando menú...</p>
      </div>

      <!-- Error -->
      <div v-if="error" class="flex flex-col items-center justify-center py-16">
        <p class="text-red-500 font-medium">{{ error }}</p>
      </div>

      <!-- Menú Animal -->
      <div v-if="!cargando && animal.length > 0" class="mb-6">
        <h3 class="text-lg font-bold text-gray-800 mb-3 flex items-center gap-2">
          <span>🥩</span> Proteína Animal
        </h3>
        <div class="grid grid-cols-2 gap-3">
          <div v-for="p in animal" :key="p.id" 
            class="bg-white rounded-xl shadow-md border-t-4 border-emerald-500 overflow-hidden">
            <div class="p-3">
              <div class="flex justify-between items-start mb-2">
                <h4 class="font-semibold text-gray-800 text-sm leading-tight">{{ p.nombre }}</h4>
                <span class="bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full text-sm font-bold">${{ p.precio }}</span>
              </div>
              <p class="text-xs text-gray-500 mb-3">{{ p.descripcion }}</p>
              <a :href="`https://wa.me/${whatsapp}?text=Hola! Quiero pedir: ${encodeURIComponent(p.nombre)}`"
                 class="flex items-center justify-center gap-1 w-full bg-emerald-500 text-white py-2.5 rounded-lg font-medium text-sm hover:bg-emerald-600 transition">
                📱 Pedir
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- Menú Vegetal -->
      <div v-if="!cargando && vegetal.length > 0" class="mb-6">
        <h3 class="text-lg font-bold text-gray-800 mb-3 flex items-center gap-2">
          <span>🌱</span> Proteína Vegetal
        </h3>
        <div class="grid grid-cols-2 gap-3">
          <div v-for="p in vegetal" :key="p.id" 
            class="bg-white rounded-xl shadow-md border-t-4 border-emerald-400 overflow-hidden">
            <div class="p-3">
              <div class="flex justify-between items-start mb-2">
                <h4 class="font-semibold text-gray-800 text-sm leading-tight">{{ p.nombre }}</h4>
                <span class="bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full text-sm font-bold">${{ p.precio }}</span>
              </div>
              <p class="text-xs text-gray-500 mb-3">{{ p.descripcion }}</p>
              <a :href="`https://wa.me/${whatsapp}?text=Hola! Quiero pedir: ${encodeURIComponent(p.nombre)}`"
                 class="flex items-center justify-center gap-1 w-full bg-emerald-500 text-white py-2.5 rounded-lg font-medium text-sm hover:bg-emerald-600 transition">
                📱 Pedir
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- Solo por Reservas -->
      <div v-if="!cargando && (eventos.length > 0 || degustaciones.length > 0)" class="mb-6">
        <div class="bg-gradient-to-r from-amber-500 to-orange-500 rounded-2xl p-5 shadow-lg">
          <h3 class="text-white text-center font-bold text-lg mb-1">🎀 Solo por Reservas</h3>
          <p class="text-amber-100 text-center text-sm mb-4">Eventos y degustaciones especiales</p>
          
          <div class="space-y-3">
            <div v-for="e in eventos" :key="e.id" class="bg-white/20 rounded-xl p-3">
              <div class="flex justify-between items-center mb-1">
                <span class="text-white font-semibold">{{ e.titulo }}</span>
                <span class="bg-white text-amber-600 px-2 py-0.5 rounded-full text-sm font-bold">${{ e.precio }}</span>
              </div>
              <p class="text-amber-100 text-xs mb-2">{{ e.fecha }} • {{ e.hora }}</p>
              <a :href="getWhatappMensaje(e, 'reserva')"
                 class="block w-full bg-white text-amber-600 text-center py-2 rounded-lg font-bold text-sm">
              📱 Reservar
              </a>
            </div>
            <div v-for="d in degustaciones" :key="d.id" class="bg-white/20 rounded-xl p-3">
              <div class="flex justify-between items-center mb-1">
                <span class="text-white font-semibold">{{ d.titulo }}</span>
                <span class="bg-white text-amber-600 px-2 py-0.5 rounded-full text-sm font-bold">${{ d.precio }}</span>
              </div>
              <p class="text-amber-100 text-xs mb-2">{{ d.fecha }} • {{ d.hora }}</p>
              <a :href="getWhatappMensaje(d, 'reserva')"
                 class="block w-full bg-white text-amber-600 text-center py-2 rounded-lg font-bold text-sm">
              📱 Reservar
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-gray-200 py-4 px-4 shadow-lg">
      <div class="flex justify-around items-center">
        <a :href="`tel:+${whatsapp}`" class="flex flex-col items-center text-gray-500 hover:text-emerald-600 transition">
          <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center text-xl mb-1">📞</div>
          <span class="text-xs font-medium">Llamar</span>
        </a>
        <a :href="`https://wa.me/${whatsapp}`" class="flex flex-col items-center text-green-600 hover:text-green-700 transition">
          <div class="w-12 h-12 bg-green-50 rounded-full flex items-center justify-center text-xl mb-1">💬</div>
          <span class="text-xs font-medium">WhatsApp</span>
        </a>
        <router-link to="/admin" class="flex flex-col items-center text-emerald-600 hover:text-emerald-700 transition">
          <div class="w-12 h-12 bg-emerald-50 rounded-full flex items-center justify-center text-xl mb-1">⚙️</div>
          <span class="text-xs font-medium">Admin</span>
        </router-link>
      </div>
    </footer>

    <!-- Modal -->
    <div v-if="mostrarModal" class="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-2xl p-6 w-full max-w-sm shadow-2xl">
        <h3 class="text-xl font-bold text-emerald-700 mb-2 text-center">Pedido Directo</h3>
        <p class="text-gray-500 text-center mb-4">{{ productoSeleccionado?.nombre }} - ${{ productoSeleccionado?.precio }}</p>
        <input v-model="pedidoDirecto.nombre" placeholder="Tu nombre completo" 
          class="w-full mb-3 p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none">
        <input v-model="pedidoDirecto.telefono" placeholder="Tu teléfono" 
          class="w-full mb-4 p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none">
        <button @click="crearPedido" 
          class="w-full bg-emerald-500 text-white py-3 rounded-lg font-bold hover:bg-emerald-600 transition mb-2">
          ✅ Confirmar Pedido
        </button>
        <button @click="mostrarModal = false" 
          class="w-full bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition">
          Cancelar
        </button>
      </div>
    </div>
  </div>
</template>