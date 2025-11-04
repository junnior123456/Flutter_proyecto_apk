# 🌐 Configuración de Red - PawFinder

## 📋 **URLs Configuradas para Android/Genymotion:**

### 🎯 **URL Principal:**
- `http://192.168.18.97:3000/api` (IP WiFi del host)

### 🔄 **URLs Alternativas (Auto-detección):**
1. `http://192.168.56.1:3000/api` - Genymotion host bridge
2. `http://192.168.56.2:3000/api` - Genymotion alternativa  
3. `http://10.0.2.2:3000/api` - Android Studio Emulator
4. `http://10.0.3.2:3000/api` - Genymotion NAT
5. `http://localhost:3000/api` - Localhost directo
6. `http://127.0.0.1:3000/api` - IP local

## ✅ **Estado del Backend:**
- ✅ Escuchando en `0.0.0.0:3000` (todas las interfaces)
- ✅ CORS habilitado para todas las conexiones
- ✅ Accesible desde múltiples IPs de red

## 🔧 **Funcionalidades Implementadas:**
- 🔍 **Auto-detección de IP:** Prueba automáticamente todas las URLs
- 📱 **Configuración específica por plataforma:** Web vs Android
- 🔄 **Fallback automático:** Si una URL falla, prueba la siguiente
- 📊 **Logs detallados:** Para diagnóstico de conectividad

## 🧪 **Para Probar la Conexión:**
1. Abre la app en el emulador
2. Ve a "🧪 Probar API Backend"
3. Haz clic en "Verificar Conexión"
4. Observa los logs en la consola de Flutter

## 🔐 **Credenciales de Prueba:**
- **Email:** `junnior@upeu.edu.pe`
- **Contraseña:** `123456`
- **Rol:** ADMIN (primer usuario)

## 📱 **Configuración de Android:**
- ✅ Permisos de internet habilitados
- ✅ Network security config configurado
- ✅ Cleartext traffic permitido para desarrollo