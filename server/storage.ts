import { 
  users, type User, type InsertUser,
  products, type Product, type InsertProduct,
  productCategories, type ProductCategory, type InsertProductCategory,
  unitsOfMeasure, type UnitOfMeasure, type InsertUnitOfMeasure,
  inventory, type Inventory, type InsertInventory,
  stockMovements, type StockMovement, type InsertStockMovement,
  orders, type Order, type InsertOrder,
  orderItems, type OrderItem, type InsertOrderItem,
  warehouses, type Warehouse, type InsertWarehouse,
  classTypes, type ClassType,
  tuOrientationTypes, type TuOrientationType
} from "@shared/schema";
import { db, pool } from "./db";
import { eq, like, and, isNull, desc, sql, not } from "drizzle-orm";
import session from "express-session";
import connectPg from "connect-pg-simple";

const PostgresSessionStore = connectPg(session);

export interface IStorage {
  // Users
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  updateUser(id: number, user: Partial<User>): Promise<User | undefined>;
  deleteUser(id: number): Promise<boolean>;
  getAllUsers(): Promise<User[]>;

  // Products
  getProduct(id: number): Promise<Product | undefined>;
  getProductBySku(sku: string): Promise<Product | undefined>;
  createProduct(product: InsertProduct): Promise<Product>;
  updateProduct(id: number, product: Partial<Product>): Promise<Product | undefined>;
  deleteProduct(id: number): Promise<boolean>;
  getAllProducts(): Promise<Product[]>;
  searchProducts(query: string): Promise<Product[]>;

  // Product Categories
  getProductCategory(id: number): Promise<ProductCategory | undefined>;
  createProductCategory(category: InsertProductCategory): Promise<ProductCategory>;
  updateProductCategory(id: number, category: Partial<ProductCategory>): Promise<ProductCategory | undefined>;
  deleteProductCategory(id: number): Promise<boolean>;
  getAllProductCategories(): Promise<ProductCategory[]>;

  // Units of Measure
  getUnitOfMeasure(id: string): Promise<UnitOfMeasure | undefined>;
  createUnitOfMeasure(uom: InsertUnitOfMeasure): Promise<UnitOfMeasure>;
  updateUnitOfMeasure(id: string, uom: Partial<UnitOfMeasure>): Promise<UnitOfMeasure | undefined>;
  deleteUnitOfMeasure(id: string): Promise<boolean>;
  getAllUnitsOfMeasure(): Promise<UnitOfMeasure[]>;

  // Inventory
  getInventory(id: number): Promise<Inventory | undefined>;
  createInventory(inv: InsertInventory): Promise<Inventory>;
  updateInventory(id: number, inv: Partial<Inventory>): Promise<Inventory | undefined>;
  deleteInventory(id: number): Promise<boolean>;
  getInventoryByProduct(productId: number): Promise<Inventory[]>;
  getInventoryByWarehouse(warehouseId: string): Promise<Inventory[]>;
  getAllInventory(): Promise<Inventory[]>;

  // Stock Movements
  createStockMovement(movement: InsertStockMovement): Promise<StockMovement>;
  getStockMovementsByProduct(productId: number): Promise<StockMovement[]>;
  getStockMovementsByWarehouse(warehouseId: string): Promise<StockMovement[]>;
  getRecentStockMovements(limit?: number): Promise<StockMovement[]>;

  // Orders
  getOrder(id: number): Promise<Order | undefined>;
  createOrder(order: InsertOrder): Promise<Order>;
  updateOrder(id: number, order: Partial<Order>): Promise<Order | undefined>;
  deleteOrder(id: number): Promise<boolean>;
  getAllOrders(): Promise<Order[]>;
  getOrdersByStatus(status: string): Promise<Order[]>;
  getRecentOrders(limit?: number): Promise<Order[]>;

  // Order Items
  getOrderItems(orderId: number): Promise<OrderItem[]>;
  createOrderItem(item: InsertOrderItem): Promise<OrderItem>;
  updateOrderItem(id: number, item: Partial<OrderItem>): Promise<OrderItem | undefined>;
  deleteOrderItem(id: number): Promise<boolean>;

  // Warehouses
  getWarehouse(id: string): Promise<Warehouse | undefined>;
  getAllWarehouses(): Promise<Warehouse[]>;

