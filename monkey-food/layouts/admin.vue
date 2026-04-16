<template>
  <div class="min-h-screen bg-[#fffbf5] flex flex-col">
    <!-- Header -->
    <header class="flex-shrink-0 bg-[#fffbf5] border-b border-gray-200 px-4 py-2 flex items-center justify-between">
      <div class="w-10"></div>
      <h1 class="text-lg font-bold text-gray-800">Monkey Food</h1>
      <button @click="logout" class="w-10 text-center">
        <span class="text-xs text-gray-400">Salir</span>
      </button>
    </header>

    <!-- Quick Actions -->
    <div class="bg-white border-b border-gray-200 px-4 py-2 flex-shrink-0">
      <div class="flex gap-2 overflow-x-auto">
        <NuxtLink 
          to="/admin"
          :class="['filter-btn', $route.path === '/admin' ? 'filter-btn-active' : 'filter-btn-inactive']"
        >
          Hoy
        </NuxtLink>
        <NuxtLink 
          to="/admin/pedidos"
          :class="['filter-btn', $route.path === '/admin/pedidos' ? 'filter-btn-active' : 'filter-btn-inactive']"
        >
          Pedidos
        </NuxtLink>
        <NuxtLink 
          to="/admin/menu"
          :class="['filter-btn', $route.path === '/admin/menu' ? 'filter-btn-active' : 'filter-btn-inactive']"
        >
          Menu
        </NuxtLink>
        <NuxtLink 
          to="/admin/stats"
          :class="['filter-btn', $route.path === '/admin/stats' ? 'filter-btn-active' : 'filter-btn-inactive']"
        >
          Stats
        </NuxtLink>
      </div>
    </div>

    <!-- Main content -->
    <main class="flex-1 overflow-y-auto mx-auto w-full max-w-lg px-0 pb-20">
      <NuxtPage />
    </main>

    <!-- NavBar -->
    <nav class="flex-shrink-0 bg-white border-t-4 border-gray-100 shadow-lg">
      <div class="flex items-center justify-around h-16 max-w-lg mx-auto px-2">
        <NuxtLink 
          to="/admin"
          :class="['flex flex-col items-center gap-0.5 flex-1 py-2 transition-colors', 
            $route.path === '/admin' ? 'text-green-600' : 'text-gray-400']"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
          </svg>
          <span class="text-[10px] font-medium">Hoy</span>
        </NuxtLink>
        <NuxtLink 
          to="/admin/pedidos"
          :class="['flex flex-col items-center gap-0.5 flex-1 py-2 transition-colors', 
            $route.path === '/admin/pedidos' ? 'text-green-600' : 'text-gray-400']"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
          </svg>
          <span class="text-[10px] font-medium">Pedidos</span>
        </NuxtLink>
        <NuxtLink 
          to="/admin/menu"
          :class="['flex flex-col items-center gap-0.5 flex-1 py-2 transition-colors', 
            $route.path === '/admin/menu' ? 'text-green-600' : 'text-gray-400']"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
          <span class="text-[10px] font-medium">Menu</span>
        </NuxtLink>
        <NuxtLink 
          to="/admin/stats"
          :class="['flex flex-col items-center gap-0.5 flex-1 py-2 transition-colors', 
            $route.path === '/admin/stats' ? 'text-green-600' : 'text-gray-400']"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
          </svg>
          <span class="text-[10px] font-medium">Stats</span>
        </NuxtLink>
      </div>
    </nav>
  </div>
</template>

<script setup lang="ts">
const logout = () => {
  localStorage.removeItem('monkey-admin-auth')
  navigateTo('/admin-login')
}
</script>