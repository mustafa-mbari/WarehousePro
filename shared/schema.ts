import { 
  pgTable, 
  text, 
  serial, 
  integer, 
  boolean, 
  timestamp,
  varchar, 
  date,
  decimal,
  json,
  jsonb,
  bigserial,
  bigint,
  primaryKey,
  uniqueIndex
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

// Users table
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  firstName: varchar("first_name", { length: 50 }).notNull(),
  lastName: varchar("last_name", { length: 50 }).notNull(),
  phone: varchar("phone", { length: 20 }),
  birthDate: date("birth_date"),
  gender: varchar("gender", { length: 10 }),
  profilePicture: varchar("profile_picture", { length: 255 }),
  address: text("address"),
  city: varchar("city", { length: 50 }),
  country: varchar("country", { length: 50 }),
  postalCode: varchar("postal_code", { length: 20 }),
  languagePreference: varchar("language_preference", { length: 10 }),
  timezone: varchar("timezone", { length: 50 }),
  defaultWarehouseId: varchar("default_warehouse_id", { length: 10 }),
  isActive: boolean("is_active").default(true),
  isAdmin: boolean("is_admin").default(false),
  lastLogin: timestamp("last_login"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  deletedAt: timestamp("deleted_at"),
});

export const warehouses = pgTable("warehouses", {
  id: varchar("warehouse_id", { length: 10 }).primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  description: text("description"),
  address: text("address"),
  city: varchar("city", { length: 50 }),
  state: varchar("state", { length: 50 }),
  country: varchar("country", { length: 50 }),
  postalCode: varchar("postal_code", { length: 20 }),
  contactName: varchar("contact_name", { length: 100 }),
  contactEmail: varchar("contact_email", { length: 100 }),
  contactPhone: varchar("contact_phone", { length: 20 }),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  deletedAt: timestamp("deleted_at"),
});

export const unitsOfMeasure = pgTable("units_of_measure", {
  id: varchar("uom_id", { length: 10 }).primaryKey(),
  name: varchar("uom_name", { length: 50 }).notNull(),
  type: varchar("uom_type", { length: 20 }).notNull(),
  description: text("description"),
  conversionFactor: decimal("conversion_factor", { precision: 10, scale: 4 }),
  baseUomId: varchar("base_uom_id", { length: 10 }),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  deletedAt: timestamp("deleted_at"),
  system: varchar("system", { length: 20 }),
  category: varchar("category", { length: 50 }),
  symbol: varchar("symbol", { length: 10 }),
  isBaseUnit: boolean("is_base_unit").default(false),
  decimalPrecision: integer("decimal_precision").default(2),
  measurementAccuracy: decimal("measurement_accuracy", { precision: 10, scale: 4 }),
  industryStandard: boolean("industry_standard").default(false),
  notes: text("notes"),
  sortOrder: integer("sort_order"),
  createdBy: varchar("created_by", { length: 36 }),
  updatedBy: varchar("updated_by", { length: 36 }),
  deletedBy: varchar("deleted_by", { length: 36 }),
});

export const classTypes = pgTable("class_types", {
  id: varchar("class_type_id", { length: 20 }).primaryKey(),
  name: varchar("class_name", { length: 50 }).notNull(),
  code: varchar("class_code", { length: 20 }).unique(),
  parentId: varchar("parent_class_id", { length: 20 }),
  level: integer("level"),
  isSystem: boolean("is_system").default(false),
  description: text("description"),
  imageUrl: text("image_url"),
  colorCode: varchar("color_code", { length: 10 }),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  deletedAt: timestamp("deleted_at"),
  createdBy: varchar("created_by", { length: 36 }),
  updatedBy: varchar("updated_by", { length: 36 }),
  deletedBy: varchar("deleted_by", { length: 36 }),
});

