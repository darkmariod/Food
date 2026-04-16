export default defineNuxtRouteMiddleware((to, from) => {
  // Skip auth check for login page
  if (to.path === '/admin-login') {
    return
  }
  
  // Only check on client side
  if (import.meta.client) {
    // Check if admin route
    if (to.path.startsWith('/admin')) {
      const auth = localStorage.getItem('monkey-admin-auth')
      
      if (!auth) {
        return navigateTo('/admin-login')
      }
      
      // Check if session is older than 24 hours
      const authTime = parseInt(auth)
      const now = Date.now()
      const oneDay = 24 * 60 * 60 * 1000
      
      if (now - authTime > oneDay) {
        localStorage.removeItem('monkey-admin-auth')
        return navigateTo('/admin-login')
      }
    }
  }
})