  // Class Types
  getClassType(id: string): Promise<ClassType | undefined>;
  getAllClassTypes(): Promise<ClassType[]>;

  // Dashboard Data
  getInventoryValue(): Promise<number>;
  getLowStockItems(): Promise<{product: Product, inventory: Inventory}[]>;
  getInventoryLevelsByCategory(): Promise<{category: string, value: number}[]>;
  getOrderTrends(): Promise<{date: string, incoming: number, outgoing: number}[]>;

  // Session store
  sessionStore: any; // Using 'any' for session store type
}

export class DatabaseStorage implements IStorage {
  sessionStore: any; // Using 'any' type for sessionStore

  constructor() {
    this.sessionStore = new PostgresSessionStore({
      pool: pool,
      tableName: 'session',
      createTableIfMissing: true,
    });
  }

  // Users
  async getUser(id: number): Promise<User | undefined> {
    const [user] = await db
      .select()
      .from(users)
      .where(and(eq(users.id, id), isNull(users.deletedAt)))
      .limit(1);
    return user;
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    const [user] = await db
      .select()
      .from(users)
      .where(and(eq(users.username, username), isNull(users.deletedAt)))
      .limit(1);
    return user;
  }

  async createUser(user: InsertUser): Promise<User> {
    const [newUser] = await db
      .insert(users)
      .values(user)
      .returning();
    return newUser;
  }

  async updateUser(id: number, user: Partial<User>): Promise<User | undefined> {
    const [updatedUser] = await db
      .update(users)
      .set({ ...user, updatedAt: new Date() })
      .where(eq(users.id, id))
      .returning();
    return updatedUser;
  }

  async deleteUser(id: number): Promise<boolean> {
    const [deletedUser] = await db
      .update(users)
      .set({ deletedAt: new Date() })
      .where(eq(users.id, id))
      .returning();
    return !!deletedUser;
  }

  async getAllUsers(): Promise<User[]> {
    return db
      .select()
      .from(users)
      .where(isNull(users.deletedAt))
      .orderBy(users.username);
  }

  // Products
  async getProduct(id: number): Promise<Product | undefined> {
    const [product] = await db
      .select()
      .from(products)
      .where(and(eq(products.id, id), isNull(products.deletedAt)))
      .limit(1);
    return product;
  }

  async getProductBySku(sku: string): Promise<Product | undefined> {
    const [product] = await db
      .select()
      .from(products)
      .where(and(eq(products.sku, sku), isNull(products.deletedAt)))
      .limit(1);
    return product;
  }

  async createProduct(product: InsertProduct): Promise<Product> {
    const [newProduct] = await db
      .insert(products)
      .values(product)
      .returning();
    return newProduct;
  }

  async updateProduct(id: number, product: Partial<Product>): Promise<Product | undefined> {
    const [updatedProduct] = await db
      .update(products)
      .set({ ...product, updatedAt: new Date() })
      .where(eq(products.id, id))
      .returning();
    return updatedProduct;
  }

  async deleteProduct(id: number): Promise<boolean> {
    const [deletedProduct] = await db
      .update(products)
      .set({ deletedAt: new Date() })
      .where(eq(products.id, id))
      .returning();
    return !!deletedProduct;
  }

  async getAllProducts(): Promise<Product[]> {
    return db
      .select()
      .from(products)
      .where(isNull(products.deletedAt))
      .orderBy(products.name);
  }

  async searchProducts(query: string): Promise<Product[]> {
    return db
      .select()
      .from(products)
      .where(
        and(
          isNull(products.deletedAt),
          sql`(${products.name} ILIKE ${'%' + query + '%'} OR ${products.sku} ILIKE ${'%' + query + '%'})`
        )
      )
      .orderBy(products.name);
  }

  // Product Categories
  async getProductCategory(id: number): Promise<ProductCategory | undefined> {
    const [category] = await db
      .select()
      .from(productCategories)
      .where(and(eq(productCategories.id, id), isNull(productCategories.deletedAt)))
      .limit(1);
    return category;
  }

  async createProductCategory(category: InsertProductCategory): Promise<ProductCategory> {
    const [newCategory] = await db
      .insert(productCategories)
      .values(category)
      .returning();
    return newCategory;
  }

