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
  Loader2,
  PackagePlus,
  Search,
  FilterX,
  Download,
  AlertTriangle,
} from "lucide-react";
import { Link } from "wouter";

// Define interface for inventory with its joined product data
interface InventoryItem {
  id: number;
  productId: number;
  warehouseId: string;
  quantity: string;
  reservedQuantity: string;
  location: string;
  lastCountDate: string;
  product?: {
    id: number;
    name: string;
    sku: string;
    barcode: string;
    categoryId: number;
    category?: {
      name: string;
    };
  };
  warehouse?: {
    id: string;
    name: string;
  };
}

export default function InventoryPage() {
  const [searchTerm, setSearchTerm] = useState("");
  const [warehouseFilter, setWarehouseFilter] = useState("_all");

  // Fetch inventory data
  const { data: inventoryData, isLoading, error } = useQuery({
    queryKey: ["/api/inventory"],
  });

  // Fetch warehouses for filter
  const { data: warehousesData } = useQuery({
    queryKey: ["/api/warehouses"],
  });

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
              <CardTitle>Error Loading Inventory</CardTitle>
            </div>
            <CardDescription>
              There was a problem loading inventory data.
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

  // Filter inventory based on search term and warehouse filter
  const filteredInventory = inventoryData?.filter((item: InventoryItem) => {
    const matchesSearch =
      !searchTerm ||
      item.product?.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.product?.sku.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.location?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesWarehouse = warehouseFilter === "_all" || item.warehouseId === warehouseFilter;

    return matchesSearch && matchesWarehouse;
  });

  const resetFilters = () => {
    setSearchTerm("");
    setWarehouseFilter("_all");
  };

  return (
    <DashboardLayout>
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Inventory</h1>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
            Manage your stock levels and inventory across all warehouses
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
          <Button asChild>
            <Link href="/inventory/adjustments">
              <PackagePlus className="mr-2 h-4 w-4" /> New Adjustment
            </Link>
          </Button>
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" /> Export
          </Button>
        </div>
      </div>

      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Inventory Overview</CardTitle>
          <CardDescription>
            View and manage inventory across all warehouses
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="mb-4 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
            <div className="relative w-full sm:w-1/3">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500 dark:text-gray-400" />
              <Input
                placeholder="Search products, SKUs, locations..."
                className="pl-8"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
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
            {(searchTerm || warehouseFilter) && (
              <Button variant="outline" onClick={resetFilters}>
                <FilterX className="mr-2 h-4 w-4" /> Clear Filters
              </Button>
            )}
          </div>

          <div className="border rounded-md">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product</TableHead>
                  <TableHead>SKU</TableHead>
                  <TableHead>Warehouse</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead className="text-right">Available</TableHead>
                  <TableHead className="text-right">Reserved</TableHead>
                  <TableHead className="text-right">Total</TableHead>
                  <TableHead>Last Counted</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredInventory?.length > 0 ? (
                  filteredInventory.map((item: InventoryItem) => {
                    const available = parseFloat(item.quantity) - parseFloat(item.reservedQuantity);
                    return (
                      <TableRow key={item.id}>
                        <TableCell className="font-medium">
                          {item.product?.name || `Product #${item.productId}`}
                        </TableCell>
                        <TableCell>
                          {item.product?.sku || "N/A"}
                        </TableCell>
                        <TableCell>
                          {item.warehouse?.name || `Warehouse #${item.warehouseId}`}
                        </TableCell>
                        <TableCell>
                          {item.location || "—"}
                        </TableCell>
                        <TableCell className="text-right">
                          {available.toFixed(2)}
                        </TableCell>
                        <TableCell className="text-right">
                          {parseFloat(item.reservedQuantity).toFixed(2)}
                        </TableCell>
                        <TableCell className="text-right">
                          {parseFloat(item.quantity).toFixed(2)}
                        </TableCell>
                        <TableCell>
                          {item.lastCountDate
                            ? new Date(item.lastCountDate).toLocaleDateString()
                            : "—"}
                        </TableCell>
                      </TableRow>
                    );
                  })
                ) : (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center py-6 text-muted-foreground">
                      No inventory records found
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>

          <div className="flex items-center justify-end space-x-2 py-4">
            <div className="text-sm text-muted-foreground">
              {filteredInventory?.length || 0} items(s) found
            </div>
          </div>
        </CardContent>
      </Card>
    </DashboardLayout>
  );
}
