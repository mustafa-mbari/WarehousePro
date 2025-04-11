import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Loader2,
  Search,
  FilterX,
  Download,
  AlertTriangle,
  Calendar,
  ArrowDownCircle,
  ArrowUpCircle,
  RefreshCw,
  Plus,
} from "lucide-react";
import { Link } from "wouter";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";

interface StockMovement {
  id: number;
  productId: number;
  warehouseId: string;
  quantity: string;
  direction: "IN" | "OUT";
  referenceType: string;
  referenceId: string;
  notes: string;
  createdAt: string;
  createdBy: number;
  product?: {
    name: string;
    sku: string;
  };
  warehouse?: {
    name: string;
  };
  createdByUser?: {
    firstName: string;
    lastName: string;
    username: string;
  };
}

export default function InventoryMovements() {
  const [searchTerm, setSearchTerm] = useState("");
  const [directionFilter, setDirectionFilter] = useState("_all");
  const [warehouseFilter, setWarehouseFilter] = useState("_all");
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const { toast } = useToast();

  // Form states for creating new movement
  const [newMovement, setNewMovement] = useState({
    productId: "",
    warehouseId: "",
    quantity: "",
    direction: "IN",
    referenceType: "ADJUSTMENT",
    referenceId: "",
    notes: "",
  });

  // Fetch stock movements
  const { data: movementsData, isLoading, error } = useQuery({
    queryKey: ["/api/stock-movements/recent"],
  });

  // Fetch products for dropdown
  const { data: productsData } = useQuery({
    queryKey: ["/api/products"],
  });

  // Fetch warehouses for dropdown
  const { data: warehousesData } = useQuery({
    queryKey: ["/api/warehouses"],
  });

  const handleCreateMovement = async () => {
    try {
      await apiRequest("POST", "/api/stock-movements", {
        ...newMovement,
        productId: parseInt(newMovement.productId),
        quantity: parseFloat(newMovement.quantity),
      });
      
      // Close dialog and reset form
      setIsCreateDialogOpen(false);
      setNewMovement({
        productId: "",
        warehouseId: "",
        quantity: "",
        direction: "IN",
        referenceType: "ADJUSTMENT",
        referenceId: "",
        notes: "",
      });
      
      // Refresh data
      queryClient.invalidateQueries({ queryKey: ["/api/stock-movements/recent"] });
      queryClient.invalidateQueries({ queryKey: ["/api/inventory"] });
      
      toast({
        title: "Success",
        description: "Stock movement created successfully",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to create stock movement",
        variant: "destructive",
      });
    }
  };

  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-96">
          <Loader2 className="h-8 w-8 animate-spin text-primary-500" />
        </div>
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout>
        <Card className="border-red-200 dark:border-red-800">
          <CardHeader>
            <div className="flex items-center">
              <AlertTriangle className="h-5 w-5 text-red-500 mr-2" />
              <CardTitle>Error Loading Stock Movements</CardTitle>
            </div>
            <CardDescription>
              There was a problem loading stock movement data.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p>Please try refreshing the page or contact support if the problem persists.</p>
            <Button variant="outline" className="mt-4" onClick={() => window.location.reload()}>
              Refresh Page
            </Button>
          </CardContent>
        </Card>
      </DashboardLayout>
    );
  }

  // Filter movements based on search term and filters
  const filteredMovements = movementsData?.filter((movement: StockMovement) => {
    const matchesSearch =
      !searchTerm ||
      movement.product?.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      movement.product?.sku?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      movement.referenceId?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesDirection = directionFilter === "_all" || movement.direction === directionFilter;
    const matchesWarehouse = warehouseFilter === "_all" || movement.warehouseId === warehouseFilter;

    return matchesSearch && matchesDirection && matchesWarehouse;
  });

  const resetFilters = () => {
    setSearchTerm("");
    setDirectionFilter("_all");
    setWarehouseFilter("_all");
  };

  return (
    <DashboardLayout>
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Stock Movements</h1>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
            Track and manage all stock movements across your warehouses
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="mr-2 h-4 w-4" /> New Movement
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Create Stock Movement</DialogTitle>
                <DialogDescription>
                  Record a new stock movement for a product.
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid grid-cols-4 items-center gap-4">
                  <label htmlFor="productId" className="text-right">
                    Product
                  </label>
                  <Select
                    value={newMovement.productId}
                    onValueChange={(value) => setNewMovement({...newMovement, productId: value})}
                  >
                    <SelectTrigger className="col-span-3">
                      <SelectValue placeholder="Select a product" />
                    </SelectTrigger>
                    <SelectContent>
                      {productsData?.map((product: any) => (
                        <SelectItem key={product.id} value={product.id.toString()}>
                          {product.name} ({product.sku})
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid grid-cols-4 items-center gap-4">
                  <label htmlFor="warehouseId" className="text-right">
                    Warehouse
                  </label>
                  <Select
                    value={newMovement.warehouseId}
                    onValueChange={(value) => setNewMovement({...newMovement, warehouseId: value})}
                  >
                    <SelectTrigger className="col-span-3">
                      <SelectValue placeholder="Select a warehouse" />
                    </SelectTrigger>
                    <SelectContent>
                      {warehousesData?.map((warehouse: any) => (
                        <SelectItem key={warehouse.id} value={warehouse.id}>
                          {warehouse.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid grid-cols-4 items-center gap-4">
                  <label htmlFor="quantity" className="text-right">
                    Quantity
                  </label>
                  <Input
                    id="quantity"
                    type="number"
                    step="0.01"
                    value={newMovement.quantity}
                    onChange={(e) => setNewMovement({...newMovement, quantity: e.target.value})}
                    className="col-span-3"
                  />
                </div>
                <div className="grid grid-cols-4 items-center gap-4">
                  <label htmlFor="direction" className="text-right">
                    Direction
                  </label>
                  <Select
                    value={newMovement.direction}
                    onValueChange={(value) => setNewMovement({...newMovement, direction: value as "IN" | "OUT"})}
                  >
                    <SelectTrigger className="col-span-3">
                      <SelectValue placeholder="Select direction" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="IN">IN (Receiving)</SelectItem>
                      <SelectItem value="OUT">OUT (Shipping)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid grid-cols-4 items-center gap-4">
                  <label htmlFor="referenceId" className="text-right">
                    Reference #
                  </label>
                  <Input
                    id="referenceId"
                    value={newMovement.referenceId}
                    onChange={(e) => setNewMovement({...newMovement, referenceId: e.target.value})}
                    className="col-span-3"
                  />
                </div>
                <div className="grid grid-cols-4 items-center gap-4">
                  <label htmlFor="notes" className="text-right">
                    Notes
                  </label>
                  <Input
                    id="notes"
                    value={newMovement.notes}
                    onChange={(e) => setNewMovement({...newMovement, notes: e.target.value})}
                    className="col-span-3"
                  />
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                  Cancel
                </Button>
                <Button onClick={handleCreateMovement}>Save Movement</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" /> Export
          </Button>
        </div>
      </div>

      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Stock Movement History</CardTitle>
          <CardDescription>
            View all stock movements including receipts, shipments, and adjustments
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="mb-4 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
            <div className="relative w-full sm:w-1/3">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500 dark:text-gray-400" />
              <Input
                placeholder="Search products, SKUs, reference #..."
                className="pl-8"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <Select value={directionFilter} onValueChange={setDirectionFilter}>
              <SelectTrigger className="w-full sm:w-1/5">
                <SelectValue placeholder="All Movements" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="_all">All Movements</SelectItem>
                <SelectItem value="IN">Incoming</SelectItem>
                <SelectItem value="OUT">Outgoing</SelectItem>
              </SelectContent>
            </Select>
            <Select value={warehouseFilter} onValueChange={setWarehouseFilter}>
              <SelectTrigger className="w-full sm:w-1/4">
                <SelectValue placeholder="All Warehouses" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="_all">All Warehouses</SelectItem>
                {warehousesData?.map((warehouse: any) => (
                  <SelectItem key={warehouse.id} value={warehouse.id}>
                    {warehouse.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {(searchTerm || directionFilter || warehouseFilter) && (
              <Button variant="outline" onClick={resetFilters}>
                <FilterX className="mr-2 h-4 w-4" /> Clear Filters
              </Button>
            )}
          </div>

          <div className="border rounded-md">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date & Time</TableHead>
                  <TableHead>Direction</TableHead>
                  <TableHead>Product</TableHead>
                  <TableHead>Warehouse</TableHead>
                  <TableHead className="text-right">Quantity</TableHead>
                  <TableHead>Reference</TableHead>
                  <TableHead>Created By</TableHead>
                  <TableHead>Notes</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredMovements?.length > 0 ? (
                  filteredMovements.map((movement: StockMovement) => (
                    <TableRow key={movement.id}>
                      <TableCell>
                        <div className="flex items-center">
                          <Calendar className="mr-2 h-4 w-4 text-muted-foreground" />
                          {new Date(movement.createdAt).toLocaleString()}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center">
                          {movement.direction === "IN" ? (
                            <ArrowDownCircle className="mr-2 h-4 w-4 text-green-500" />
                          ) : (
                            <ArrowUpCircle className="mr-2 h-4 w-4 text-red-500" />
                          )}
                          <span className={movement.direction === "IN" ? "text-green-600" : "text-red-600"}>
                            {movement.direction}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell>
                        {movement.product?.name || `Product #${movement.productId}`}
                        <div className="text-xs text-muted-foreground">
                          {movement.product?.sku || ""}
                        </div>
                      </TableCell>
                      <TableCell>
                        {movement.warehouse?.name || `Warehouse #${movement.warehouseId}`}
                      </TableCell>
                      <TableCell className="text-right font-medium">
                        {parseFloat(movement.quantity).toFixed(2)}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center">
                          <span className="text-xs px-2 py-1 rounded-full bg-gray-100 dark:bg-gray-800">
                            {movement.referenceType}
                          </span>
                          <span className="ml-2">{movement.referenceId || "—"}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        {movement.createdByUser ? 
                          `${movement.createdByUser.firstName} ${movement.createdByUser.lastName}` : 
                          `User #${movement.createdBy}`}
                      </TableCell>
                      <TableCell className="max-w-xs truncate">
                        {movement.notes || "—"}
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center py-6 text-muted-foreground">
                      No stock movements found
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>

          <div className="flex items-center justify-end space-x-2 py-4">
            <div className="text-sm text-muted-foreground">
              {filteredMovements?.length || 0} movement(s) found
            </div>
          </div>
        </CardContent>
      </Card>
    </DashboardLayout>
  );
}
