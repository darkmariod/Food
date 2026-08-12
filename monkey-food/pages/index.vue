<template>
    <div class="min-h-screen bg-[var(--ff-cream)]">
        <!-- Header estilo Cobra (verde oscuro) -->
        <header
            class="sticky top-0 z-40 bg-[var(--ff-dark)] text-white"
        >
            <div
                class="max-w-md mx-auto px-4 py-3 flex items-center justify-between"
            >
                <div class="flex items-center gap-2.5">
                    <span
                        class="w-9 h-9 rounded-xl bg-white/15 text-white font-display flex items-center justify-center text-sm"
                        >ff</span
                    >
                    <div class="leading-tight">
                        <p class="font-display text-white text-[17px]">
                            food fitness
                        </p>
                        <p class="text-[11px] text-white/60">Riobamba</p>
                    </div>
                </div>
                <div class="flex items-center gap-3">
                    <span
                        class="hidden xs:flex items-center gap-1.5 text-xs text-white/80"
                    >
                        <span
                            class="w-2 h-2 rounded-full bg-[var(--ff-green)]"
                        ></span>
                        abierto
                    </span>
                    <NuxtLink
                        to="/admin-login"
                        class="text-xs text-white/60 hover:text-white"
                    >
                        Admin
                    </NuxtLink>
                </div>
            </div>
        </header>

        <!-- Sub-cabecera -->
        <div class="max-w-md mx-auto px-4 pt-4">
            <h1 class="font-display text-2xl text-gray-900 leading-tight">
                Menú de hoy
            </h1>
            <p class="text-sm text-gray-500 mt-0.5">
                comida real, hecha con amor ·
                <span class="font-semibold text-[var(--ff-green)]">{{
                    disponibles > 0
                        ? `quedan ${disponibles} pedidos`
                        : "cerrado por hoy"
                }}</span>
            </p>
        </div>

        <!-- Categorías -->
        <div
            v-if="categorias.length > 0"
            class="max-w-md mx-auto px-4 mt-3 flex gap-2 overflow-x-auto pb-1 scrollbar-hide"
        >
            <button
                @click="categoriaSel = 'todo'"
                :class="[
                    'shrink-0 px-4 py-1.5 rounded-full text-sm font-semibold border transition-colors',
                    categoriaSel === 'todo'
                        ? 'bg-[var(--ff-dark)] text-white border-[var(--ff-dark)]'
                        : 'bg-white text-[var(--ff-dark)] border-[var(--ff-dark)]/25',
                ]"
            >
                Todo
            </button>
            <button
                v-for="c in categorias"
                :key="c"
                @click="categoriaSel = c"
                :class="[
                    'shrink-0 px-4 py-1.5 rounded-full text-sm font-semibold border transition-colors capitalize',
                    categoriaSel === c
                        ? 'bg-[var(--ff-dark)] text-white border-[var(--ff-dark)]'
                        : 'bg-white text-[var(--ff-dark)] border-[var(--ff-dark)]/25',
                ]"
            >
                {{ catEmoji(c) }} {{ catLabel(c) }}
            </button>
        </div>

        <!-- Grilla de productos -->
        <main
            class="max-w-md mx-auto px-4 mt-4 pb-28"
            :class="{ 'opacity-50 pointer-events-none': disponibles === 0 }"
        >
            <div class="grid grid-cols-2 gap-3">
                <div
                    v-for="plato in platos"
                    :key="plato.id"
                    class="bg-white rounded-2xl border border-[var(--ff-dark)]/15 p-2.5 flex flex-col shadow-sm"
                >
                    <div
                        class="aspect-square rounded-xl bg-[var(--ff-sage)] overflow-hidden flex items-center justify-center mb-2"
                    >
                        <img
                            v-if="plato.image_url"
                            :src="plato.image_url"
                            :alt="plato.nombre"
                            class="w-full h-full object-cover"
                            loading="lazy"
                        />
                        <span v-else class="text-4xl">{{
                            plato.emoji || "🍽️"
                        }}</span>
                    </div>
                    <p class="font-bold text-gray-900 text-sm leading-tight">
                        {{ plato.nombre }}
                    </p>
                    <p class="text-xs text-gray-500 line-clamp-1 mt-0.5">
                        {{ plato.descripcion }}
                    </p>
                    <div class="mt-2 flex items-center justify-between">
                        <span class="font-extrabold text-[var(--ff-green)]"
                            >${{ plato.price.toFixed(2) }}</span
                        >
                        <button
                            @click="menuStore.agregarAlCarrito(plato)"
                            class="w-9 h-9 rounded-full bg-[var(--ff-dark)] text-white text-xl leading-none flex items-center justify-center hover:opacity-90 active:scale-90 transition"
                            aria-label="agregar"
                        >
                            +
                        </button>
                    </div>
                </div>
            </div>

            <p
                v-if="platos.length === 0"
                class="text-center text-gray-400 py-10"
            >
                No hay platos en esta categoría hoy.
            </p>

            <!-- Confianza -->
            <div
                class="mt-6 flex flex-wrap gap-x-4 gap-y-1 text-xs text-gray-500"
            >
                <span class="flex items-center gap-1">
                    <span
                        class="w-1.5 h-1.5 rounded-full bg-[var(--ff-green)]"
                    ></span>
                    Pago contra entrega
                </span>
                <span class="flex items-center gap-1">
                    <span
                        class="w-1.5 h-1.5 rounded-full bg-[var(--ff-green)]"
                    ></span>
                    Ingredientes frescos
                </span>
                <span class="flex items-center gap-1">
                    <span
                        class="w-1.5 h-1.5 rounded-full bg-[var(--ff-green)]"
                    ></span>
                    Pedidos hasta las 9:00am
                </span>
            </div>
        </main>

        <!-- Carrito flotante -->
        <div
            v-if="menuStore.carrito.length > 0"
            class="fixed bottom-4 left-4 right-4 z-50 sm:left-auto sm:right-6 sm:w-auto"
        >
            <button
                @click="mostrarCarrito = true"
                class="w-full sm:w-auto bg-[var(--ff-dark)] text-white px-4 py-3.5 sm:px-6 rounded-2xl shadow-lg flex items-center justify-between gap-3 hover:opacity-95 active:scale-[0.98] transition"
            >
                <span class="flex items-center gap-2 font-bold">
                    <span
                        class="bg-white/20 rounded-full w-6 h-6 flex items-center justify-center text-sm"
                        >{{ totalItems }}</span
                    >
                    ver mi pedido
                </span>
                <span class="font-extrabold text-[var(--ff-green)]"
                    >${{ menuStore.totalCarrito.toFixed(2) }}</span
                >
            </button>
        </div>

        <!-- Modal Carrito -->
        <div
            v-if="mostrarCarrito"
            class="fixed inset-0 bg-black/60 z-50 flex items-end sm:items-center sm:justify-center"
        >
            <div
                class="bg-white w-full max-w-md mx-auto rounded-t-2xl sm:rounded-2xl p-4 max-h-[88vh] overflow-y-auto"
            >
                <div class="flex justify-between items-center mb-4">
                    <h2 class="font-display text-lg text-gray-900">tu pedido</h2>
                    <button
                        @click="mostrarCarrito = false"
                        class="w-8 h-8 flex items-center justify-center bg-gray-100 rounded-full text-gray-600"
                    >
                        ✕
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
                        class="flex justify-between items-center border-b border-gray-100 pb-3"
                    >
                        <div class="flex-1 min-w-0">
                            <p
                                class="font-medium text-sm text-gray-900 truncate"
                            >
                                {{ item.product.nombre }}
                            </p>
                            <p class="text-xs text-gray-500">
                                ${{ item.product.price.toFixed(2) }} c/u
                            </p>
                        </div>
                        <div class="flex items-center gap-2">
                            <button
                                @click="
                                    menuStore.removerDelCarrito(item.product.id)
                                "
                                class="w-7 h-7 flex items-center justify-center bg-gray-100 text-gray-700 rounded-full"
                            >
                                −
                            </button>
                            <span class="w-6 text-center font-semibold">{{
                                item.cantidad
                            }}</span>
                            <button
                                @click="menuStore.agregarAlCarrito(item.product)"
                                class="w-7 h-7 flex items-center justify-center bg-[var(--ff-dark)] text-white rounded-full"
                            >
                                +
                            </button>
                        </div>
                    </div>
                </div>

                <div
                    v-if="menuStore.carrito.length > 0"
                    class="border-t border-gray-100 pt-4 mb-4"
                >
                    <div
                        class="flex justify-between text-xl font-extrabold text-gray-900"
                    >
                        <span>total</span>
                        <span class="text-[var(--ff-green)]"
                            >${{ menuStore.totalCarrito.toFixed(2) }}</span
                        >
                    </div>
                </div>

                <!-- Datos del cliente -->
                <div v-if="menuStore.carrito.length > 0" class="space-y-3 mb-4">
                    <input
                        v-model="nombreCliente"
                        placeholder="tu nombre *"
                        class="w-full p-3 border border-gray-200 rounded-xl text-base focus:outline-none focus:border-green-500"
                    />
                    <input
                        v-model="teléfonoCliente"
                        placeholder="tu WhatsApp * (ej: 0991234567)"
                        class="w-full p-3 border border-gray-200 rounded-xl text-base focus:outline-none focus:border-green-500"
                        type="tel"
                    />
                    <input
                        v-model="direcciónCliente"
                        placeholder="dirección de entrega *"
                        class="w-full p-3 border border-gray-200 rounded-xl text-base focus:outline-none focus:border-green-500"
                    />
                    <input
                        v-model="horaEntrega"
                        placeholder="hora de entrega (opcional)"
                        class="w-full p-3 border border-gray-200 rounded-xl text-base focus:outline-none focus:border-green-500"
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
                    class="w-full bg-[var(--ff-dark)] text-white py-4 rounded-xl font-bold text-lg disabled:opacity-50 hover:opacity-95 active:scale-[0.98] transition"
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
const categoriaSel = ref("todo");

