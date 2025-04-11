import type { Express } from "express";
import { createServer, type Server } from "http";
import { setupAuth } from "./auth";
import { storage } from "./storage";
import { ZodError } from "zod";
import { fromZodError } from "zod-validation-error";
import { 
  insertProductSchema, 
  insertProductCategorySchema,
  insertUnitOfMeasureSchema,
  insertInventorySchema,
  insertStockMovementSchema,
  insertOrderSchema,
  insertOrderItemSchema,
  insertWarehouseSchema
} from "@shared/schema";

// Middleware to check if user is authenticated
function isAuthenticated(req: any, res: any, next: any) {
  if (req.isAuthenticated()) {
    return next();
  }
  res.status(401).json({ message: "Unauthorized" });
}

export async function registerRoutes(app: Express): Promise<Server> {
  // Set up authentication
  setupAuth(app);

  // Dashboard data endpoints
  app.get("/api/dashboard/stats", isAuthenticated, async (req, res, next) => {
    try {
      const inventoryValue = await storage.getInventoryValue();
      const lowStockItems = await storage.getLowStockItems();
      const recentOrders = await storage.getRecentOrders(5);
      
      // Count active products
      const products = await storage.getAllProducts();
      const activeProducts = products.filter(p => p.isActive).length;
      
      // Count pending orders
      const pendingOrders = (await storage.getOrdersByStatus("PENDING")).length;
      
      res.json({
        inventoryValue,
        activeProducts,
        pendingOrders,
        lowStockItemsCount: lowStockItems.length,
        recentOrders,
        inventoryLevelsByCategory: await storage.getInventoryLevelsByCategory(),
        orderTrends: await storage.getOrderTrends(),
      });
    } catch (err) {
      next(err);
    }
  });
  
  app.get("/api/dashboard/activities", isAuthenticated, async (req, res, next) => {
    try {
      const recentStockMovements = await storage.getRecentStockMovements(10);
      res.json(recentStockMovements);
    } catch (err) {
      next(err);
    }
  });

  // Products endpoints
  app.get("/api/products", isAuthenticated, async (req, res, next) => {
    try {
      const query = req.query.q as string;
      let products;
      
      if (query) {
        products = await storage.searchProducts(query);
      } else {
        products = await storage.getAllProducts();
      }
      
      res.json(products);
    } catch (err) {
      next(err);
    }
  });
  
  app.get("/api/products/:id", isAuthenticated, async (req, res, next) => {
    try {
      const product = await storage.getProduct(parseInt(req.params.id));
      if (!product) {
        return res.status(404).json({ message: "Product not found" });
      }
      res.json(product);
    } catch (err) {
      next(err);
    }
  });
  
  app.post("/api/products", isAuthenticated, async (req, res, next) => {
    try {
      const validatedData = insertProductSchema.parse(req.body);
      const product = await storage.createProduct({
        ...validatedData,
        createdBy: req.user!.id,
      });
      res.status(201).json(product);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({ 
          message: "Validation failed", 
          errors: fromZodError(err).message 
        });
      }
      next(err);
    }
  });
  
  app.put("/api/products/:id", isAuthenticated, async (req, res, next) => {
    try {
      const id = parseInt(req.params.id);
      const existing = await storage.getProduct(id);
      
      if (!existing) {
        return res.status(404).json({ message: "Product not found" });
      }
      
      const updatedProduct = await storage.updateProduct(id, {
        ...req.body,
        updatedBy: req.user!.id
      });
      
      res.json(updatedProduct);
    } catch (err) {
      next(err);
    }
  });
  
  app.delete("/api/products/:id", isAuthenticated, async (req, res, next) => {
    try {
      const id = parseInt(req.params.id);
      const existing = await storage.getProduct(id);
      
      if (!existing) {
        return res.status(404).json({ message: "Product not found" });
      }
      
      await storage.updateProduct(id, {
        deletedBy: req.user!.id,
        deletedAt: new Date()
      });
      
      res.status(204).send();
    } catch (err) {
      next(err);
    }
  });
  
  // Product Categories endpoints
  app.get("/api/product-categories", isAuthenticated, async (req, res, next) => {
    try {
      const categories = await storage.getAllProductCategories();
      res.json(categories);
    } catch (err) {
      next(err);
    }
  });
  
  app.post("/api/product-categories", isAuthenticated, async (req, res, next) => {
    try {
      const validatedData = insertProductCategorySchema.parse(req.body);
      const category = await storage.createProductCategory({
        ...validatedData,
        createdBy: req.user!.id.toString(),
      });
      res.status(201).json(category);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({ 
          message: "Validation failed", 
          errors: fromZodError(err).message 
        });
      }
      next(err);
    }
  });
  
  // Units of Measure endpoints
  app.get("/api/units-of-measure", isAuthenticated, async (req, res, next) => {
    try {
      const units = await storage.getAllUnitsOfMeasure();
      res.json(units);
    } catch (err) {
      next(err);
    }
  });
  
  app.post("/api/units-of-measure", isAuthenticated, async (req, res, next) => {
    try {
      const validatedData = insertUnitOfMeasureSchema.parse(req.body);
      const unit = await storage.createUnitOfMeasure({
        ...validatedData,
        createdBy: req.user!.id.toString(),
      });
      res.status(201).json(unit);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({ 
          message: "Validation failed", 
          errors: fromZodError(err).message 
        });
      }
      next(err);
    }
  });
  
  // Inventory endpoints
  app.get("/api/inventory", isAuthenticated, async (req, res, next) => {
    try {
      const inventory = await storage.getAllInventory();
      res.json(inventory);
    } catch (err) {
      next(err);
    }
  });
  
  app.get("/api/inventory/product/:productId", isAuthenticated, async (req, res, next) => {
    try {
      const inventory = await storage.getInventoryByProduct(parseInt(req.params.productId));
      res.json(inventory);
    } catch (err) {
      next(err);
    }
  });
  
  app.get("/api/inventory/warehouse/:warehouseId", isAuthenticated, async (req, res, next) => {
    try {
      const inventory = await storage.getInventoryByWarehouse(req.params.warehouseId);
      res.json(inventory);
    } catch (err) {
      next(err);
    }
  });
  
  app.post("/api/inventory", isAuthenticated, async (req, res, next) => {
    try {
      const validatedData = insertInventorySchema.parse(req.body);
      const inventory = await storage.createInventory(validatedData);
      res.status(201).json(inventory);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({ 
          message: "Validation failed", 
          errors: fromZodError(err).message 
        });
      }
      next(err);
    }
  });
  
  // Stock Movements endpoints
  app.post("/api/stock-movements", isAuthenticated, async (req, res, next) => {
    try {
      const validatedData = insertStockMovementSchema.parse(req.body);
      const movement = await storage.createStockMovement({
        ...validatedData,
        createdBy: req.user!.id,
      });
      res.status(201).json(movement);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({ 
          message: "Validation failed", 
          errors: fromZodError(err).message 
        });
      }
      next(err);
    }
  });
  
  app.get("/api/stock-movements/recent", isAuthenticated, async (req, res, next) => {
    try {
      const limit = req.query.limit ? parseInt(req.query.limit as string) : 10;
      const movements = await storage.getRecentStockMovements(limit);
      res.json(movements);
    } catch (err) {
      next(err);
    }
  });
  
  // Orders endpoints
  app.get("/api/orders", isAuthenticated, async (req, res, next) => {
    try {
      const status = req.query.status as string;
      let orders;
      
      if (status) {
        orders = await storage.getOrdersByStatus(status);
      } else {
        orders = await storage.getAllOrders();
      }
      
      res.json(orders);
    } catch (err) {
      next(err);
    }
  });
  
  app.get("/api/orders/:id", isAuthenticated, async (req, res, next) => {
    try {
      const order = await storage.getOrder(parseInt(req.params.id));
      if (!order) {
        return res.status(404).json({ message: "Order not found" });
      }
      
      const items = await storage.getOrderItems(order.id);
      res.json({ ...order, items });
    } catch (err) {
      next(err);
    }
  });
  
  app.post("/api/orders", isAuthenticated, async (req, res, next) => {
    try {
      const validatedData = insertOrderSchema.parse(req.body);
      const orderItems = req.body.items || [];
      
      const order = await storage.createOrder({
        ...validatedData,
        createdBy: req.user!.id,
      });
      
      // Create order items
      for (const item of orderItems) {
        await storage.createOrderItem({
          ...item,
          orderId: order.id,
        });
      }
      
      res.status(201).json(order);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({ 
          message: "Validation failed", 
          errors: fromZodError(err).message 
        });
      }
      next(err);
    }
  });
  
  // Users endpoints
  app.get("/api/users", isAuthenticated, async (req, res, next) => {
    try {
      const users = await storage.getAllUsers();
      // Remove password field from response
      const safeUsers = users.map(({ password, ...user }) => user);
      res.json(safeUsers);
    } catch (err) {
      next(err);
    }
  });
  
  // Warehouses endpoints
  app.get("/api/warehouses", isAuthenticated, async (req, res, next) => {
    try {
      const warehouses = await storage.getAllWarehouses();
      res.json(warehouses);
    } catch (err) {
      next(err);
    }
  });
  
  app.post("/api/warehouses", isAuthenticated, async (req, res, next) => {
    try {
      const warehouseData = insertWarehouseSchema.parse(req.body);
      const newWarehouse = await storage.createWarehouse(warehouseData);
      res.status(201).json(newWarehouse);
    } catch (err) {
      next(err);
    }
  });
  
  app.put("/api/warehouses/:id", isAuthenticated, async (req, res, next) => {
    try {
      const id = req.params.id;
      const existing = await storage.getWarehouse(id);
      
      if (!existing) {
        return res.status(404).json({ message: "Warehouse not found" });
      }
      
      const updatedWarehouse = await storage.updateWarehouse(id, req.body);
      res.json(updatedWarehouse);
    } catch (err) {
      next(err);
    }
  });
  
  app.delete("/api/warehouses/:id", isAuthenticated, async (req, res, next) => {
    try {
      const id = req.params.id;
      const existing = await storage.getWarehouse(id);
      
      if (!existing) {
        return res.status(404).json({ message: "Warehouse not found" });
      }
      
      const result = await storage.deleteWarehouse(id);
      if (result) {
        res.status(204).send();
      } else {
        res.status(500).json({ message: "Could not delete warehouse" });
      }
    } catch (err) {
      next(err);
    }
  });

  const httpServer = createServer(app);
  return httpServer;
}
