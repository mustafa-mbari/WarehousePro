import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Loader2,
  PlusCircle,
  MinusCircle,
  Trash2,
  Save,
  AlertTriangle,
  SearchIcon,
  XCircle,
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { useLocation } from "wouter";

// Define schema for form validation
const inventoryAdjustmentSchema = z.object({
  warehouseId: z.string().min(1, "Warehouse is required"),
  reason: z.string().min(1, "Reason is required"),
  notes: z.string().optional(),
  items: z.array(
    z.object({
      productId: z.number().min(1, "Product is required"),
      quantity: z.string().refine((val) => {
        const num = parseFloat(val);
        return !isNaN(num) && num !== 0;
      }, "Quantity must be a non-zero number"),
      direction: z.enum(["IN", "OUT"]),
    })
  ).min(1, "At least one product is required")
});

type InventoryAdjustmentFormValues = z.infer<typeof inventoryAdjustmentSchema>;

export default function InventoryAdjustments() {
  const [, navigate] = useLocation();
  const { toast } = useToast();
  const [searchTerm, setSearchTerm] = useState("");
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);

  // Fetch warehouses
  const { data: warehousesData, isLoading: warehousesLoading } = useQuery({
    queryKey: ["/api/warehouses"],
  });

  // Define form with react-hook-form and zod validation
  const form = useForm<InventoryAdjustmentFormValues>({
    resolver: zodResolver(inventoryAdjustmentSchema),
    defaultValues: {
      warehouseId: "",
      reason: "PHYSICAL_COUNT",
      notes: "",
      items: []
    }
  });

  // Handle product search
  const handleSearch = async () => {
    if (!searchTerm.trim()) return;
    
    setIsSearching(true);
    try {
      const res = await fetch(`/api/products?q=${encodeURIComponent(searchTerm)}`);
      if (!res.ok) throw new Error("Failed to search products");
      
      const data = await res.json();
      setSearchResults(data);
    } catch (error) {
      toast({
        title: "Search Error",
        description: "Failed to search products. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSearching(false);
    }
  };

  // Add product to form
  const addProduct = (product: any) => {
    const items = form.getValues().items || [];
    
    // Check if product already exists in the list
    const existingIndex = items.findIndex(item => item.productId === product.id);
    
    if (existingIndex >= 0) {
      toast({
        title: "Product already added",
        description: "This product is already in the adjustment list.",
        variant: "destructive",
      });
      return;
    }
    
    // Add new product to the list
    form.setValue("items", [
      ...items,
      {
        productId: product.id,
        productName: product.name,
        productSku: product.sku,
        quantity: "1",
        direction: "IN"
      }
    ]);
    
    // Clear search
    setSearchTerm("");
    setSearchResults([]);
  };

  // Remove product from form
  const removeProduct = (index: number) => {
    const items = form.getValues().items;
    form.setValue("items", items.filter((_, i) => i !== index));
  };

  // Toggle direction (IN/OUT)
  const toggleDirection = (index: number) => {
    const items = form.getValues().items;
    const currentDirection = items[index].direction;
    const newDirection = currentDirection === "IN" ? "OUT" : "IN";
    
    const updatedItems = [...items];
    updatedItems[index].direction = newDirection;
    
    form.setValue("items", updatedItems);
  };

  // Update quantity
  const updateQuantity = (index: number, value: string) => {
    const items = form.getValues().items;
    
    const updatedItems = [...items];
    updatedItems[index].quantity = value;
    
    form.setValue("items", updatedItems);
  };

  // Submit form
  const onSubmit = async (data: InventoryAdjustmentFormValues) => {
    try {
      // Create stock movements for each item
      const movements = data.items.map(item => ({
        productId: item.productId,
        warehouseId: data.warehouseId,
        quantity: Math.abs(parseFloat(item.quantity)),
        direction: item.direction,
        referenceType: "ADJUSTMENT",
        referenceId: new Date().toISOString().slice(0, 10),
        notes: `${data.reason}: ${data.notes}`
      }));
      
      // Submit each movement
      for (const movement of movements) {
        await apiRequest("POST", "/api/stock-movements", movement);
      }
      
      // Show success message
      toast({
        title: "Adjustment Complete",
        description: `Successfully adjusted inventory for ${movements.length} product(s).`,
      });
      
      // Invalidate queries to refresh data
      queryClient.invalidateQueries({ queryKey: ["/api/inventory"] });
      queryClient.invalidateQueries({ queryKey: ["/api/stock-movements/recent"] });
      
      // Redirect to inventory page
      navigate("/inventory");
    } catch (error) {
      toast({
        title: "Adjustment Failed",
        description: "There was an error processing the inventory adjustment.",
        variant: "destructive",
      });
    }
  };

  if (warehousesLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-96">
          <Loader2 className="h-8 w-8 animate-spin text-primary-500" />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Inventory Adjustment</h1>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
            Create a new inventory adjustment to correct stock levels
          </p>
        </div>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)}>
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Adjustment Details</CardTitle>
                <CardDescription>
                  Provide the general details for this inventory adjustment
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <FormField
                    control={form.control}
                    name="warehouseId"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Warehouse</FormLabel>
                        <Select
                          onValueChange={field.onChange}
                          defaultValue={field.value}
                        >
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Select a warehouse" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {warehousesData?.map((warehouse: any) => (
                              <SelectItem key={warehouse.id} value={warehouse.id}>
                                {warehouse.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormDescription>
                          Select the warehouse where the adjustment is being made
                        </FormDescription>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="reason"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Reason</FormLabel>
                        <Select
                          onValueChange={field.onChange}
                          defaultValue={field.value}
                        >
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Select reason for adjustment" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            <SelectItem value="PHYSICAL_COUNT">Physical Count</SelectItem>
                            <SelectItem value="DAMAGE">Damage/Loss</SelectItem>
                            <SelectItem value="EXPIRY">Expiration</SelectItem>
                            <SelectItem value="RETURN">Customer Return</SelectItem>
                            <SelectItem value="CORRECTION">System Correction</SelectItem>
                            <SelectItem value="OTHER">Other</SelectItem>
                          </SelectContent>
                        </Select>
                        <FormDescription>
                          Indicate why this adjustment is being made
                        </FormDescription>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="notes"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Notes</FormLabel>
                        <FormControl>
                          <Textarea
                            placeholder="Enter any additional details about this adjustment..."
                            className="resize-none"
                            {...field}
                          />
                        </FormControl>
                        <FormDescription>
                          These notes will be attached to the adjustment record
                        </FormDescription>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Add Products</CardTitle>
                <CardDescription>
                  Search for products to include in this adjustment
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex space-x-2">
                    <div className="relative flex-1">
                      <SearchIcon className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500 dark:text-gray-400" />
                      <Input
                        placeholder="Search by name, SKU or barcode..."
                        className="pl-8"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                      />
                    </div>
                    <Button type="button" onClick={handleSearch} disabled={isSearching || !searchTerm.trim()}>
                      {isSearching ? <Loader2 className="h-4 w-4 animate-spin" /> : "Search"}
                    </Button>
                  </div>

                  {searchResults.length > 0 && (
                    <Card>
                      <CardContent className="p-2">
                        <Table>
                          <TableHeader>
                            <TableRow>
                              <TableHead>Product</TableHead>
                              <TableHead>SKU</TableHead>
                              <TableHead>Actions</TableHead>
                            </TableRow>
                          </TableHeader>
                          <TableBody>
                            {searchResults.map((product) => (
                              <TableRow key={product.id}>
                                <TableCell>{product.name}</TableCell>
                                <TableCell>{product.sku}</TableCell>
                                <TableCell>
                                  <Button
                                    type="button"
                                    size="sm"
                                    variant="ghost"
                                    onClick={() => addProduct(product)}
                                  >
                                    <PlusCircle className="h-4 w-4 mr-1" /> Add
                                  </Button>
                                </TableCell>
                              </TableRow>
                            ))}
                          </TableBody>
                        </Table>
                      </CardContent>
                    </Card>
                  )}

                  <FormField
                    control={form.control}
                    name="items"
                    render={() => (
                      <FormItem>
                        <div className="rounded-md border">
                          <Table>
                            <TableHeader>
                              <TableRow>
                                <TableHead>Product</TableHead>
                                <TableHead>Direction</TableHead>
                                <TableHead>Quantity</TableHead>
                                <TableHead>Actions</TableHead>
                              </TableRow>
                            </TableHeader>
                            <TableBody>
                              {form.watch("items")?.length > 0 ? (
                                form.watch("items").map((item: any, index) => (
                                  <TableRow key={index}>
                                    <TableCell>
                                      {item.productName}
                                      <div className="text-xs text-muted-foreground">
                                        {item.productSku}
                                      </div>
                                    </TableCell>
                                    <TableCell>
                                      <Button
                                        type="button"
                                        variant={item.direction === "IN" ? "outline" : "destructive"}
                                        size="sm"
                                        onClick={() => toggleDirection(index)}
                                      >
                                        {item.direction === "IN" ? (
                                          <PlusCircle className="h-4 w-4 mr-1" />
                                        ) : (
                                          <MinusCircle className="h-4 w-4 mr-1" />
                                        )}
                                        {item.direction}
                                      </Button>
                                    </TableCell>
                                    <TableCell>
                                      <Input
                                        type="number"
                                        min="0.01"
                                        step="0.01"
                                        value={item.quantity}
                                        onChange={(e) => updateQuantity(index, e.target.value)}
                                        className="w-24"
                                      />
                                    </TableCell>
                                    <TableCell>
                                      <Button
                                        type="button"
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => removeProduct(index)}
                                      >
                                        <Trash2 className="h-4 w-4 text-red-500" />
                                      </Button>
                                    </TableCell>
                                  </TableRow>
                                ))
                              ) : (
                                <TableRow>
                                  <TableCell colSpan={4} className="text-center py-4 text-muted-foreground">
                                    No products added yet
                                  </TableCell>
                                </TableRow>
                              )}
                            </TableBody>
                          </Table>
                        </div>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              </CardContent>
              <CardFooter className="flex justify-between">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate("/inventory")}
                >
                  <XCircle className="h-4 w-4 mr-2" />
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={form.watch("items")?.length === 0}
                >
                  <Save className="h-4 w-4 mr-2" />
                  Save Adjustment
                </Button>
              </CardFooter>
            </Card>
          </div>
        </form>
      </Form>
    </DashboardLayout>
  );
}