// Platos disponibles (activos)
const disponiblesLista = computed(() =>
    menuStore.bowls.filter((b) => b.available),
);

// Categorías presentes en los platos activos
const categorias = computed(() => [
    ...new Set(disponiblesLista.value.map((b) => b.category || "otros")),
]);

// Platos filtrados por categoría seleccionada
const platos = computed(() => {
    if (categoriaSel.value === "todo") return disponiblesLista.value;
    return disponiblesLista.value.filter(
        (b) => (b.category || "otros") === categoriaSel.value,
    );
});

const catLabel = (c: string) =>
    (({
        desayuno: "Desayunos",
        almuerzo: "Almuerzos",
        menestra: "Menestras",
        animal: "Proteína animal",
        vegetal: "Proteína vegetal",
        bebida: "Bebidas",
    }) as Record<string, string>)[c] || c;

const catEmoji = (c: string) =>
    (({
        desayuno: "🍳",
        almuerzo: "🍽️",
        menestra: "🫘",
        animal: "🍗",
        vegetal: "🫘",
        bebida: "🥤",
    }) as Record<string, string>)[c] || "🍴";

const totalItems = computed(() =>
    menuStore.carrito.reduce((s, i) => s + i.cantidad, 0),
);

// Cupos del día (desde config del admin)
const disponibles = computed(() => {
    if (typeof window === "undefined") return 12;
    const config = localStorage.getItem("monkey-admin-config");
    if (config) return JSON.parse(config).bowlsDisponibles ?? 12;
    return 12;
});

onMounted(async () => {
    await menuStore.initialize();
});

const enviarPedido = async () => {
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
