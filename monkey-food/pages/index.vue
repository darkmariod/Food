<template>
    <div class="min-h-screen bg-gray-50">
        <!-- Header -->
        <header
            class="bg-green-600 text-white p-3 sm:p-4 shadow-lg sticky top-0 z-40"
        >
            <div class="max-w-md mx-auto flex justify-between items-center">
                <h1 class="text-lg sm:text-xl font-bold">Food</h1>
                <NuxtLink
                    to="/admin-login"
                    class="text-xs sm:text-sm opacity-80 hover:opacity-100 bg-white/20 px-2 py-1 rounded"
                >
                    Admin
                </NuxtLink>
            </div>
        </header>

        <!-- Info - Urgencia + Beneficio -->
        <div class="bg-green-50 p-2 sm:p-3">
            <p
                class="text-center text-green-800 text-xs sm:text-sm font-medium"
            >
                {{
                    bowlsDisponibles > 0
                        ? `Solo ${bowlsDisponibles} bowls disponibles`
                        : "Pedidos cerrados hoy"
                }}
            </p>
            <p class="text-center text-green-700 text-xs mt-1">
                Pedidos hasta las 14PM | Entregas 16:30-18:00PM
            </p>
        </div>

        <!-- Beneficios -->
        <div class="bg-white border-b border-gray-100 p-3">
            <div
                class="max-w-md mx-auto flex flex-col gap-1 text-xs text-gray-600"
            >
                <p><strong>30-40g proteína</strong> - ideal post-entreno</p>
                <p>
                    <strong>Ingredientes frescos</strong> - preparado cada día
                </p>
                <p><strong>Pide en 1 minuto</strong></p>
            </div>
        </div>

        <!-- Confianza -->
        <div class="bg-gray-50 p-2 border-b border-gray-200">
            <div
                class="max-w-md mx-auto flex justify-center gap-4 text-xs text-gray-500"
            >
                <span>Pago contra entrega</span>
                <span>Preparado al momento</span>
                <span>Entrega puntual</span>
            </div>
        </div>

        <!-- Carrito flotante -->
        <div
            v-if="menuStore.carrito.length > 0"
            class="fixed bottom-4 left-4 right-4 z-50 sm:left-auto sm:right-6 sm:w-auto"
        >
            <button
                @click="mostrarCarrito = true"
                class="w-full sm:w-auto bg-green-600 text-white px-4 py-3 sm:px-6 rounded-full shadow-lg flex items-center justify-center gap-3 hover:bg-green-700 transition active:scale-95"
            >
                <span class="font-bold">Ordenar ahora</span>
                <span
                    class="bg-white text-green-600 px-2 py-0.5 rounded-full font-bold"
                >
                    ${{ menuStore.totalCarrito }}
                </span>
            </button>
        </div>

        <!-- Menú -->
        <main
            class="max-w-md mx-auto p-3 sm:p-4 pb-24"
            :class="{
                'opacity-50 pointer-events-none': bowlsDisponibles === 0,
            }"
        >
            <!-- Proteína Animal -->
            <section class="mb-6">
                <h2 class="text-base sm:text-lg font-bold text-gray-800 mb-3">
                    Proteína Animal
                </h2>
                <div class="grid grid-cols-2 gap-3">
                    <div
                        v-for="bowl in menuStore.bowlsAnimal"
                        :key="bowl.id"
                        class="bg-white rounded-xl p-3 shadow-sm border border-gray-100 hover:shadow-md transition flex flex-col"
                    >
                        <div class="text-center mb-2">
                            <span class="text-3xl block">{{ bowl.emoji }}</span>
                        </div>
                        <h3
                            class="font-bold text-gray-800 text-center text-sm leading-tight"
                        >
                            {{ bowl.nombre }}
                        </h3>
                        <p
                            class="text-xs text-gray-500 text-center mt-1 line-clamp-2"
                        >
                            {{ bowl.descripcion }}
                        </p>
                        <p
                            class="text-xs text-green-600 text-center mt-1 font-medium"
                        >
                            {{ bowl.protein_grams }} proteína
                        </p>
                        <div
                            class="mt-auto pt-2 flex items-center justify-between gap-2"
                        >
                            <span class="text-lg font-bold text-green-600"
                                >$4</span
                            >
                            <button
                                @click="menuStore.agregarAlCarrito(bowl)"
                                class="flex-1 bg-green-600 text-white py-2 rounded-full text-sm font-medium hover:bg-green-700 active:scale-95 transition"
                            >
                                Agregar
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Proteína Vegetal -->
            <section class="mb-6">
                <h2 class="text-base sm:text-lg font-bold text-gray-800 mb-3">
                    Proteína Vegetal
                </h2>
                <div class="grid grid-cols-2 gap-3">
                    <div
                        v-for="bowl in menuStore.bowlsVegetal"
                        :key="bowl.id"
                        class="bg-white rounded-xl p-3 shadow-sm border border-gray-100 hover:shadow-md transition flex flex-col"
                    >
                        <div class="text-center mb-2">
                            <span class="text-3xl block">{{ bowl.emoji }}</span>
                        </div>
                        <h3
                            class="font-bold text-gray-800 text-center text-sm leading-tight"
                        >
                            {{ bowl.nombre }}
                        </h3>
                        <p
                            class="text-xs text-gray-500 text-center mt-1 line-clamp-2"
                        >
                            {{ bowl.descripcion }}
                        </p>
                        <p
                            class="text-xs text-green-600 text-center mt-1 font-medium"
                        >
                            {{ bowl.protein_grams }} proteína
                        </p>
                        <div
                            class="mt-auto pt-2 flex items-center justify-between gap-2"
                        >
                            <span class="text-lg font-bold text-green-600"
                                >$4</span
                            >
                            <button
                                @click="menuStore.agregarAlCarrito(bowl)"
                                class="flex-1 bg-green-600 text-white py-2 rounded-full text-sm font-medium hover:bg-green-700 active:scale-95 transition"
                            >
                                Agregar
                            </button>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <!-- Modal Carrito -->
        <div
            v-if="mostrarCarrito"
            class="fixed inset-0 bg-black/60 z-50 flex items-end sm:items-center sm:justify-center"
        >
            <div
                class="bg-white w-full max-w-md mx-auto rounded-t-2xl sm:rounded-2xl p-4 max-h-[85vh] overflow-y-auto"
            >
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-lg font-bold">Tu Pedido</h2>
                    <button
                        @click="mostrarCarrito = false"
                        class="w-8 h-8 flex items-center justify-center bg-gray-100 rounded-full text-gray-600"
                    >
                        X
                    </button>
                </div>

                <div
                    v-if="menuStore.carrito.length === 0"
                    class="text-center py-8 text-gray-500"
                >
                    <p class="text-4xl mb-2">🛒</p>
                    <p>Tu carrito está vacío</p>
                </div>

                <div v-else class="space-y-3 mb-4">
                    <div
                        v-for="item in menuStore.carrito"
                        :key="item.product.id"
                        class="flex justify-between items-center border-b pb-3"
                    >
                        <div class="flex-1">
                            <p class="font-medium text-sm">
                                {{ item.product.nombre }}
                            </p>
                            <p class="text-xs text-gray-500">
                                x{{ item.cantidad }}
                            </p>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="font-bold"
                                >${{ item.product.price * item.cantidad }}</span
                            >
                            <button
                                @click="
                                    menuStore.removerDelCarrito(item.product.id)
                                "
                                class="w-7 h-7 flex items-center justify-center bg-red-100 text-red-600 rounded-full text-xs"
                            >
                                -
                            </button>
                        </div>
                    </div>
                </div>

                <div
                    v-if="menuStore.carrito.length > 0"
                    class="border-t pt-4 mb-4"
                >
                    <div class="flex justify-between text-xl font-bold">
                        <span>Total:</span>
                        <span class="text-green-600"
                            >${{ menuStore.totalCarrito }}</span
                        >
                    </div>
                </div>

                <!-- Datos del cliente -->
                <div v-if="menuStore.carrito.length > 0" class="space-y-3 mb-4">
                    <input
                        v-model="nombreCliente"
                        placeholder="Tu nombre *"
                        class="w-full p-3 border rounded-xl text-base"
                    />
                    <input
                        v-model="teléfonoCliente"
                        placeholder="Tu WhatsApp * (ej: 0991234567)"
                        class="w-full p-3 border rounded-xl text-base"
                        type="tel"
                    />
                    <input
                        v-model="direcciónCliente"
                        placeholder="Dirección de entrega *"
                        class="w-full p-3 border rounded-xl text-base"
                    />
                    <input
                        v-model="horaEntrega"
                        placeholder="Hora de entrega (ej: 6:30 PM)"
                        class="w-full p-3 border rounded-xl text-base"
                    />
                </div>

                <button
                    @click="enviarPedido"
                    :disabled="
                        !nombreCliente ||
                        !teléfonoCliente ||
                        !direcciónCliente ||
                        menuStore.carrito.length === 0 ||
                        bowlsDisponibles === 0
                    "
                    class="w-full bg-green-600 text-white py-4 rounded-xl font-bold text-lg disabled:opacity-50 active:scale-95 transition"
                >
                    Enviar pedido por WhatsApp
                </button>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useMenuStore } from "~/stores/menu";

