-- =============================================
-- SETUP PROFESIONAL - FitMeals
-- =============================================

-- 1. Tabla productos con validaciones
CREATE TABLE IF NOT EXISTS productos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre text NOT NULL,
    precio numeric(10,2) NOT NULL DEFAULT 0 CHECK (precio >= 0),
    descripcion text,
    categoria text NOT NULL DEFAULT 'animal' CHECK (categoria IN ('animal','vegetal')),
    activo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 2. Tabla pedidos con validaciones
CREATE TABLE IF NOT EXISTS pedidos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_nombre text NOT NULL DEFAULT 'Cliente',
    cliente_telefono text,
    items jsonb NOT NULL DEFAULT '[]'::jsonb,
    total numeric(10,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    estado text NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','en_proceso','entregado','cancelado')),
    notas text,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 3. Índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON productos(activo);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON pedidos(estado);
CREATE INDEX IF NOT EXISTS idx_pedidos_created_at ON pedidos(created_at DESC);

-- 4. Habilitar RLS
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;

-- 5. Políticas
DROP POLICY IF EXISTS productos_select ON productos;
DROP POLICY IF EXISTS productos_insert ON productos;
DROP POLICY IF EXISTS productos_update ON productos;
DROP POLICY IF EXISTS productos_delete ON productos;

CREATE POLICY productos_select ON productos FOR SELECT USING (true);
CREATE POLICY productos_insert ON productos FOR INSERT WITH CHECK (true);
CREATE POLICY productos_update ON productos FOR UPDATE USING (true);
CREATE POLICY productos_delete ON productos FOR DELETE USING (true);

DROP POLICY IF EXISTS pedidos_select ON pedidos;
DROP POLICY IF EXISTS pedidos_insert ON pedidos;
DROP POLICY IF EXISTS pedidos_update ON pedidos;
DROP POLICY IF EXISTS pedidos_delete ON pedidos;

CREATE POLICY pedidos_select ON pedidos FOR SELECT USING (true);
CREATE POLICY pedidos_insert ON pedidos FOR INSERT WITH CHECK (true);
CREATE POLICY pedidos_update ON pedidos FOR UPDATE USING (true);
CREATE POLICY pedidos_delete ON pedidos FOR DELETE USING (true);

-- 6. Limpiar datos duplicados y dejar solo 4 productos
DELETE FROM productos;

INSERT INTO productos (nombre, precio, descripcion, categoria) VALUES
('Arroz Relleno de Pollo Fit', 4.00, '150g arroz + 130g pollo + ensalada', 'animal'),
('Menestra Power con Pollo', 4.00, 'Frejol + arroz + pollo + ensalada', 'animal'),
('Arroz Relleno de Soya', 4.00, 'Arroz + carne de soya + ensalada', 'vegetal'),
('Menestra Power Vegetal', 4.00, 'Frejol + arroz + ensalada', 'vegetal');

-- 5. Tabla eventos
CREATE TABLE IF NOT EXISTS eventos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    titulo text NOT NULL,
    descripcion text,
    precio numeric(10,2) NOT NULL DEFAULT 0 CHECK (precio >= 0),
    fecha date NOT NULL,
    hora text,
    lugar text,
    contacto text,
    activo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 6. Tabla degustaciones
CREATE TABLE IF NOT EXISTS degustaciones (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    titulo text NOT NULL,
    descripcion text,
    precio numeric(10,2) NOT NULL DEFAULT 0 CHECK (precio >= 0),
    fecha date NOT NULL,
    hora text,
    lugar text,
    contacto text,
    activo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 7. Índices
CREATE INDEX IF NOT EXISTS idx_eventos_fecha ON eventos(fecha);
CREATE INDEX IF NOT EXISTS idx_eventos_activo ON eventos(activo);
CREATE INDEX IF NOT EXISTS idx_degustaciones_fecha ON degustaciones(fecha);
CREATE INDEX IF NOT EXISTS idx_degustaciones_activo ON degustaciones(activo);

-- 8. RLS para eventos
ALTER TABLE eventos ENABLE ROW LEVEL SECURITY;
ALTER TABLE degustaciones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS eventos_select ON eventos;
DROP POLICY IF EXISTS eventos_insert ON eventos;
DROP POLICY IF EXISTS eventos_update ON eventos;
DROP POLICY IF EXISTS eventos_delete ON eventos;

CREATE POLICY eventos_select ON eventos FOR SELECT USING (true);
CREATE POLICY eventos_insert ON eventos FOR INSERT WITH CHECK (true);
CREATE POLICY eventos_update ON eventos FOR UPDATE USING (true);
CREATE POLICY eventos_delete ON eventos FOR DELETE USING (true);

DROP POLICY IF EXISTS degustaciones_select ON degustaciones;
DROP POLICY IF EXISTS degustaciones_insert ON degustaciones;
DROP POLICY IF EXISTS degustaciones_update ON degustaciones;
DROP POLICY IF EXISTS degustaciones_delete ON degustaciones;

CREATE POLICY degustaciones_select ON degustaciones FOR SELECT USING (true);
CREATE POLICY degustaciones_insert ON degustaciones FOR INSERT WITH CHECK (true);
CREATE POLICY degustaciones_update ON degustaciones FOR UPDATE USING (true);
CREATE POLICY degustaciones_delete ON degustaciones FOR DELETE USING (true);

SELECT * FROM productos;