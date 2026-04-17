import { defineStore } from 'pinia'

export interface Bowl {
  id: string
  nombre: string
  descripcion: string
  price: number
  category: string
  protein_grams: string
  emoji: string
  available: boolean
}

export interface Pedido {
  id: string
  customer_name: string
  customer_phone: string
  customer_address: string
  status: 'pending' | 'confirmed' | 'preparing' | 'delivered' | 'cancelled'
  total: number
  notes: string
  created_at: string
  updated_at: string
}

export interface OrderItem {
  id: string
  order_id: string
  product_id: string
  quantity: number
  unit_price: number
}

export const useMenuStore = defineStore('menu', {
  state: () => ({
    bowls: [] as Bowl[],
    pedidos: [] as Pedido[],
    orderItems: [] as OrderItem[],
    carrito: [] as { product: Bowl; cantidad: number }[],
    loading: false,
    configDiaria: {
      bowls_total: 10,
      bowls_vendidos: 0
    },
    useSupabase: false
  }),

  getters: {
    bowlsAnimal: (state) => state.bowls.filter(b => b.category === 'animal' && b.available),
    bowlsVegetal: (state) => state.bowls.filter(b => b.category === 'vegetal' && b.available),
    totalCarrito: (state) => state.carrito.reduce((sum, item) => sum + (item.product.price * item.cantidad), 0),
    bowlsDisponibles: (state) => state.configDiaria.bowls_total - state.configDiaria.bowls_vendidos,
    pedidosHoy: (state) => {
      const hoy = new Date().toISOString().split('T')[0]
      return state.pedidos.filter(p => p.created_at.startsWith(hoy))
    },
    pedidosPendientes: (state) => state.pedidos.filter(p => p.status === 'pending'),
    pedidosConfirmados: (state) => state.pedidos.filter(p => p.status === 'confirmed'),
    pedidosEntregados: (state) => state.pedidos.filter(p => p.status === 'delivered'),
    pedidosCobrados: (state) => state.pedidos.filter(p => p.status === 'delivered') // Cobrado = entregado y pagado
  },

  actions: {
    // Cargar productos (bowls) desde Supabase
    async loadBowls() {
      const client = useSupabaseClient()
      const { data, error } = await client
        .from('products')
        .select('*')
        .eq('available', true)
        .order('name')

      if (error) {
        console.error('Error cargando products:', error)
        return
      }

      if (data) {
        this.bowls = data.map(p => ({
          id: p.id,
          nombre: p.name,
          descripcion: p.description || '',
          price: Number(p.price),
          category: p.category || 'animal',
          protein_grams: p.protein_grams || '30-40g',
          emoji: p.emoji || '',
          available: p.available
        }))
      }
    },

    // Cargar configuración diaria
    async loadConfig() {
      const client = useSupabaseClient()
      const hoy = new Date().toISOString().split('T')[0]
      
      const { data } = await client
        .from('config_diaria')
        .select('*')
        .eq('fecha', hoy)
        .single()

      if (data) {
        this.configDiaria = {
          bowls_total: data.bowls_total,
          bowls_vendidos: data.bowls_vendidos
        }
      }
    },

    // Cargar pedidos desde Supabase
    async loadPedidos() {
      const client = useSupabaseClient()
      const { data, error } = await client
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100)

      if (error) {
        console.error('Error cargando orders:', error)
        return
      }

      if (data) {
        this.pedidos = data.map(p => ({
          id: p.id,
          customer_name: p.customer_name,
          customer_phone: p.customer_phone,
          customer_address: p.customer_address,
          status: p.status,
          total: Number(p.total),
          notes: p.notes,
          created_at: p.created_at,
          updated_at: p.updated_at
        }))
      }
    },

    // Cargar items de un pedido
    async loadOrderItems(orderId: string) {
      const client = useSupabaseClient()
      const { data } = await client
        .from('order_items')
        .select('*')
        .eq('order_id', orderId)

      if (data) {
        this.orderItems = data
      }
    },

    // Crear pedido en Supabase (estructura: orders + order_items)
    async crearPedidoSupabase(cliente: string, teléfono: string, dirección: string, notas: string) {
      const client = useSupabaseClient()
      
      if (this.carrito.length === 0) return null

      // 1. Crear pedido en tabla orders
      const { data: pedido, error } = await client
        .from('orders')
        .insert({
          customer_name: cliente,
          customer_phone: teléfono,
          customer_address: dirección,
          status: 'pending',
          total: this.totalCarrito,
          notes: notas
        })
        .select()
        .single()

      if (error) {
        console.error('Error creando pedido:', error)
        return null
      }

      // 2. Crear items en tabla order_items
      const orderItems = this.carrito.map(item => ({
        order_id: pedido.id,
        product_id: item.product.id,
        quantity: item.cantidad,
        unit_price: item.product.price
      }))

      const { error: itemsError } = await client
        .from('order_items')
        .insert(orderItems)

      if (itemsError) {
        console.error('Error creando order_items:', itemsError)
      }

      // 3. Decrementar bowls disponibles
      await this.decrementarBowls()

      // 4. Limpiar carrito
      this.vaciarCarrito()
      
      return pedido
    },

    // Decrementar bowls disponibles
    async decrementarBowls() {
      const client = useSupabaseClient()
      const hoy = new Date().toISOString().split('T')[0]

      // Obtener config actual
      const { data: config } = await client
        .from('config_diaria')
        .select('*')
        .eq('fecha', hoy)
        .single()

      if (config) {
        // Actualizar
        await client
          .from('config_diaria')
          .update({ bowls_vendidos: config.bowls_vendidos + 1 })
          .eq('id', config.id)
      } else {
        // Crear nuevo registro
        await client
          .from('config_diaria')
          .insert({
            bowls_total: 10,
            bowls_vendidos: 1,
            fecha: hoy
          })
      }

      // Actualizar estado local
      this.configDiaria.bowls_vendidos++
    },

    // Actualizar estado del pedido (mapeo: pending→pendiente, confirmed→confirmado, etc.)
    async actualizarEstado(pedidoId: string, estado: Pedido['status']) {
      const client = useSupabaseClient()
      
      const { error } = await client
        .from('orders')
        .update({ 
          status: estado,
          updated_at: new Date().toISOString()
        })
        .eq('id', pedidoId)

      if (error) {
        console.error('Error actualizando estado:', error)
        return
      }

      // Actualizar estado local
      const pedido = this.pedidos.find(p => p.id === pedidoId)
      if (pedido) {
        pedido.status = estado
      }
    },

    // Suscribirse a cambios realtime
    subscribeToRealtime() {
      const client = useSupabaseClient()
      
      // Suscribirse a orders
      const channel = client
        .channel('monkey-food-changes')
        .on('postgres_changes', { 
          event: '*', 
          schema: 'public', 
          table: 'orders' 
        }, (payload) => {
          console.log('Cambio en orders:', payload)
          if (payload.eventType === 'INSERT') {
            this.loadPedidos()
          } else if (payload.eventType === 'UPDATE') {
            const idx = this.pedidos.findIndex(p => p.id === payload.new.id)
            if (idx !== -1) {
              this.pedidos[idx].status = payload.new.status
            }
          }
        })
        .subscribe()

      return () => {
        client.removeChannel(channel)
      }
    },

    // === METODOS LOCALSTORAGE (fallback) ===
    agregarAlCarrito(product: Bowl) {
      const existente = this.carrito.find(item => item.product.id === product.id)
      if (existente) {
        existente.cantidad++
      } else {
        this.carrito.push({ product, cantidad: 1 })
      }
    },

    removerDelCarrito(productId: string) {
      const index = this.carrito.findIndex(item => item.product.id === productId)
      if (index !== -1) {
        if (this.carrito[index].cantidad > 1) {
          this.carrito[index].cantidad--
        } else {
          this.carrito.splice(index, 1)
        }
      }
    },

    vaciarCarrito() {
      this.carrito = []
    },

    // Crear pedido local (sin Supabase)
    crearPedidoLocal(cliente: string, teléfono: string, dirección: string, notas: string): Pedido {
      const bowl = this.carrito[0]?.product
      const pedido: Pedido = {
        id: Date.now().toString(),
        customer_name: cliente,
        customer_phone: teléfono,
        customer_address: dirección,
        status: 'pending',
        total: this.totalCarrito,
        notes: notas,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
      this.pedidos.push(pedido)
      this.vaciarCarrito()
      return pedido
    },

    loadFromStorage() {
      if (typeof window === 'undefined') return
      const stored = localStorage.getItem('monkey-food-pedidos')
      if (stored) {
        this.pedidos = JSON.parse(stored)
      }
    },

    saveToStorage() {
      if (typeof window === 'undefined') return
      localStorage.setItem('monkey-food-pedidos', JSON.stringify(this.pedidos))
    },

    // Inicializar
    async initialize() {
      // Si hay variables de entorno de Supabase, usar Supabase
      const config = useRuntimeConfig()
      const supabaseUrl = config.public.supabaseUrl || 'https://almfsjxrajxmyfygrtdj.supabase.co'
      
      console.log('Supabase URL:', supabaseUrl)
      
      if (supabaseUrl && supabaseUrl !== 'https://placeholder.supabase.co') {
        this.useSupabase = true
        await this.loadBowls()
        await this.loadConfig()
        await this.loadPedidos()
        
        // Suscribirse a realtime
        this.subscribeToRealtime()
      } else {
        // Usar datos locales hardcodeados
        this.bowls = [
          { id: '1', nombre: 'Pollo Power', descripcion: 'Arroz relleno (arveja + zanahoria + refrito), pollo desmechado', price: 4, category: 'animal', protein_grams: '35-40g', emoji: '🍗', available: true },
          { id: '2', nombre: 'Seco Fit de Pollo', descripcion: 'Pollo con tomate y pimiento, arroz + ensalada', price: 4, category: 'animal', protein_grams: '30-35g', emoji: '🍗', available: true },
          { id: '3', nombre: 'Seco Fit de Carne', descripcion: 'Carne guisada con tomate y pimiento, arroz + ensalada', price: 4, category: 'animal', protein_grams: '30-35g', emoji: '🥩', available: true },
          { id: '4', nombre: 'Soya Power', descripcion: 'Arroz relleno (arveja + zanahoria + refrito), carne de soya', price: 4, category: 'vegetal', protein_grams: '30-35g', emoji: '🫘', available: true },
          { id: '5', nombre: 'Seco Vegetal', descripcion: 'Soya con tomate y pimiento, arroz + ensalada', price: 4, category: 'vegetal', protein_grams: '28-32g', emoji: '🫘', available: true }
        ]
        this.loadFromStorage()
      }
    }
  }
})
