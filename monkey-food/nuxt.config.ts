// https://nuxt.com/docs/api/configuration
export default defineNuxtConfig({
  devtools: { enabled: true },
  compatibilityDate: '2024-11-01',
  app: {
    head: {
      title: 'Monkey Food Fitness',
      meta: [
        { name: 'description', content: 'Bowls altos en proteina - Riobamba' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
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