  async updateProductCategory(id: number, category: Partial<ProductCategory>): Promise<ProductCategory | undefined> {
    const [updatedCategory] = await db
      .update(productCategories)
      .set({ ...category, updatedAt: new Date() })
      .where(eq(productCategories.id, id))
      .returning();
    return updatedCategory;
  }

  async deleteProductCategory(id: number): Promise<boolean> {
    const [deletedCategory] = await db
      .update(productCategories)
      .set({ deletedAt: new Date() })
      .where(eq(productCategories.id, id))
      .returning();
    return !!deletedCategory;
  }

  async getAllProductCategories(): Promise<ProductCategory[]> {
    return db
      .select()
      .from(productCategories)
      .where(isNull(productCategories.deletedAt))
      .orderBy(productCategories.name);
  }

  // Units of Measure
  async getUnitOfMeasure(id: string): Promise<UnitOfMeasure | undefined> {
    const [uom] = await db
      .select()
      .from(unitsOfMeasure)
      .where(and(eq(unitsOfMeasure.id, id), isNull(unitsOfMeasure.deletedAt)))
      .limit(1);
    return uom;
  }

  async createUnitOfMeasure(uom: InsertUnitOfMeasure): Promise<UnitOfMeasure> {
    const [newUom] = await db
      .insert(unitsOfMeasure)
      .values(uom)
      .returning();
    return newUom;
  }

  async updateUnitOfMeasure(id: string, uom: Partial<UnitOfMeasure>): Promise<UnitOfMeasure | undefined> {
    const [updatedUom] = await db
      .update(unitsOfMeasure)
      .set({ ...uom, updatedAt: new Date() })
      .where(eq(unitsOfMeasure.id, id))
      .returning();
    return updatedUom;
  }

  async deleteUnitOfMeasure(id: string): Promise<boolean> {
    const [deletedUom] = await db
      .update(unitsOfMeasure)
      .set({ deletedAt: new Date() })
      .where(eq(unitsOfMeasure.id, id))
      .returning();
    return !!deletedUom;
  }

  async getAllUnitsOfMeasure(): Promise<UnitOfMeasure[]> {
    return db
      .select()
      .from(unitsOfMeasure)
      .where(isNull(unitsOfMeasure.deletedAt))
      .orderBy(unitsOfMeasure.name);
  }

  // Inventory
  async getInventory(id: number): Promise<Inventory | undefined> {
    const [inv] = await db
      .select()
      .from(inventory)
      .where(eq(inventory.id, id))
      .limit(1);
    return inv;
  }

  async createInventory(inv: InsertInventory): Promise<Inventory> {
    const [newInv] = await db
      .insert(inventory)
      .values(inv)
      .returning();
    return newInv;
  }

  async updateInventory(id: number, inv: Partial<Inventory>): Promise<Inventory | undefined> {
    const [updatedInv] = await db
      .update(inventory)
      .set({ ...inv, updatedAt: new Date() })
      .where(eq(inventory.id, id))
      .returning();
    return updatedInv;
  }

  async deleteInventory(id: number): Promise<boolean> {
    const result = await db
      .delete(inventory)
      .where(eq(inventory.id, id))
      .returning();
    return result.length > 0;
  }

  async getInventoryByProduct(productId: number): Promise<Inventory[]> {
    return db
      .select()
      .from(inventory)
      .where(eq(inventory.productId, productId));
  }

  async getInventoryByWarehouse(warehouseId: string): Promise<Inventory[]> {
    return db
      .select()
      .from(inventory)
      .where(eq(inventory.warehouseId, warehouseId));
  }

  async getAllInventory(): Promise<Inventory[]> {
    return db
      .select()
      .from(inventory);
  }

  // Stock Movements
  async createStockMovement(movement: InsertStockMovement): Promise<StockMovement> {
    const [newMovement] = await db
      .insert(stockMovements)
      .values(movement)
      .returning();

    // Update inventory levels
    const existingInventory = await this.getInventoryByProductAndWarehouse(
      movement.productId,
      movement.warehouseId
    );

    if (existingInventory) {
      const quantityChange = movement.direction === 'IN' 
        ? Number(movement.quantity) 
        : -Number(movement.quantity);

      await this.updateInventory(existingInventory.id, {
        quantity: Number(existingInventory.quantity) + quantityChange
      });
    } else if (movement.direction === 'IN') {
      // Create new inventory record if it doesn't exist and it's an incoming movement
      await this.createInventory({
        productId: movement.productId,
        warehouseId: movement.warehouseId,
        quantity: movement.quantity,
        reservedQuantity: '0'
      });
    }

    return newMovement;
  }

