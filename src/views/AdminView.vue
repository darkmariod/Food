<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const pedidos = ref([])
const productos = ref([])
const eventos = ref([])
const degustaciones = ref([])
const stats = ref({})
const tab = ref('pedidos')
const cargando = ref(true)

// Supabase direct
const SB_URL = 'https://almfsjxrajxmyfygrtdj.supabase.co'
const SB_KEY = 'sb_publishable_5wCGWfuWq5Y8JOMM8sVT5w_f_4YvogO'
const SB_HEADERS = { 'apikey': SB_KEY, 'Authorization': `Bearer ${SB_KEY}`, 'Content-Type': 'application/json', 'Prefer': 'return=representation' }

// WhatsApp del bartender
const whatsapp = ref(localStorage.getItem('fitmeals_whatsapp') || '5491112345678')

const password = ref('fitmeals') // Password por defecto
const showLogin = ref(true)

onMounted(() => {
  const saved = localStorage.getItem('fitmeals_pass')
  if (saved) {
    password.value = saved
    loadData()
  } else {
    showLogin.value = true
  }
})

async function login() {
  if (!password.value) return
  if (password.value === 'fitmeals') {
    localStorage.setItem('fitmeals_pass', password.value)
    showLogin.value = false
    loadData()
  } else {
    alert('Contraseña incorrecta')
  }
}

async function loadData() {
  cargando.value = true
  try {
    const [rPedidos, rProductos, rEventos, rDegustaciones] = await Promise.all([
      fetch(`${SB_URL}/rest/v1/pedidos?order=created_at.desc&limit=50`, { headers: SB_HEADERS }),
      fetch(`${SB_URL}/rest/v1/productos?order=nombre.asc`, { headers: SB_HEADERS }),
      fetch(`${SB_URL}/rest/v1/eventos?order=fecha.desc`, { headers: SB_HEADERS }),
      fetch(`${SB_URL}/rest/v1/degustaciones?order=fecha.desc`, { headers: SB_HEADERS })
    ])
    pedidos.value = await rPedidos.json()
    productos.value = await rProductos.json()
    eventos.value = await rEventos.json()
    degustaciones.value = await rDegustaciones.json()
    
    // Calcular stats local
    const hoy = new Date().toISOString().split('T')[0]
    const pedidosHoy = pedidos.value.filter(p => p.created_at && p.created_at.startsWith(hoy))
    stats.value = {
      pendientes: pedidos.filter(p => p.estado === 'pendiente').length,
      en_proceso: pedidos.filter(p => p.estado === 'en_proceso').length,
      entregados: pedidos.filter(p => p.estado === 'entregado').length,
      total_hoy: pedidosHoy.reduce((sum, p) => sum + (parseFloat(p.total) || 0), 0)
    }
  } catch (e) {
    console.error(e)
  } finally {
    cargando.value = false
  }
}

function logout() {
  localStorage.removeItem('fitmeals_pass')
  password.value = ''
  showLogin.value = true
}

async function cambiarEstado(pedidoId, nuevoEstado) {
  await fetch(`${SB_URL}/rest/v1/pedidos?id=eq.${pedidoId}`, {
    method: 'PATCH',
    headers: { ...SB_HEADERS, 'Content-Type': 'application/json' },
    body: JSON.stringify({ estado: nuevoEstado })
  })
  loadData()
}

function getEstadoColor(estado) {
  const colores = {
    pendiente: 'bg-yellow-100 text-yellow-800',
    en_proceso: 'bg-emerald-100 text-emerald-800',
    entregado: 'bg-emerald-500 text-white',
    cancelado: 'bg-gray-300 text-gray-700'
  }
  return colores[estado] || 'bg-gray-100'
}

