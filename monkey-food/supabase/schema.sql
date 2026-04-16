-- Monkey Food Fitness - Schema Supabase
-- Adaptado de Las Empanadas de Susi (GinoRobla)

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de productos (bowls)
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 4.00,
  category TEXT, -- 'animal' o 'vegetal'
  protein_grams TEXT, -- '35-40g', '30-35g', etc.
  emoji TEXT, -- 🍗, 🥩, 🫘
  available BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de pedidos
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customers(id),
  customer_name TEXT,
  customer_phone TEXT,
  customer_address TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'delivered', 'cancelled')),
  total DECIMAL(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Items del pedido
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL
);

-- Habilitar Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE order_items;

-- Insertar bowls iniciales
INSERT INTO products (name, description, price, category, protein_grams, emoji) VALUES
('Pollo Power ⭐', 'Arroz relleno (arveja + zanahoria + refrito), pollo desmechado', 4.00, 'animal', '35-40g', '🍗'),
('Seco Fit de Pollo', 'Pollo con tomate y pimiento, arroz + ensalada', 4.00, 'animal', '30-35g', '🍗'),
('Seco Fit de Carne', 'Carne guisada con tomate y pimiento, arroz + ensalada', 4.00, 'animal', '30-35g', '🥩'),
('Soya Power', 'Arroz relleno (arveja + zanahoria + refrito), carne de soya', 4.00, 'vegetal', '30-35g', '🫘'),
('Seco Vegetal', 'Soya con tomate y pimiento, arroz + ensalada', 4.00, 'vegetal', '28-32g', '🫘');

-- Políticas RLS (opcional - para desarrollo sin auth)
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Policies públicas para desarrollo
CREATE POLICY "Public access customers" ON customers FOR ALL USING (true);
CREATE POLICY "Public access products" ON products FOR ALL USING (true);
CREATE POLICY "Public access orders" ON orders FOR ALL USING (true);
CREATE POLICY "Public access order_items" ON order_items FOR ALL USING (true);