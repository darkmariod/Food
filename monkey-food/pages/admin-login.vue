<template>
  <div class="min-h-screen bg-[#fffbf5] flex flex-col">
    <main class="flex-1 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl p-6 w-full max-w-sm shadow-lg">
        <div class="text-center mb-6">
          <span class="text-4xl">🐒</span>
          <h1 class="text-xl font-bold text-gray-800 mt-2">Monkey Food</h1>
          <p class="text-sm text-gray-500">Panel de Administración</p>
        </div>

        <div v-if="error" class="bg-red-100 text-red-700 px-4 py-2 rounded-xl text-sm mb-4">
          {{ error }}
        </div>

        <div class="space-y-4">
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Usuario</label>
            <input 
              v-model="username"
              type="text"
              placeholder="admin"
              class="input"
            />
          </div>
          <div>
            <label class="text-xs text-gray-500 mb-1 block">Contraseña</label>
            <input 
              v-model="password"
              type="password"
              placeholder="••••••••"
              class="input"
            />
          </div>
          <button 
            @click="login"
            class="w-full bg-green-500 text-white py-3 rounded-xl font-bold hover:bg-green-600 active:scale-95 transition"
          >
            Ingresar
          </button>
        </div>

        <div class="mt-4 text-center">
          <NuxtLink to="/" class="text-sm text-gray-400 hover:text-gray-600">
            ← Volver a la tienda
          </NuxtLink>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const username = ref('')
const password = ref('')
const error = ref('')

// Credenciales por defecto (podés cambiarlas)
const ADMIN_USER = 'admin'
const ADMIN_PASS = 'monkey2024'

const login = () => {
  error.value = ''
  
  if (username.value === ADMIN_USER && password.value === ADMIN_PASS) {
    // Guardar sesión
    localStorage.setItem('monkey-admin-auth', Date.now().toString())
    navigateTo('/admin')
  } else {
    error.value = 'Credenciales incorrectas'
  }
}
</script>