  private async getInventoryByProductAndWarehouse(
    productId: number, 
    warehouseId: string
  ): Promise<Inventory | undefined> {
    const [inv] = await db
      .select()
      .from(inventory)
      .where(
        and(
          eq(inventory.productId, productId),
          eq(inventory.warehouseId, warehouseId)
        )
      )
      .limit(1);
    return inv;
  }

  async getStockMovementsByProduct(productId: number): Promise<StockMovement[]> {
    return db
      .select()
      .from(stockMovements)
      .where(eq(stockMovements.productId, productId))
      .orderBy(desc(stockMovements.createdAt));
  }

  async getStockMovementsByWarehouse(warehouseId: string): Promise<StockMovement[]> {
    return db
      .select()
      .from(stockMovements)
      .where(eq(stockMovements.warehouseId, warehouseId))
      .orderBy(desc(stockMovements.createdAt));
  }

  async getRecentStockMovements(limit: number = 10): Promise<StockMovement[]> {
    return db
      .select()
      .from(stockMovements)
      .orderBy(desc(stockMovements.createdAt))
      .limit(limit);
  }

  // Orders
  async getOrder(id: number): Promise<Order | undefined> {
    const [order] = await db
      .select()
      .from(orders)
      .where(eq(orders.id, id))
      .limit(1);
    return order;
  }

  async createOrder(order: InsertOrder): Promise<Order> {
    const [newOrder] = await db
      .insert(orders)
      .values(order)
      .returning();
    return newOrder;
  }

  async updateOrder(id: number, order: Partial<Order>): Promise<Order | undefined> {
    const [updatedOrder] = await db
      .update(orders)
      .set({ ...order, updatedAt: new Date() })
      .where(eq(orders.id, id))
      .returning();
    return updatedOrder;
  }

  async deleteOrder(id: number): Promise<boolean> {
    // First delete order items
    await db
      .delete(orderItems)
      .where(eq(orderItems.orderId, id));

    // Then delete the order
    const result = await db
      .delete(orders)
      .where(eq(orders.id, id))
      .returning();
    return result.length > 0;
  }

  async getAllOrders(): Promise<Order[]> {
    return db
      .select()
      .from(orders)
      .orderBy(desc(orders.orderDate));
  }

  async getOrdersByStatus(status: string): Promise<Order[]> {
    return db
      .select()
      .from(orders)
      .where(eq(orders.status, status))
      .orderBy(desc(orders.orderDate));
  }

  async getRecentOrders(limit: number = 10): Promise<Order[]> {
    return db
      .select()
      .from(orders)
      .orderBy(desc(orders.orderDate))
      .limit(limit);
  }

  // Order Items
  async getOrderItems(orderId: number): Promise<OrderItem[]> {
    return db
      .select()
      .from(orderItems)
      .where(eq(orderItems.orderId, orderId));
  }

  async createOrderItem(item: InsertOrderItem): Promise<OrderItem> {
    const [newItem] = await db
      .insert(orderItems)
      .values(item)
      .returning();
    return newItem;
  }

  async updateOrderItem(id: number, item: Partial<OrderItem>): Promise<OrderItem | undefined> {
    const [updatedItem] = await db
      .update(orderItems)
      .set(item)
      .where(eq(orderItems.id, id))
      .returning();
    return updatedItem;
  }

  async deleteOrderItem(id: number): Promise<boolean> {
    const result = await db
      .delete(orderItems)
      .where(eq(orderItems.id, id))
      .returning();
    return result.length > 0;
  }

  // Warehouses
  async getWarehouse(id: string): Promise<Warehouse | undefined> {
    const [warehouse] = await db
      .select()
      .from(warehouses)
      .where(and(eq(warehouses.id, id), isNull(warehouses.deletedAt)))
      .limit(1);
    return warehouse;
  }

  async getAllWarehouses(): Promise<Warehouse[]> {
    return db
      .select()
      .from(warehouses)
      .where(isNull(warehouses.deletedAt))
      .orderBy(warehouses.name);
  }