const menuStore = useMenuStore();
const mostrarCarrito = ref(false);
const nombreCliente = ref("");
const teléfonoCliente = ref("");
const direcciónCliente = ref("");
const horaEntrega = ref("");

// Configuración desde localStorage o valores por defecto
const bowlsDisponibles = computed(() => {
    if (typeof window === "undefined") return 10;
    const config = localStorage.getItem("monkey-admin-config");
    if (config) {
        return JSON.parse(config).bowlsDisponibles || 10;
    }
    return 10;
});

onMounted(async () => {
    await menuStore.initialize();
});

const enviarPedido = async () => {
    // 1. Armar el resumen ANTES de guardar (crearPedidoSupabase vacía el carrito)
    const itemsAgrupados = menuStore.carrito.reduce(
        (acc, item) => {
            const key = item.product.nombre;
            if (!acc[key]) {
                acc[key] = { ...item, cantidad: 0 };
            }
            acc[key].cantidad += item.cantidad;
            return acc;
        },
        {} as Record<string, { product: any; cantidad: number }>,
    );

    const resumenItems = Object.values(itemsAgrupados)
        .map((item) => `${item.cantidad}x ${item.product.nombre}`)
        .join(", ");
    const total = menuStore.totalCarrito;

    // Notas que verá el dueño en el panel: qué pidió + hora de entrega
    const notas = `${resumenItems} | Entrega: ${horaEntrega.value || "A convenir"}`;

    // 2. Guardar el pedido en Supabase (aparece en el panel del dueño)
    let guardado = null;
    try {
        guardado = await menuStore.crearPedidoSupabase(
            nombreCliente.value,
            teléfonoCliente.value,
            direcciónCliente.value,
            notas,
        );
    } catch (e) {
        console.error("Error guardando pedido:", e);
    }

    if (!guardado) {
        alert(
            "Ups, no pudimos registrar tu pedido. Probá de nuevo o escribinos por WhatsApp.",
        );
        return;
    }

    // 3. Abrir WhatsApp con el pedido ya redactado
    let mensaje = `Hola, quiero pedir:\n\n`;
    Object.values(itemsAgrupados).forEach((item) => {
        mensaje += `- ${item.cantidad}x ${item.product.nombre}\n`;
    });
    mensaje += `\nTotal: $${total}\n\n`;
    mensaje += `Direccion: ${direcciónCliente.value}\n`;
    mensaje += `Hora de entrega: ${horaEntrega.value || "A convenir"}\n`;
    mensaje += `Cliente: ${nombreCliente.value}\n`;
    mensaje += `WhatsApp: ${teléfonoCliente.value}`;

    const urlWhatsapp = `https://wa.me/593968464331?text=${encodeURIComponent(mensaje)}`;
    window.open(urlWhatsapp, "_blank");

    mostrarCarrito.value = false;
    nombreCliente.value = "";
    teléfonoCliente.value = "";
    direcciónCliente.value = "";
    horaEntrega.value = "";

    alert("Pedido enviado! Seras redirigido a WhatsApp.");
};
</script>
