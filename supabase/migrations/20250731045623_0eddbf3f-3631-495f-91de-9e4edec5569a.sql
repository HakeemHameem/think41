-- Create products table
CREATE TABLE public.products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category TEXT,
  stock_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create cart items table
CREATE TABLE public.cart_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Enable Row Level Security
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- Products policies (public read, no write for now)
CREATE POLICY "Everyone can view products" 
ON public.products 
FOR SELECT 
USING (true);

-- Cart policies (users can only see and modify their own cart)
CREATE POLICY "Users can view their own cart items" 
ON public.cart_items 
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cart items" 
ON public.cart_items 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cart items" 
ON public.cart_items 
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cart items" 
ON public.cart_items 
FOR DELETE 
USING (auth.uid() = user_id);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_cart_items_updated_at
  BEFORE UPDATE ON public.cart_items
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Insert sample products with placeholder images
INSERT INTO public.products (name, description, price, image_url, category, stock_quantity) VALUES
('Wireless Headphones', 'Premium noise-canceling wireless headphones with 30-hour battery life', 199.99, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop', 'Electronics', 25),
('Smart Watch', 'Fitness tracking smartwatch with heart rate monitor and GPS', 299.99, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&h=500&fit=crop', 'Electronics', 15),
('Leather Jacket', 'Genuine leather jacket with classic biker design', 249.99, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&h=500&fit=crop', 'Fashion', 10),
('Running Shoes', 'Lightweight running shoes with advanced cushioning technology', 149.99, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&h=500&fit=crop', 'Sports', 30),
('Coffee Maker', 'Programmable drip coffee maker with thermal carafe', 89.99, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&h=500&fit=crop', 'Home', 20),
('Yoga Mat', 'Non-slip premium yoga mat with alignment lines', 39.99, 'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=500&h=500&fit=crop', 'Sports', 50),
('Smartphone Case', 'Protective case with wireless charging compatibility', 29.99, 'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=500&h=500&fit=crop', 'Electronics', 100),
('Sunglasses', 'UV protection sunglasses with polarized lenses', 79.99, 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500&h=500&fit=crop', 'Fashion', 40),
('Backpack', 'Water-resistant travel backpack with laptop compartment', 119.99, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&h=500&fit=crop', 'Travel', 25),
('Bluetooth Speaker', 'Portable waterproof speaker with 360-degree sound', 69.99, 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&h=500&fit=crop', 'Electronics', 35);

-- Add more products to reach 50+ items
INSERT INTO public.products (name, description, price, image_url, category, stock_quantity) VALUES
('Gaming Mouse', 'High-precision gaming mouse with RGB lighting', 79.99, 'https://images.unsplash.com/photo-1527814050087-3793815479db?w=500&h=500&fit=crop', 'Electronics', 45),
('Desk Lamp', 'LED desk lamp with adjustable brightness and color temperature', 59.99, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop', 'Home', 30),
('Water Bottle', 'Insulated stainless steel water bottle', 24.99, 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500&h=500&fit=crop', 'Sports', 75),
('Notebook', 'Premium leather-bound notebook with dot grid pages', 19.99, 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&h=500&fit=crop', 'Office', 60),
('Wireless Charger', 'Fast wireless charging pad for smartphones', 34.99, 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=500&h=500&fit=crop', 'Electronics', 80),
('Perfume', 'Luxury fragrance with floral and woody notes', 89.99, 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=500&h=500&fit=crop', 'Beauty', 25),
('Camera Lens', 'Professional 50mm portrait lens', 399.99, 'https://images.unsplash.com/photo-1606986628253-51ece21d6dbc?w=500&h=500&fit=crop', 'Electronics', 12),
('Kitchen Knife', 'Professional chef knife with German steel', 129.99, 'https://images.unsplash.com/photo-1593618998160-e34014dea7a0?w=500&h=500&fit=crop', 'Kitchen', 18),
('Plant Pot', 'Ceramic plant pot with drainage holes', 15.99, 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500&h=500&fit=crop', 'Home', 90),
('Board Game', 'Strategic board game for 2-4 players', 49.99, 'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=500&h=500&fit=crop', 'Games', 22);