  async createWarehouse(data: Partial<Warehouse> | InsertWarehouse): Promise<Warehouse> {
    const [result] = await db.insert(warehouses).values({
      ...data,
      id: data.id || Math.random().toString(36).substring(2, 12).toUpperCase(),
    }).returning();
    return result;
  }

  async updateWarehouse(id: string, data: Partial<Warehouse>): Promise<Warehouse | undefined> {
    const [result] = await db.update(warehouses)
      .set({
        ...data,
        updatedAt: new Date()
      })
      .where(eq(warehouses.id, id))
      .returning();
    return result;
  }

  async deleteWarehouse(id: string): Promise<boolean> {
    const result = await db.update(warehouses)
      .set({
        deletedAt: new Date()
      })
      .where(eq(warehouses.id, id));
    return result.rowCount > 0;
  }

  // Class Types
  async getClassType(id: string): Promise<ClassType | undefined> {
    const [classType] = await db
      .select()
      .from(classTypes)
      .where(and(eq(classTypes.id, id), isNull(classTypes.deletedAt)))
      .limit(1);
    return classType;
  }

  async getAllClassTypes(): Promise<ClassType[]> {
    return db
      .select()
      .from(classTypes)
      .where(isNull(classTypes.deletedAt))
      .orderBy(classTypes.name);
  }

  // Dashboard Data
  async getInventoryValue(): Promise<number> {
    const result = await db.execute(sql`
      SELECT SUM(i.quantity * p.cost) as total_value
      FROM ${inventory} i
      JOIN ${products} p ON i.product_id = p.id
      WHERE p.deleted_at IS NULL
    `);

    return result.rows[0]?.total_value || 0;
  }

  async getLowStockItems(): Promise<{product: Product, inventory: Inventory}[]> {
    const result = await db.execute(sql`
      SELECT p.*, i.*
      FROM ${products} p
      JOIN ${inventory} i ON p.id = i.product_id
      WHERE p.deleted_at IS NULL
        AND i.quantity <= p.reorder_point
      ORDER BY p.name
    `);

    return result.rows.map((row: any) => {
      const product: Product = {
        id: row.id,
        sku: row.sku,
        name: row.name,
        description: row.description,
        categoryId: row.category_id,
        uomId: row.uom_id,
        price: row.price,
        cost: row.cost,
        weight: row.weight,
        length: row.length,
        width: row.width,
        height: row.height,
        minStockLevel: row.min_stock_level,
        maxStockLevel: row.max_stock_level,
        reorderPoint: row.reorder_point,
        leadTime: row.lead_time,
        isActive: row.is_active,
        imageUrl: row.image_url,
        barcode: row.barcode,
        createdAt: row.created_at,
        updatedAt: row.updated_at,
        deletedAt: row.deleted_at,
        createdBy: row.created_by,
        updatedBy: row.updated_by,
        deletedBy: row.deleted_by,
      };

      const inventory: Inventory = {
        id: row.id,
        productId: row.product_id,
        warehouseId: row.warehouse_id,
        quantity: row.quantity,
        reservedQuantity: row.reserved_quantity,
        location: row.location,
        lastCountDate: row.last_count_date,
        createdAt: row.created_at,
        updatedAt: row.updated_at,
      };

      return { product, inventory };
    });
  }

  async getInventoryLevelsByCategory(): Promise<{category: string, value: number}[]> {
    const result = await db.execute(sql`
      SELECT pc.category_name as category, SUM(i.quantity) as value
      FROM ${inventory} i
      JOIN ${products} p ON i.product_id = p.id
      LEFT JOIN ${productCategories} pc ON p.category_id = pc.category_id
      WHERE p.deleted_at IS NULL
      GROUP BY pc.category_name
      ORDER BY value DESC
      LIMIT 5
    `);

    return result.rows;
  }

  async getOrderTrends(): Promise<{date: string, incoming: number, outgoing: number}[]> {
    // Mock data for order trends
    const lastSixMonths = Array.from({ length: 6 }, (_, i) => {
      const date = new Date();
      date.setMonth(date.getMonth() - i);
      return date.toISOString().slice(0, 7); // Format as YYYY-MM
    }).reverse();

    return lastSixMonths.map(date => ({
      date,
      incoming: Math.floor(Math.random() * 100) + 50, // Random number between 50-150
      outgoing: Math.floor(Math.random() * 100) + 30, // Random number between 30-130
    }));
  }
}

export const storage = new DatabaseStorage();