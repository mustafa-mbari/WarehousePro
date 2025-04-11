import { Switch, Route } from "wouter";
import { Toaster } from "@/components/ui/toaster";
import NotFound from "@/pages/not-found";
import Dashboard from "@/pages/dashboard";
import InventoryPage from "@/pages/inventory";
import InventoryMovements from "@/pages/inventory/movements";
import InventoryAdjustments from "@/pages/inventory/adjustments";
import ProductsPage from "@/pages/products";
import ProductCategoriesPage from "@/pages/products/categories";
import UnitsOfMeasurePage from "@/pages/products/uom";
import OrdersPage from "@/pages/orders";
import WarehousesPage from "@/pages/warehouses";
import UsersPage from "@/pages/users";
import SettingsPage from "@/pages/settings";
import AuthPage from "@/pages/auth-page";
import { ProtectedRoute } from "./lib/protected-route";
import { AuthProvider } from "./hooks/use-auth";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "./lib/queryClient";

function Router() {
  return (
    <Switch>
      <ProtectedRoute path="/" component={Dashboard} />
      <ProtectedRoute path="/inventory" component={InventoryPage} />
      <ProtectedRoute path="/inventory/movements" component={InventoryMovements} />
      <ProtectedRoute path="/inventory/adjustments" component={InventoryAdjustments} />
      <ProtectedRoute path="/products" component={ProductsPage} />
      <ProtectedRoute path="/products/categories" component={ProductCategoriesPage} />
      <ProtectedRoute path="/products/uom" component={UnitsOfMeasurePage} />
      <ProtectedRoute path="/orders" component={OrdersPage} />
      <ProtectedRoute path="/warehouses" component={WarehousesPage} />
      <ProtectedRoute path="/users" component={UsersPage} />
      <ProtectedRoute path="/settings" component={SettingsPage} />
      <Route path="/auth" component={AuthPage} />
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <Router />
        <Toaster />
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;
