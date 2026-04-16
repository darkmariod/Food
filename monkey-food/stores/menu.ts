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
  items: { product: Bowl; quantity: number }[]
  created_at: string
}

export const useMenuStore = defineStore('menu', {
  state: () => ({
    bowls: [] as Bowl[],
    pedidos: [] as Pedido[],
    carrito: [] as { product: Bowl; cantidad: number }[],
    loading: false,
    useSupabase: false // toggle para usar Supabase o localStorage
  }),

  getters: {
    bowlsAnimal: (state) => state.bowls.filter(b => b.category === 'animal' && b.available),
    bowlsVegetal: (state) => state.bowls.filter(b => b.category === 'vegetal' && b.available),
    totalCarrito: (state) => state.carrito.reduce((sum, item) => sum + (item.product.price * item.cantidad), 0),
    pedidosHoy: (state) => {
      const hoy = new Date().toISOString().split('T')[0]
      return state.pedidos.filter(p => p.created_at.startsWith(hoy))
    }
  },

  actions: {
    // Cargar productos desde Supabase
    async loadProducts() {
      if (!this.useSupabase) return
      
      const client = useSupabaseClient()
      const { data } = await client
        .from('products')
        .select('*')
        .eq('available', true)
        .order('name')
      
      if (data) {
        this.bowls = data.map(p => ({
          id: p.id,
          nombre: p.name,
          descripcion: p.description || '',
          price: p.price,
          category: p.category,
          protein_grams: p.protein_grams,
          emoji: p.emoji,
          available: p.available
        }))
      }
    },

    // Cargar pedidos desde Supabase
    async loadOrders() {
      if (!this.useSupabase) return
      
      const client = useSupabaseClient()
      const { data } = await client
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100)
      
      if (data) {
        this.pedidos = data.map(p => ({
          id: p.id,
          customer_name: p.customer_name,
          customer_phone: p.customer_phone,
          customer_address: p.customer_address,
          status: p.status,
          total: p.total,
          items: [],
          created_at: p.created_at
        }))
      }
    },

    // Crear pedido en Supabase
    async crearPedidoSupabase(cliente: string, teléfono: string, dirección: string) {
      if (!this.useSupabase) return null

      const client = useSupabaseClient()
      
      // Agrupar items
      const itemsAgrupados = this.carrito.reduce((acc, item) => {
        const key = item.product.id
        if (!acc[key]) {
          acc[key] = { ...item, cantidad: 0 }
        }
        acc[key].cantidad += item.cantidad
        return acc
      }, {} as Record<string, { product: Bowl; cantidad: number }>)

      // Crear pedido
      const { data: pedido, error } = await client
        .from('orders')
        .insert({
          customer_name: cliente,
          customer_phone: teléfono,
          customer_address: dirección,
          status: 'pending',
          total: this.totalCarrito
        })
        .select()
        .single()

      if (error || !pedido) {
        console.error('Error creando pedido:', error)
        return null
      }

      // Crear items
      const orderItems = Object.values(itemsAgrupados).map(item => ({
        order_id: pedido.id,
        product_id: item.product.id,
        quantity: item.cantidad,
        unit_price: item.product.price
      }))

      await client.from('order_items').insert(orderItems)

      // Limpiar carrito
      this.vaciarCarrito()
      
      return pedido
    },

    // Actualizar estado del pedido
    async actualizarEstado(pedidoId: string, estado: Pedido['status']) {
      if (!this.useSupabase) {
        // Fallback localStorage
        const pedido = this.pedidos.find(p => p.id === pedidoId)
        if (pedido) {
          pedido.status = estado
          this.saveToStorage()
        }
        return
      }

      const client = useSupabaseClient()
      await client
        .from('orders')
        .update({ status: estado })
        .eq('id', pedidoId)
    },

    // Suscribirse a cambios realtime
    subscribeToOrders() {
      if (!this.useSupabase) return () => {}

      const client = useSupabaseClient()
      
      const channel = client
        .channel('orders-changes')
        .on('postgres_changes', { 
          event: '*', 
          schema: 'public', 
          table: 'orders' 
        }, (payload) => {
          if (payload.eventType === 'INSERT') {
            // Nuevo pedido - recargar
            this.loadOrders()
          } else if (payload.eventType === 'UPDATE') {
            // Actualizar pedido específico
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
    crearPedidoLocal(cliente: string, teléfono: string, dirección: string): Pedido {
      const pedido: Pedido = {
        id: Date.now().toString(),
        customer_name: cliente,
        customer_phone: teléfono,
        customer_address: dirección,
        status: 'pending',
        total: this.totalCarrito,
        items: [...this.carrito.map(item => ({ product: item.product, quantity: item.cantidad }))],
        created_at: new Date().toISOString()
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

    // Inicializar - decide entre Supabase o local
    async initialize() {
      // Si hay variables de entorno de Supabase, usar Supabase
      const supabaseUrl = useRuntimeConfig().public.supabaseUrl
      if (supabaseUrl && supabaseUrl !== 'https://placeholder.supabase.co') {
        this.useSupabase = true
        await this.loadProducts()
        await this.loadOrders()
        
        // Suscribirse a realtime
        this.subscribeToOrders()
      } else {
        // Usar datos locales hardcodeados
        this.bowls = [
          { id: '1', nombre: 'Pollo Power ⭐', descripcion: 'Arroz relleno (arveja + zanahoria + refrito), pollo desmechado', price: 4, category: 'animal', protein_grams: '35-40g', emoji: '🍗', available: true },
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