function formatearFecha(fecha) {
  if (!fecha) return ''
  return new Date(fecha).toLocaleString('es-AR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })
}

function getItems(items) {
  if (!items) return []
  if (Array.isArray(items)) return items
  try { 
    const parsed = JSON.parse(items)
    // Handle case where it's already a stringified JSON inside
    if (typeof parsed === 'string') return JSON.parse(parsed)
    return parsed
  } catch { return [] }
}

const nuevoProducto = ref({ nombre: '', precio: 0, descripcion: '', categoria: 'animal' })

async function agregarProducto() {
  if (!nuevoProducto.value.nombre || nuevoProducto.value.precio <= 0) {
    alert('Completá nombre y precio')
    return
  }
  await fetch(`${SB_URL}/rest/v1/productos`, {
    method: 'POST',
    headers: { ...SB_HEADERS, 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...nuevoProducto.value, activo: true })
  })
  nuevoProducto.value = { nombre: '', precio: 0, descripcion: '', categoria: 'animal' }
  loadData()
}

async function eliminarProducto(id) {
  if (!confirm('¿Eliminar producto?')) return
  await fetch(`${SB_URL}/rest/v1/productos?id=eq.${id}`, {
    method: 'DELETE',
    headers: SB_HEADERS
  })
  loadData()
}

// Eventos
const nuevoEvento = ref({ titulo: '', descripcion: '', precio: 0, fecha: '', hora: '', lugar: '', contacto: '' })

async function agregarEvento() {
  if (!nuevoEvento.value.titulo || !nuevoEvento.value.fecha) {
    alert('Completá título y fecha')
    return
  }
  await fetch(`${SB_URL}/rest/v1/eventos`, {
    method: 'POST',
    headers: { ...SB_HEADERS, 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...nuevoEvento.value, activo: true })
  })
  nuevoEvento.value = { titulo: '', descripcion: '', precio: 0, fecha: '', hora: '', lugar: '', contacto: '' }
  loadData()
}

async function eliminarEvento(id) {
  if (!confirm('¿Eliminar evento?')) return
  await fetch(`${SB_URL}/rest/v1/eventos?id=eq.${id}`, {
    method: 'DELETE',
    headers: SB_HEADERS
  })
  loadData()
}

// Degustaciones
const nuevaDegustacion = ref({ titulo: '', descripcion: '', precio: 0, fecha: '', hora: '', lugar: '', contacto: '' })

async function agregarDegustacion() {
  if (!nuevaDegustacion.value.titulo || !nuevaDegustacion.value.fecha) {
    alert('Completá título y fecha')
    return
  }
  await fetch(`${SB_URL}/rest/v1/degustaciones`, {
    method: 'POST',
    headers: { ...SB_HEADERS, 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...nuevaDegustacion.value, activo: true })
  })
  nuevaDegustacion.value = { titulo: '', descripcion: '', precio: 0, fecha: '', hora: '', lugar: '', contacto: '' }
  loadData()
}

async function eliminarDegustacion(id) {
  if (!confirm('¿Eliminar degustación?')) return
  await fetch(`${SB_URL}/rest/v1/degustaciones?id=eq.${id}`, {
    method: 'DELETE',
    headers: SB_HEADERS
  })
  loadData()
}

