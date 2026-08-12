<template>
    <div class="min-h-screen bg-[#fffdf9]">
        <!-- Admin discreto -->
        <div class="max-w-md mx-auto px-5 pt-3 flex justify-end">
            <NuxtLink
                to="/admin-login"
                class="text-xs text-gray-400 hover:text-gray-600"
            >
                Admin
            </NuxtLink>
        </div>

        <!-- Cabecera -->
        <header class="max-w-md mx-auto px-5 pt-1 text-center">
            <h1 class="text-3xl font-extrabold text-black tracking-tight">
                food fitness
            </h1>
            <p class="text-gray-500 mt-1">
                comida real, hecha con amor · Riobamba
            </p>
        </header>

        <!-- Banner info -->
        <div class="max-w-md mx-auto px-5 mt-5">
            <div
                class="bg-blue-100 rounded-2xl px-4 py-3 flex items-center justify-between gap-3"
            >
                <span class="text-blue-800 font-bold leading-tight">
                    {{
                        disponibles > 0
                            ? `hoy quedan ${disponibles} pedidos`
                            : "hoy ya cerramos"
                    }}
                </span>
                <span
                    class="text-blue-700 text-sm flex items-center gap-1.5 shrink-0"
                >
                    <svg
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.8"
                        class="w-4 h-4"
                    >
                        <circle cx="12" cy="12" r="9" />
                        <path d="M12 7v5l3 2" stroke-linecap="round" />
                    </svg>
                    pedidos hasta las 9:00am
                </span>
            </div>
        </div>

        <!-- Lista de platos -->
        <main
            class="max-w-md mx-auto px-5 mt-4 pb-28"
            :class="{ 'opacity-50 pointer-events-none': disponibles === 0 }"
        >
            <div
                v-for="plato in platos"
                :key="plato.id"
                class="flex items-center justify-between gap-3 py-4 border-b border-gray-100"
            >
                <div class="min-w-0">
                    <p class="font-bold text-black">{{ plato.nombre }}</p>
                    <p class="text-sm text-gray-500 mt-0.5">
                        {{ plato.descripcion }}
                    </p>
                </div>
                <div class="flex items-center gap-3 shrink-0">
                    <span class="font-bold text-black"
                        >${{ plato.price.toFixed(2) }}</span
                    >
                    <button
                        @click="menuStore.agregarAlCarrito(plato)"
                        class="flex items-center gap-1.5 border border-gray-300 rounded-xl px-3 py-2 text-sm font-medium text-black hover:bg-gray-50 active:scale-95 transition"
                    >
                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            class="w-4 h-4"
                        >
                            <path
                                d="M21 11.5a8.38 8.38 0 01-8.5 8.5 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8A8.5 8.5 0 0112.5 3 8.5 8.5 0 0121 11.5z"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            />
                        </svg>
                        pedir
                    </button>
                </div>
            </div>

            <p
                v-if="platos.length === 0"
                class="text-center text-gray-400 py-10"
            >
                No hay productos disponibles hoy.
            </p>

            <!-- Info del negocio -->
            <div class="mt-8 space-y-2.5 text-sm text-gray-600">
                <p class="flex items-start gap-2.5">
                    <svg
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.8"
                        class="w-4 h-4 mt-0.5 shrink-0"
                    >
                        <path
                            d="M21 10c0 6-9 12-9 12s-9-6-9-12a9 9 0 0118 0z"
                        />
                        <circle cx="12" cy="10" r="3" />
                    </svg>
                    <span
                        >agosto: gimnasios de la comunidad · septiembre: colegio
                        y universidad</span
                    >
                </p>
                <p class="flex items-start gap-2.5">
                    <svg
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.8"
                        class="w-4 h-4 mt-0.5 shrink-0"
                    >
                        <path
                            d="M20 6L9 17l-5-5"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        />
                    </svg>
                    <span>pago contra entrega · ingredientes frescos</span>
                </p>
            </div>
        </main>

        <!-- Carrito flotante -->
        <div
            v-if="menuStore.carrito.length > 0"
            class="fixed bottom-4 left-4 right-4 z-50 sm:left-auto sm:right-6 sm:w-auto"
        >
            <button
                @click="mostrarCarrito = true"
                class="w-full sm:w-auto bg-black text-white px-4 py-3 sm:px-6 rounded-full shadow-lg flex items-center justify-center gap-3 active:scale-95 transition"
            >
                <span class="font-bold">ver mi pedido</span>
                <span
                    class="bg-white text-black px-2 py-0.5 rounded-full font-bold"
                >
                    ${{ menuStore.totalCarrito.toFixed(2) }}
                </span>
            </button>
        </div>

        <!-- Modal Carrito -->
        <div
            v-if="mostrarCarrito"
            class="fixed inset-0 bg-black/60 z-50 flex items-end sm:items-center sm:justify-center"
        >
            <div
                class="bg-white w-full max-w-md mx-auto rounded-t-2xl sm:rounded-2xl p-4 max-h-[85vh] overflow-y-auto"
            >
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-lg font-bold text-black">tu pedido</h2>
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
                    <p>tu pedido está vacío</p>
                </div>

                <div v-else class="space-y-3 mb-4">
                    <div
                        v-for="item in menuStore.carrito"
                        :key="item.product.id"
                        class="flex justify-between items-center border-b pb-3"
                    >
                        <div class="flex-1">
                            <p class="font-medium text-sm text-black">
                                {{ item.product.nombre }}
                            </p>
                            <p class="text-xs text-gray-500">
                                x{{ item.cantidad }}
                            </p>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="font-bold text-black"
                                >${{ (item.product.price * item.cantidad).toFixed(2) }}</span
                            >
                            <button
                                @click="menuStore.removerDelCarrito(item.product.id)"
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
                    <div class="flex justify-between text-xl font-bold text-black">
                        <span>total:</span>
                        <span>${{ menuStore.totalCarrito.toFixed(2) }}</span>
                    </div>
                </div>

                <!-- Datos del cliente -->
                <div v-if="menuStore.carrito.length > 0" class="space-y-3 mb-4">
                    <input
                        v-model="nombreCliente"
                        placeholder="tu nombre *"
                        class="w-full p-3 border rounded-xl text-base"
                    />
                    <input
                        v-model="teléfonoCliente"
                        placeholder="tu WhatsApp * (ej: 0991234567)"
                        class="w-full p-3 border rounded-xl text-base"
                        type="tel"
                    />
                    <input
                        v-model="direcciónCliente"
                        placeholder="dirección de entrega *"
                        class="w-full p-3 border rounded-xl text-base"
                    />
                    <input
                        v-model="horaEntrega"
                        placeholder="hora de entrega (opcional)"
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
                        disponibles === 0
                    "
                    class="w-full bg-black text-white py-4 rounded-xl font-bold text-lg disabled:opacity-50 active:scale-95 transition"
                >
                    enviar pedido por WhatsApp
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

