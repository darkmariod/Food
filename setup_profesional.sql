-- =============================================
-- FITMEALS - SISTEMA PROFESIONAL
-- =============================================

-- Tabla productos
CREATE TABLE IF NOT EXISTS productos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre text NOT NULL,
    precio numeric(10,2) NOT NULL DEFAULT 0 CHECK (precio >= 0),
    descripcion text,
    categoria text NOT NULL DEFAULT 'animal' CHECK (categoria IN ('animal','vegetal')),
    activo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Tabla pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_nombre text NOT NULL DEFAULT 'Cliente',
    cliente_telefono text,
    items jsonb NOT NULL DEFAULT '[]'::jsonb,
    total numeric(10,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    estado text NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','en_proceso','entregado','cancelado')),
    notas text,
    metodo_pago text DEFAULT 'transferencia',
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON productos(activo);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON pedidos(estado);
CREATE INDEX IF NOT EXISTS idx_pedidos_created_at ON pedidos(created_at DESC);

-- RLS
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;

-- Políticas productos
DROP POLICY IF EXISTS "productos_select" ON productos;
DROP POLICY IF EXISTS "productos_insert" ON productos;
DROP POLICY IF EXISTS "productos_update" ON productos;
DROP POLICY IF EXISTS "productos_delete" ON productos;
CREATE POLICY productos_select ON productos FOR SELECT USING (true);
CREATE POLICY productos_insert ON productos FOR INSERT WITH CHECK (true);
CREATE POLICY productos_update ON productos FOR UPDATE USING (true);
CREATE POLICY productos_delete ON productos FOR DELETE USING (true);

-- Políticas pedidos
DROP POLICY IF EXISTS "pedidos_select" ON pedidos;
DROP POLICY IF EXISTS "pedidos_insert" ON pedidos;
DROP POLICY IF EXISTS "pedidos_update" ON pedidos;
DROP POLICY IF EXISTS "pedidos_delete" ON pedidos;
CREATE POLICY pedidos_select ON pedidos FOR SELECT USING (true);
CREATE POLICY pedidos_insert ON pedidos FOR INSERT WITH CHECK (true);
CREATE POLICY pedidos_update ON pedidos FOR UPDATE USING (true);
CREATE POLICY pedidos_delete ON pedidos FOR DELETE USING (true);

-- Limpiar y cargar productos iniciales
DELETE FROM productos;
INSERT INTO productos (nombre, precio, descripcion, categoria) VALUES
('Arroz Relleno de Pollo Fit', 4.00, '150g arroz + 130g pollo + ensalada', 'animal'),
('Menestra Power con Pollo', 4.00, 'Frejol + arroz + pollo + ensalada', 'animal'),
('Arroz Relleno de Soya', 4.00, 'Arroz + carne de soya + ensalada', 'vegetal'),
('Menestra Power Vegetal', 4.00, 'Frejol + arroz + ensalada', 'vegetal');

SELECT * FROM productos;