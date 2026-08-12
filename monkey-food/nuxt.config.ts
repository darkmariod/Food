// https://nuxt.com/docs/api/configuration
export default defineNuxtConfig({
  devtools: { enabled: true },
  compatibilityDate: '2024-11-01',
  app: {
    head: {
      title: 'food fitness · Riobamba',
      meta: [
        { name: 'description', content: 'comida real, hecha con amor · Riobamba' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Archivo+Black&family=Inter:wght@400;500;600;700;800;900&display=swap' }
      ]
    }
  },
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss', '@nuxtjs/supabase'],

  supabase: {
    redirect: false,
    url: process.env.SUPABASE_URL || 'https://almfsjxrajxmyfygrtdj.supabase.co',
    key: process.env.SUPABASE_KEY || 'sb_publishable_5wCGWfuWq5Y8JOMM8sVT5w_f_4YvogO',
    supabaseUrl: process.env.SUPABASE_URL || 'https://almfsjxrajxmyfygrtdj.supabase.co',
    supabaseKey: process.env.SUPABASE_KEY || 'sb_publishable_5wCGWfuWq5Y8JOMM8sVT5w_f_4YvogO'
  },

  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL || 'https://almfsjxrajxmyfygrtdj.supabase.co',
      supabaseAnonKey: process.env.SUPABASE_KEY || 'sb_publishable_5wCGWfuWq5Y8JOMM8sVT5w_f_4YvogO',
      whatsappNumber: '593968464331'
    }
  },

  css: ['~/assets/css/main.css']
})