// Todos los platos disponibles (lista plana, sin categorías)
const platos = computed(() => menuStore.bowls.filter((b) => b.available));

// Cupos del día (desde config del admin)
const disponibles = computed(() => {
    if (typeof window === "undefined") return 12;
    const config = localStorage.getItem("monkey-admin-config");
    if (config) {
        return JSON.parse(config).bowlsDisponibles ?? 12;
    }
    return 12;
});

onMounted(async () => {
    await menuStore.initialize();
});

const enviarPedido = async () => {
    // 1. Resumen ANTES de guardar (crearPedidoSupabase vacía el carrito)
    const itemsAgrupados = menuStore.carrito.reduce(
        (acc, item) => {
            const key = item.product.nombre;
            if (!acc[key]) acc[key] = { ...item, cantidad: 0 };
            acc[key].cantidad += item.cantidad;
            return acc;
        },
        {} as Record<string, { product: any; cantidad: number }>,
    );

    const resumenItems = Object.values(itemsAgrupados)
        .map((item) => `${item.cantidad}x ${item.product.nombre}`)
        .join(", ");
    const total = menuStore.totalCarrito;
    const notas = `${resumenItems} | Entrega: ${horaEntrega.value || "A convenir"}`;

    // 2. Guardar en Supabase (aparece en el panel)
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

    // 3. Abrir WhatsApp con el pedido redactado
    let mensaje = `Hola, quiero pedir:\n\n`;
    Object.values(itemsAgrupados).forEach((item) => {
        mensaje += `- ${item.cantidad}x ${item.product.nombre}\n`;
    });
    mensaje += `\nTotal: $${total.toFixed(2)}\n\n`;
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

    alert("¡Pedido enviado! Te redirigimos a WhatsApp.");
};
</script>
