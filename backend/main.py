"""
FitMeals API - Seguro y simple
"""
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import requests
import os
import hashlib
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Config
SUPABASE_URL = os.getenv("SUPABASE_URL", "").rstrip("/")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "fitmeals")  # Cambiar aquí tu password
headers = {"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}", "Content-Type": "application/json"}

# Seguridad simple
def verify_password(password: str) -> bool:
    return password == ADMIN_PASSWORD

# Menú por defecto
PRODUCTOS = [
    {"nombre": "Arroz Relleno de Pollo Fit", "precio": 4.00, "descripcion": "150g arroz + 130g pollo + ensalada", "categoria": "animal"},
    {"nombre": "Menestra Power con Pollo", "precio": 4.00, "descripcion": "Frejol + arroz + pollo + ensalada", "categoria": "animal"},
    {"nombre": "Arroz Relleno de Soya", "precio": 4.00, "descripcion": "Arroz + carne de soya + ensalada", "categoria": "vegetal"},
    {"nombre": "Menestra Power Vegetal", "precio": 4.00, "descripcion": "Frejol + arroz + ensalada", "categoria": "vegetal"},
]

def seed_productos():
    try:
        r = requests.get(f"{SUPABASE_URL}/rest/v1/productos?select=id", headers=headers)
        if r.status_code == 200 and len(r.json()) > 0:
            return
        for p in PRODUCTOS:
            requests.post(f"{SUPABASE_URL}/rest/v1/productos", headers=headers, json={**p, "activo": True})
    except Exception:
        pass

@asynccontextmanager
async def lifespan(app: FastAPI):
    seed_productos()
    yield

app = FastAPI(title="FitMeals API", version="2.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# === RUTAS ===

@app.get("/")
def root():
    return {"message": "FitMeals API", "status": "online"}

@app.get("/health")
def health():
    return {"status": "ok"}

# Login simple (sin expiry)
@app.post("/api/login")
def login(data: dict):
    password = data.get("password", "")
    if verify_password(password):
        return {"token": ADMIN_PASSWORD}  # Sin expiración
    return {"error": "Contraseña incorrecta"}, 401

# Productos públicos
@app.get("/api/productos")
def get_productos():
    r = requests.get(f"{SUPABASE_URL}/rest/v1/productos?activo=eq.true&order=nombre.asc", headers=headers)
    return r.json()

# Productos privados (con token simple)
def verify_token(password: str):
    if not verify_password(password):
        raise HTTPException(status_code=401, detail="No autorizado")

@app.post("/api/productos", dependencies=[])
def create_producto(producto: dict):
    verify_token(producto.get("_token", ""))
    r = requests.post(f"{SUPABASE_URL}/rest/v1/productos", headers=headers, json={**producto, "activo": True})
    return r.json()

@app.put("/api/productos/{producto_id}")
def update_producto(producto_id: str, producto: dict):
    verify_token(producto.get("_token", ""))
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/productos?id=eq.{producto_id}", headers=headers, json=producto)
    return r.json()

@app.delete("/api/productos/{producto_id}")
def delete_producto(producto_id: str, data: dict = {}):
    verify_token(data.get("_token", ""))
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/productos?id=eq.{producto_id}", headers=headers, json={"activo": False})
    return {"message": "Eliminado"}

# Pedidos público (para crear)
@app.get("/api/pedidos")
def get_pedidos(data: dict = {}):
    verify_token(data.get("_token", ""))
    r = requests.get(f"{SUPABASE_URL}/rest/v1/pedidos?order=created_at.desc", headers=headers)
    return r.json()

@app.post("/api/pedidos")
def create_pedido(pedido: dict):
    r = requests.post(f"{SUPABASE_URL}/rest/v1/pedidos", headers=headers, json={
        "cliente_nombre": pedido.get("cliente_nombre", "Cliente"),
        "cliente_telefono": pedido.get("cliente_telefono", ""),
        "items": pedido.get("items", []),
        "total": pedido.get("total", 0),
        "estado": "pendiente",
        "metodo_pago": pedido.get("metodo_pago", "transferencia"),
        "notas": pedido.get("notas", "")
    })
    return r.json()

@app.patch("/api/pedidos/{pedido_id}/estado")
def update_estado(pedido_id: str, data: dict):
    verify_token(data.get("_token", ""))
    estado = data.get("estado", "pendiente")
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/pedidos?id=eq.{pedido_id}", headers=headers, json={"estado": estado})
    return {"message": f"Actualizado a {estado}"}

# Stats
@app.get("/api/stats/hoy")
def stats_hoy(data: dict = {}):
    verify_token(data.get("_token", ""))
    today = datetime.now().strftime("%Y-%m-%d")
    r = requests.get(f"{SUPABASE_URL}/rest/v1/pedidos?created_at=gte.{today}T00:00:00", headers=headers)
    pedidos = r.json()
    return {
        "fecha": today,
        "total_pedidos": len(pedidos),
        "ingresos": sum(p.get("total", 0) for p in pedidos),
        "pendientes": len([p for p in pedidos if p.get("estado") == "pendiente"]),
        "en_proceso": len([p for p in pedidos if p.get("estado") == "en_proceso"]),
        "entregados": len([p for p in pedidos if p.get("estado") == "entregado"]),
        "cancelados": len([p for p in pedidos if p.get("estado") == "cancelado"]),
    }

# === EVENTOS ===
@app.get("/api/eventos")
def get_eventos():
    r = requests.get(f"{SUPABASE_URL}/rest/v1/eventos?activo=eq.true&order=fecha.asc", headers=headers)
    return r.json()

@app.post("/api/eventos", dependencies=[])
def create_evento(evento: dict):
    verify_token(evento.get("_token", ""))
    r = requests.post(f"{SUPABASE_URL}/rest/v1/eventos", headers=headers, json={**evento, "activo": True})
    return r.json()

@app.put("/api/eventos/{evento_id}")
def update_evento(evento_id: str, evento: dict):
    verify_token(evento.get("_token", ""))
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/eventos?id=eq.{evento_id}", headers=headers, json=evento)
    return r.json()

@app.delete("/api/eventos/{evento_id}")
def delete_evento(evento_id: str, data: dict = {}):
    verify_token(data.get("_token", ""))
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/eventos?id=eq.{evento_id}", headers=headers, json={"activo": False})
    return {"message": "Eliminado"}

# === DEGUSTACIONES ===
@app.get("/api/degustaciones")
def get_degustaciones():
    r = requests.get(f"{SUPABASE_URL}/rest/v1/degustaciones?activo=eq.true&order=fecha.asc", headers=headers)
    return r.json()

@app.post("/api/degustaciones", dependencies=[])
def create_degustacion(degustacion: dict):
    verify_token(degustacion.get("_token", ""))
    r = requests.post(f"{SUPABASE_URL}/rest/v1/degustaciones", headers=headers, json={**degustacion, "activo": True})
    return r.json()

@app.put("/api/degustaciones/{degustacion_id}")
def update_degustacion(degustacion_id: str, degustacion: dict):
    verify_token(degustacion.get("_token", ""))
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/degustaciones?id=eq.{degustacion_id}", headers=headers, json=degustacion)
    return r.json()

@app.delete("/api/degustaciones/{degustacion_id}")
def delete_degustacion(degustacion_id: str, data: dict = {}):
    verify_token(data.get("_token", ""))
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/degustaciones?id=eq.{degustacion_id}", headers=headers, json={"activo": False})
    return {"message": "Eliminado"}