export const tuOrientationTypes = pgTable("tu_orientation_types", {
  code: varchar("orientation_code", { length: 10 }).primaryKey(),
  name: varchar("orientation_name", { length: 50 }).notNull(),
  description: text("description"),
  rotationAngleX: decimal("rotation_angle_x", { precision: 5, scale: 2 }),
  rotationAngleY: decimal("rotation_angle_y", { precision: 5, scale: 2 }),
  rotationAngleZ: decimal("rotation_angle_z", { precision: 5, scale: 2 }),
  isStandard: boolean("is_standard").default(true),
  allowedForTuTypes: jsonb("allowed_for_tu_types"),
  weightLimit: decimal("weight_limit", { precision: 10, scale: 2 }),
  requiresSpecialEquipment: boolean("requires_special_equipment").default(false),
  diagramUrl: text("diagram_url"),
  safetyInstructions: text("safety_instructions"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  deletedAt: timestamp("deleted_at"),
  createdBy: varchar("created_by", { length: 36 }),
  updatedBy: varchar("updated_by", { length: 36 }),
  deletedBy: varchar("deleted_by", { length: 36 }),
});

export const productCategories = pgTable("product_categories", {
  id: bigserial("category_id", { mode: "number" }).primaryKey(),
  code: varchar("category_code", { length: 64 }).notNull().unique(),
  name: varchar("category_name", { length: 256 }).notNull(),
  classType: varchar("class_type", { length: 32 }),
  description: varchar("description", { length: 2048 }),
  parentId: bigint("parent_id", { mode: "number" }),
  level: integer("level").default(1),
  sortOrder: integer("sort_order").default(0),
  isActive: boolean("is_active").default(true),
  isFeatured: boolean("is_featured").default(false),
  slug: varchar("slug", { length: 100 }).unique(),
  metaTitle: varchar("meta_title", { length: 100 }),
  metaDescription: text("meta_description"),
  imageUrl: varchar("image_url", { length: 255 }),
  icon: varchar("icon", { length: 50 }),
  colorCode: varchar("color_code", { length: 7 }),
  inventoryType: varchar("inventory_type", { length: 20 }).default("PHYSICAL"),
  taxClass: varchar("tax_class", { length: 50 }),
  transactionCount: decimal("transaction_count", { precision: 10, scale: 0 }),
  customAttributes: jsonb("custom_attributes"),
  createdAt: timestamp("create_date").defaultNow(),
  updatedAt: timestamp("update_date").defaultNow(),
  deletedAt: timestamp("deleted_at"),
  createdBy: varchar("created_by", { length: 36 }),
  updatedBy: varchar("updated_by", { length: 36 }),
  deletedBy: varchar("deleted_by", { length: 36 }),
});

export const products = pgTable("products", {
  id: serial("id").primaryKey(),
  sku: varchar("sku", { length: 50 }).notNull().unique(),
  name: varchar("name", { length: 100 }).notNull(),
  description: text("description"),
  categoryId: bigint("category_id", { mode: "number" }),
  uomId: varchar("uom_id", { length: 10 }),
  price: decimal("price", { precision: 10, scale: 2 }),
  cost: decimal("cost", { precision: 10, scale: 2 }),
  weight: decimal("weight", { precision: 10, scale: 2 }),
  length: decimal("length", { precision: 10, scale: 2 }),
  width: decimal("width", { precision: 10, scale: 2 }),
  height: decimal("height", { precision: 10, scale: 2 }),
  minStockLevel: integer("min_stock_level").default(0),
  maxStockLevel: integer("max_stock_level"),
  reorderPoint: integer("reorder_point"),
  leadTime: integer("lead_time"), // in days
  isActive: boolean("is_active").default(true),
  imageUrl: varchar("image_url", { length: 255 }),
  barcode: varchar("barcode", { length: 50 }),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  deletedAt: timestamp("deleted_at"),
  createdBy: integer("created_by"),
  updatedBy: integer("updated_by"),
  deletedBy: integer("deleted_by"),
});

export const inventory = pgTable("inventory", {
  id: serial("id").primaryKey(),
  productId: integer("product_id").notNull(),
  warehouseId: varchar("warehouse_id", { length: 10 }).notNull(),
  quantity: decimal("quantity", { precision: 10, scale: 2 }).notNull().default("0"),
  reservedQuantity: decimal("reserved_quantity", { precision: 10, scale: 2 }).default("0"),
  location: varchar("location", { length: 50 }),
  lastCountDate: timestamp("last_count_date"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const stockMovements = pgTable("stock_movements", {
  id: serial("id").primaryKey(),
  productId: integer("product_id").notNull(),
  warehouseId: varchar("warehouse_id", { length: 10 }).notNull(),
  quantity: decimal("quantity", { precision: 10, scale: 2 }).notNull(),
  direction: varchar("direction", { length: 10 }).notNull(), // IN, OUT
  referenceType: varchar("reference_type", { length: 50 }), // ORDER, ADJUSTMENT, TRANSFER
  referenceId: varchar("reference_id", { length: 50 }),
  notes: text("notes"),
  createdAt: timestamp("created_at").defaultNow(),
  createdBy: integer("created_by"),
});

export const orders = pgTable("orders", {
  id: serial("id").primaryKey(),
  orderNumber: varchar("order_number", { length: 20 }).notNull().unique(),
  customerId: integer("customer_id"),
  orderDate: timestamp("order_date").defaultNow(),
  status: varchar("status", { length: 20 }).notNull(), // DRAFT, PENDING, PROCESSING, SHIPPED, COMPLETED, CANCELLED
  totalAmount: decimal("total_amount", { precision: 10, scale: 2 }),
  notes: text("notes"),
  shippingAddress: text("shipping_address"),
  billingAddress: text("billing_address"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
  createdBy: integer("created_by"),
  updatedBy: integer("updated_by"),
});

export const orderItems = pgTable("order_items", {
  id: serial("id").primaryKey(),
  orderId: integer("order_id").notNull(),
  productId: integer("product_id").notNull(),
  quantity: decimal("quantity", { precision: 10, scale: 2 }).notNull(),
  unitPrice: decimal("unit_price", { precision: 10, scale: 2 }).notNull(),
  totalPrice: decimal("total_price", { precision: 10, scale: 2 }).notNull(),
  notes: text("notes"),
});

// Define relationships
export const productsRelations = relations(products, ({ one, many }) => ({
  category: one(productCategories, {
    fields: [products.categoryId],
    references: [productCategories.id],
  }),
  uom: one(unitsOfMeasure, {
    fields: [products.uomId],
    references: [unitsOfMeasure.id],
  }),
  inventory: many(inventory),
  orderItems: many(orderItems),
  stockMovements: many(stockMovements),
}));

export const inventoryRelations = relations(inventory, ({ one }) => ({
  product: one(products, {
    fields: [inventory.productId],
    references: [products.id],
  }),
  warehouse: one(warehouses, {
    fields: [inventory.warehouseId],
    references: [warehouses.id],
  }),
}));

export const stockMovementsRelations = relations(stockMovements, ({ one }) => ({
  product: one(products, {
    fields: [stockMovements.productId],
    references: [products.id],
  }),
  warehouse: one(warehouses, {
    fields: [stockMovements.warehouseId],
    references: [warehouses.id],
  }),
  createdByUser: one(users, {
    fields: [stockMovements.createdBy],
    references: [users.id],
  }),
}));

export const ordersRelations = relations(orders, ({ many, one }) => ({
  items: many(orderItems),
  createdByUser: one(users, {
    fields: [orders.createdBy],
    references: [users.id],
  }),
  updatedByUser: one(users, {
    fields: [orders.updatedBy],
    references: [users.id],
  }),
}));

export const orderItemsRelations = relations(orderItems, ({ one }) => ({
  order: one(orders, {
    fields: [orderItems.orderId],
    references: [orders.id],
  }),
  product: one(products, {
    fields: [orderItems.productId],
    references: [products.id],
  }),
}));

export const productCategoriesRelations = relations(productCategories, ({ one, many }) => ({
  parent: one(productCategories, {
    fields: [productCategories.parentId],
    references: [productCategories.id],
  }),
  children: many(productCategories),
  products: many(products),
}));

export const unitsOfMeasureRelations = relations(unitsOfMeasure, ({ one, many }) => ({
  baseUom: one(unitsOfMeasure, {
    fields: [unitsOfMeasure.baseUomId],
    references: [unitsOfMeasure.id],
  }),
  derivedUoms: many(unitsOfMeasure),
  products: many(products),
}));

export const classTypesRelations = relations(classTypes, ({ one, many }) => ({
  parent: one(classTypes, {
    fields: [classTypes.parentId],
    references: [classTypes.id],
  }),
  children: many(classTypes),
}));

// Insert schemas
export const insertUserSchema = createInsertSchema(users)
  .omit({
    id: true,
    createdAt: true,
    updatedAt: true,
    deletedAt: true,
    lastLogin: true,
  })
  .extend({
    password: z.string().min(6),
    email: z.string().email(),
  });

export const insertProductSchema = createInsertSchema(products)
  .omit({
    id: true,
    createdAt: true,
    updatedAt: true,
    deletedAt: true,
    createdBy: true,
    updatedBy: true,
    deletedBy: true,
  });

export const insertProductCategorySchema = createInsertSchema(productCategories)
  .omit({
    id: true,
    createdAt: true,
    updatedAt: true,
    deletedAt: true,
    createdBy: true,
    updatedBy: true,
    deletedBy: true,
    transactionCount: true,
  });

export const insertUnitOfMeasureSchema = createInsertSchema(unitsOfMeasure)
  .omit({
    createdAt: true,
    updatedAt: true,
    deletedAt: true,
    createdBy: true,
    updatedBy: true,
    deletedBy: true,
  });

export const insertInventorySchema = createInsertSchema(inventory)
  .omit({
    id: true,
    createdAt: true,
    updatedAt: true,
  });

export const insertStockMovementSchema = createInsertSchema(stockMovements)
  .omit({
    id: true,
    createdAt: true,
  });

export const insertOrderSchema = createInsertSchema(orders)
  .omit({
    id: true,
    createdAt: true,
    updatedAt: true,
    createdBy: true,
    updatedBy: true,
  });

export const insertOrderItemSchema = createInsertSchema(orderItems)
  .omit({
    id: true,
  });

// Types
export type User = typeof users.$inferSelect;
export type InsertUser = z.infer<typeof insertUserSchema>;

export type Product = typeof products.$inferSelect;
export type InsertProduct = z.infer<typeof insertProductSchema>;

export type ProductCategory = typeof productCategories.$inferSelect;
export type InsertProductCategory = z.infer<typeof insertProductCategorySchema>;

export type UnitOfMeasure = typeof unitsOfMeasure.$inferSelect;
export type InsertUnitOfMeasure = z.infer<typeof insertUnitOfMeasureSchema>;

export type Inventory = typeof inventory.$inferSelect;
export type InsertInventory = z.infer<typeof insertInventorySchema>;

export type StockMovement = typeof stockMovements.$inferSelect;
export type InsertStockMovement = z.infer<typeof insertStockMovementSchema>;

export type Order = typeof orders.$inferSelect;
export type InsertOrder = z.infer<typeof insertOrderSchema>;

export type OrderItem = typeof orderItems.$inferSelect;
export type InsertOrderItem = z.infer<typeof insertOrderItemSchema>;

// Insert schema for warehouses
export const insertWarehouseSchema = createInsertSchema(warehouses)
  .omit({
    createdAt: true,
    updatedAt: true,
    deletedAt: true,
  });

export type Warehouse = typeof warehouses.$inferSelect;
export type InsertWarehouse = z.infer<typeof insertWarehouseSchema>;
export type ClassType = typeof classTypes.$inferSelect;
export type TuOrientationType = typeof tuOrientationTypes.$inferSelect;