// === CREAR PEDIDO DE PRUEBA ===
async function crearPedidoPrueba() {
  if (productos.value.length === 0) {
    alert('No hay productos')
    return
  }
  const productosRandom = productos.value[Math.floor(Math.random() * productos.value.length)]
  const pedidoPrueba = {
    cliente_nombre: 'Cliente Prueba',
    cliente_telefono: '+5491111111111',
    items: [productosRandom.nombre],  // Simple array
    total: productosRandom.precio,
    estado: 'pendiente'
  }
  
  await fetch(`${SB_URL}/rest/v1/pedidos`, {
    method: 'POST',
    headers: { ...SB_HEADERS, 'Content-Type': 'application/json' },
    body: JSON.stringify(pedidoPrueba)
  })
  
  alert('✅ Pedido de prueba creado!')
  loadData()
}
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Login -->
    <div v-if="showLogin" class="min-h-screen bg-emerald-600 flex items-center justify-center p-4">
      <div class="bg-white rounded-xl p-8 w-full max-w-sm">
        <h1 class="text-2xl font-bold text-emerald-600 text-center mb-4">FitMeals Admin</h1>
        <input v-model="password" type="password" placeholder="Contraseña" 
          class="w-full p-3 border rounded-lg mb-4" @keyup.enter="login">
        <button @click="login" class="w-full bg-emerald-500 text-white py-3 rounded-lg font-medium">
          Entrar
        </button>
      </div>
    </div>

    <!-- Admin -->
    <div v-else>
      <header class="bg-emerald-600 text-white py-4 px-4 flex justify-between items-center">
        <router-link to="/" class="flex items-center gap-2">
          <h1 class="text-lg font-bold">FitMeals</h1>
          <span class="text-xs bg-emerald-700 px-2 py-0.5 rounded">Admin</span>
        </router-link>
        <button @click="logout" class="text-sm bg-emerald-700 px-3 py-1.5 rounded">Salir</button>
      </header>

      <!-- Botón crear pedido prueba -->
      <div class="p-4 bg-yellow-100 border-b border-yellow-300">
        <button @click="crearPedidoPrueba" class="w-full bg-yellow-500 text-yellow-900 py-2 rounded-lg font-medium hover:bg-yellow-400">
          🧪 Crear Pedido de Prueba
        </button>
      </div>

      <div class="flex bg-white border-b">
        <button @click="tab = 'pedidos'" :class="['flex-1 py-3 text-center font-medium', tab === 'pedidos' ? 'text-emerald-600 border-b-2 border-emerald-600' : 'text-gray-500']">Pedidos</button>
        <button @click="tab = 'menu'" :class="['flex-1 py-3 text-center font-medium', tab === 'menu' ? 'text-emerald-600 border-b-2 border-emerald-600' : 'text-gray-500']">Menú</button>
        <button @click="tab = 'eventos'" :class="['flex-1 py-3 text-center font-medium', tab === 'eventos' ? 'text-emerald-600 border-b-2 border-emerald-600' : 'text-gray-500']">Eventos</button>
        <button @click="tab = 'stats'" :class="['flex-1 py-3 text-center font-medium', tab === 'stats' ? 'text-emerald-600 border-b-2 border-emerald-600' : 'text-gray-500']">Caja</button>
      </div>

      <div class="grid grid-cols-4 gap-2 p-4 bg-emerald-500 text-white">
        <div class="text-center"><div class="text-2xl font-bold">{{ stats.pendientes || 0 }}</div><div class="text-xs opacity-80">Pendientes</div></div>
        <div class="text-center"><div class="text-2xl font-bold">{{ stats.en_proceso || 0 }}</div><div class="text-xs opacity-80">Proceso</div></div>
        <div class="text-center"><div class="text-2xl font-bold">{{ stats.entregados || 0 }}</div><div class="text-xs opacity-80">Entregados</div></div>
        <div class="text-center"><div class="text-2xl font-bold">${{ stats.ingresos || 0 }}</div><div class="text-xs opacity-80">Ingresos</div></div>
      </div>

      <div v-if="cargando" class="p-8 text-center text-gray-500">Cargando...</div>

      <div v-if="tab === 'pedidos' && !cargando" class="p-4">
        <div v-for="p in pedidos" :key="p.id" class="bg-white rounded-lg p-4 shadow-sm border mb-3">
          <div class="flex justify-between items-start mb-2">
            <div><div class="font-semibold">{{ p.cliente_nombre }}</div><div class="text-sm text-gray-500">{{ p.cliente_telefono }}</div></div>
            <span :class="['px-3 py-1 rounded-full text-sm font-medium', getEstadoColor(p.estado)]">{{ p.estado }}</span>
          </div>
          <!-- Items parsed -->
          <div class="text-sm text-gray-600 mb-2">
            <span v-for="item in getItems(p.items)" :key="item" class="mr-2">• {{ item.nombre || item }}</span>
          </div>
          <div class="flex justify-between items-center">
            <div class="text-lg font-bold text-emerald-600">${{ p.total }}</div>
            <div class="text-xs text-gray-400">{{ formatearFecha(p.created_at) }}</div>
          </div>
          <!-- Botones Estado -->
          <div class="flex gap-2 mt-3">
            <button v-if="p.estado === 'pendiente'" @click="cambiarEstado(p.id, 'en_proceso')" class="flex-1 bg-yellow-500 text-white py-2 rounded">⏳ En Proceso</button>
            <button v-if="p.estado === 'en_proceso'" @click="cambiarEstado(p.id, 'entregado')" class="flex-1 bg-emerald-500 text-white py-2 rounded">✅ Listo para Entregar</button>
            <button v-if="p.estado === 'entregado'" class="flex-1 bg-emerald-600 text-white py-2 rounded" disabled>✅ Entregado</button>
            <button v-if="p.estado !== 'entregado'" @click="cambiarEstado(p.id, 'cancelado')" class="flex-1 bg-gray-400 text-white py-2 rounded">Cancelar</button>
          </div>
          <!-- Botón WhatsApp cuando listo -->
          <a v-if="p.estado === 'en_proceso' || p.estado === 'entregado'" 
             :href="`https://wa.me/${whatsapp}?text=FitMeals:%20Pedido%20de%20${encodeURIComponent(p.cliente_nombre)}%20listo!%20📦`"
             class="block w-full bg-green-500 text-white text-center py-2 rounded mt-2 font-medium">
            📱 Contactar Cliente por WhatsApp
          </a>
        </div>
        <div v-if="pedidos.length === 0" class="text-center text-gray-500 py-8">No hay pedidos</div>
      </div>

      <div v-if="tab === 'menu' && !cargando" class="p-4">
        <div class="bg-white rounded-lg p-4 shadow-sm border mb-4">
          <input v-model="nuevoProducto.nombre" placeholder="Nombre" class="w-full mb-2 p-2 border rounded">
          <input v-model.number="nuevoProducto.precio" type="number" step="0.01" placeholder="Precio" class="w-full mb-2 p-2 border rounded">
          <input v-model="nuevoProducto.descripcion" placeholder="Descripción" class="w-full mb-2 p-2 border rounded">
          <select v-model="nuevoProducto.categoria" class="w-full mb-2 p-2 border rounded">
            <option value="animal">🥩 Animal</option>
            <option value="vegetal">🌱 Vegetal</option>
          </select>
          <button @click="agregarProducto" class="w-full bg-emerald-500 text-white py-2 rounded">Agregar</button>
        </div>
        <div v-for="p in productos" :key="p.id" class="bg-white rounded-lg p-4 shadow-sm border mb-2 flex justify-between items-center">
          <div><div class="font-medium">{{ p.nombre }}</div><div class="text-sm text-gray-500">${{ p.precio }} - {{ p.categoria }}</div></div>
          <button @click="eliminarProducto(p.id)" class="text-red-500 text-sm">Eliminar</button>
        </div>
      </div>

      <!-- Eventos y Degustaciones -->
      <div v-if="tab === 'eventos' && !cargando" class="p-4">
        <div class="mb-4">
          <h3 class="font-bold text-emerald-700 mb-2">📅 Nuevo Evento</h3>
          <div class="bg-white rounded-lg p-3 shadow-sm border space-y-2">
            <input v-model="nuevoEvento.titulo" placeholder="Título del evento" class="w-full p-2 border rounded">
            <input v-model="nuevoEvento.descripcion" placeholder="Descripción" class="w-full p-2 border rounded">
            <input v-model.number="nuevoEvento.precio" type="number" step="0.01" placeholder="Precio (0 = gratis)" class="w-full p-2 border rounded">
            <input v-model="nuevoEvento.fecha" type="date" class="w-full p-2 border rounded">
            <input v-model="nuevoEvento.hora" placeholder="Hora (ej: 18:00)" class="w-full p-2 border rounded">
            <input v-model="nuevoEvento.lugar" placeholder="Lugar" class="w-full p-2 border rounded">
            <input v-model="nuevoEvento.contacto" placeholder="Contacto WhatsApp" class="w-full p-2 border rounded">
            <button @click="agregarEvento" class="w-full bg-emerald-600 text-white py-2 rounded">Agregar Evento</button>
          </div>
        </div>

        <div v-if="eventos.length > 0" class="mb-4">
          <h3 class="font-bold text-emerald-700 mb-2">📅 Eventos</h3>
          <div v-for="e in eventos" :key="e.id" class="bg-white rounded-lg p-3 shadow-sm border mb-2">
            <div class="flex justify-between items-start">
              <div>
                <div class="font-medium">{{ e.titulo }}</div>
                <div class="text-sm text-gray-500">{{ e.fecha }} {{ e.hora }} - {{ e.lugar }}</div>
              </div>
              <button @click="eliminarEvento(e.id)" class="text-red-500 text-sm">X</button>
            </div>
          </div>
        </div>

        <div class="mb-4">
          <h3 class="font-bold text-emerald-700 mb-2">🍽️ Nueva Degustación</h3>
          <div class="bg-white rounded-lg p-3 shadow-sm border space-y-2">
            <input v-model="nuevaDegustacion.titulo" placeholder="Título de la degustación" class="w-full p-2 border rounded">
            <input v-model="nuevaDegustacion.descripcion" placeholder="Descripción" class="w-full p-2 border rounded">
            <input v-model.number="nuevaDegustacion.precio" type="number" step="0.01" placeholder="Precio (0 = gratis)" class="w-full p-2 border rounded">
            <input v-model="nuevaDegustacion.fecha" type="date" class="w-full p-2 border rounded">
            <input v-model="nuevaDegustacion.hora" placeholder="Hora (ej: 12:00)" class="w-full p-2 border rounded">
            <input v-model="nuevaDegustacion.lugar" placeholder="Lugar" class="w-full p-2 border rounded">
            <input v-model="nuevaDegustacion.contacto" placeholder="Contacto WhatsApp" class="w-full p-2 border rounded">
            <button @click="agregarDegustacion" class="w-full bg-emerald-500 text-white py-2 rounded">Agregar Degustación</button>
          </div>
        </div>

        <div v-if="degustaciones.length > 0">
          <h3 class="font-bold text-emerald-700 mb-2">🍽️ Degustaciones</h3>
          <div v-for="d in degustaciones" :key="d.id" class="bg-white rounded-lg p-3 shadow-sm border mb-2">
            <div class="flex justify-between items-start">
              <div>
                <div class="font-medium">{{ d.titulo }}</div>
                <div class="text-sm text-gray-500">{{ d.fecha }} {{ d.hora }} - {{ d.lugar }}</div>
              </div>
              <button @click="eliminarDegustacion(d.id)" class="text-red-500 text-sm">X</button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="tab === 'stats' && !cargando" class="p-4">
        <div class="grid grid-cols-2 gap-4">
          <div class="bg-white rounded-lg p-6 shadow-sm border text-center">
            <div class="text-3xl font-bold text-emerald-600">{{ stats.total_pedidos || 0 }}</div>
            <div class="text-gray-500">Pedidos Hoy</div>
          </div>
          <div class="bg-white rounded-lg p-6 shadow-sm border text-center">
            <div class="text-3xl font-bold text-emerald-600">${{ stats.ingresos || 0 }}</div>
            <div class="text-gray-500">Ingresos Hoy</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>