// https://nuxt.com/docs/api/configuration
export default defineNuxtConfig({
  devtools: { enabled: true },
  compatibilityDate: '2024-11-01',
  app: {
    head: {
      title: 'Monkey Food Fitness 🐒',
      meta: [
        { name: 'description', content: 'Bowls altos en proteína - Riobamba' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  },
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss', '@nuxtjs/supabase'],

  supabase: {
    redirect: false
  },

  css: ['~/assets/css/main.css']
})