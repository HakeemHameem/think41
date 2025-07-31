import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { ShoppingCart, Minus, Plus } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/hooks/useAuth';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  image_url: string;
  category: string;
  stock_quantity: number;
}

interface ProductCardProps {
  product: Product;
  cartQuantity?: number;
  onCartUpdate: () => void;
}

export const ProductCard = ({ product, cartQuantity = 0, onCartUpdate }: ProductCardProps) => {
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();
  const { user } = useAuth();

  const addToCart = async () => {
    if (!user) {
      toast({
        title: "Please sign in",
        description: "You need to be logged in to add items to cart",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);
    try {
      const { error } = await supabase
        .from('cart_items')
        .upsert({
          user_id: user.id,
          product_id: product.id,
          quantity: cartQuantity + 1,
        });

      if (error) throw error;

      toast({
        title: "Added to cart",
        description: `${product.name} has been added to your cart`,
      });
      onCartUpdate();
    } catch (error) {
      console.error('Error adding to cart:', error);
      toast({
        title: "Error",
        description: "Failed to add item to cart",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const updateQuantity = async (newQuantity: number) => {
    if (!user) return;

    setLoading(true);
    try {
      if (newQuantity === 0) {
        const { error } = await supabase
          .from('cart_items')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', product.id);

        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('cart_items')
          .update({ quantity: newQuantity })
          .eq('user_id', user.id)
          .eq('product_id', product.id);

        if (error) throw error;
      }

      onCartUpdate();
    } catch (error) {
      console.error('Error updating cart:', error);
      toast({
        title: "Error",
        description: "Failed to update cart",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="group overflow-hidden hover:shadow-lg transition-all duration-300 hover-scale">
      <div className="relative overflow-hidden">
        <img
          src={product.image_url}
          alt={product.name}
          className="w-full h-64 object-cover transition-transform duration-300 group-hover:scale-105"
        />
        <Badge className="absolute top-3 right-3 bg-primary/90 text-primary-foreground">
          {product.category}
        </Badge>
        {product.stock_quantity < 10 && (
          <Badge className="absolute top-3 left-3 bg-destructive/90 text-destructive-foreground">
            Only {product.stock_quantity} left
          </Badge>
        )}
      </div>
      
      <CardContent className="p-6">
        <h3 className="font-semibold text-lg mb-2 text-foreground group-hover:text-primary transition-colors">
          {product.name}
        </h3>
        <p className="text-muted-foreground text-sm mb-4 line-clamp-2">
          {product.description}
        </p>
        
        <div className="flex items-center justify-between">
          <span className="text-2xl font-bold text-primary">
            ${product.price}
          </span>
          
          {cartQuantity === 0 ? (
            <Button 
              onClick={addToCart} 
              disabled={loading || product.stock_quantity === 0}
              className="flex items-center gap-2"
            >
              <ShoppingCart className="h-4 w-4" />
              Add to Cart
            </Button>
          ) : (
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="icon"
                onClick={() => updateQuantity(cartQuantity - 1)}
                disabled={loading}
              >
                <Minus className="h-4 w-4" />
              </Button>
              <span className="font-medium w-8 text-center">{cartQuantity}</span>
              <Button
                variant="outline"
                size="icon"
                onClick={() => updateQuantity(cartQuantity + 1)}
                disabled={loading || cartQuantity >= product.stock_quantity}
              >
                <Plus className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};