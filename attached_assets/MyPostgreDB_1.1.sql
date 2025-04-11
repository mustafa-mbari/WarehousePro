CREATE TABLE users (
	-- المعلومات الأساسية
	user_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للمستخدم
	username VARCHAR(50) UNIQUE NOT NULL, -- اسم المستخدم (يجب أن يكون فريداً)
	password_hash VARCHAR(255) NOT NULL, -- كلمة المرور مشفرة
	email VARCHAR(100) UNIQUE NOT NULL, -- البريد الإلكتروني (يجب أن يكون فريداً)
	
	-- المعلومات الشخصية
	first_name VARCHAR(50) NOT NULL, -- الاسم الأول
	last_name VARCHAR(50) NOT NULL, -- الاسم الأخير
	phone VARCHAR(20), -- رقم الهاتف
	birth_date DATE, -- تاريخ الميلاد
	gender VARCHAR(10), -- الجنس (ذكر/أنثى/غير محدد)
	profile_picture VARCHAR(255), -- رابط صورة الملف الشخصي
	
	-- معلومات العنوان
	address TEXT, -- العنوان التفصيلي
	city VARCHAR(50), -- المدينة
	country VARCHAR(50), -- الدولة
	postal_code VARCHAR(20), -- الرمز البريدي
	
	-- إعدادات المستخدم
	language_preference VARCHAR(10), -- اللغة المفضلة (ar/en等)
	timezone VARCHAR(50), -- المنطقة الزمنية
	default_warehouse_id VARCHAR(10), -- المستودع الافتراضي للمستخدم
	
	-- معلومات الأمان
	is_active BOOLEAN DEFAULT TRUE, -- حالة تفعيل الحساب
	failed_login_attempts INTEGER DEFAULT 0, -- عدد محاولات تسجيل الدخول الفاشلة
	account_locked BOOLEAN DEFAULT FALSE, -- حالة قفل الحساب
	two_factor_auth_enabled BOOLEAN DEFAULT FALSE, -- تفعيل المصادقة الثنائية
	password_changed_at TIMESTAMP, -- آخر تاريخ لتغيير كلمة المرور
	
	-- معلومات التتبع
	last_login TIMESTAMP, -- آخر وقت تسجيل دخول
	last_ip_address VARCHAR(45), -- آخر عنوان IP استخدم للتسجيل
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	
	-- معلومات إضافية
	notes TEXT, -- ملاحظات إضافية عن المستخدم
	
	FOREIGN KEY (created_by) REFERENCES users(user_id), -- منشئ السجل
	FOREIGN KEY (updated_by) REFERENCES users(user_id), -- آخر معدل للسجل
	FOREIGN KEY (deleted_by) REFERENCES users(user_id),  -- المستخدم الذي قام بالحذف
	FOREIGN KEY (default_warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- ملاحظة: يجب إنشاء جدول 'users' قبل تنفيذ هذا السكربت.
-- CREATE TABLE users ( user_id VARCHAR(36) PRIMARY KEY, ... ); -- مثال

CREATE TABLE units_of_measure (
	uom_id VARCHAR(10) PRIMARY KEY,                     -- المعرف الفريد للوحدة (مثل: 'KG', 'L', 'M')
	uom_name VARCHAR(50) NOT NULL,                     -- اسم الوحدة (مثل: 'كيلوجرام', 'لتر', 'متر')
	uom_type VARCHAR(20) NOT NULL,                     -- نوع الوحدة: وزن (weight)، حجم (volume)، طول (length)، كمية (quantity)
	description TEXT,                                  -- وصف تفصيلي للوحدة (اختياري)
	conversion_factor DECIMAL(10,4),                   -- عامل التحويل للوحدة الأساسية (مثال: 1000 إذا كانت الوحدة بالجرام والوحدة الأساسية بالكيلوجرام)
	base_uom_id VARCHAR(10),                          -- معرف الوحدة الأساسية المرتبطة (للتحويل بين الوحدات)
	is_active BOOLEAN NOT NULL DEFAULT TRUE,                  -- هل الوحدة مفعلة؟ (true/false)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- تاريخ إنشاء الوحدة (تلقائي)
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ تحديث الوحدة (يتغير تلقائيًا عند التعديل)
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	system VARCHAR(20),                               -- النظام الذي تنتمي إليه الوحدة (متري 'metric'، إمبراطوري 'imperial'، مخصص 'custom')
	category VARCHAR(50),                             -- الفئة (مثل: 'طبخ', 'صناعي', 'طبي')
	symbol VARCHAR(10),                               -- رمز الوحدة (مثل: 'kg', 'L', 'm')
	is_base_unit BOOLEAN NOT NULL DEFAULT FALSE,               -- هل هذه الوحدة أساسية؟ (لا تحتاج تحويلًا)
	decimal_precision INTEGER DEFAULT 2,			  -- عدد المنازل العشرية
	measurement_accuracy DECIMAL(10,4),				  -- دقة القياس
	industry_standard BOOLEAN DEFAULT FALSE,		  -- هل هي وحدة معيارية في الصناعة؟
	notes TEXT,                                       -- ملاحظات إضافية (اختياري)
	sort_order INTEGER,                               -- ترتيب العرض في القوائم (اختياري)
	created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل  -- !! CHANGED: Removed FOREIGN KEY for initial creation if users table might not exist yet
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	FOREIGN KEY (base_uom_id) REFERENCES units_of_measure(uom_id)  -- مفتاح خارجي يربط الوحدة بأخرى أساسية
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE IF NOT EXISTS class_types (
	-- ********** الأعمدة الأساسية **********
	class_type_id VARCHAR(20) PRIMARY KEY, -- معرف فريد لنوع الفئة
	class_name VARCHAR(50) NOT NULL, -- اسم الفئة
	class_code VARCHAR(20) UNIQUE, -- كود مختصر للفئة

	-- ********** التصنيف والتسلسل الهرمي **********
	parent_class_id VARCHAR(20), -- الفئة الأب (للهيكل الهرمي)
	level INTEGER, -- مستوى الفئة في الهيكل الهرمي
	is_system BOOLEAN DEFAULT FALSE, -- هل هي فئة نظامية؟

	-- ********** المعلومات الإضافية **********
	description TEXT, -- وصف الفئة
	image_url TEXT, -- صورة توضيحية للفئة
	color_code VARCHAR(10), -- كود اللون للتمثيل البصري

	-- ********** أعمدة التتبع **********
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- ********** المفاتيح الخارجية **********
	FOREIGN KEY (parent_class_id) REFERENCES class_types(class_type_id)
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE IF NOT EXISTS tu_orientation_types (
	-- ********** الأعمدة الأساسية **********
	orientation_code VARCHAR(10) PRIMARY KEY, -- كود فريد لتوجيه الوحدة
	orientation_name VARCHAR(50) NOT NULL, -- اسم التوجيه
	description TEXT, -- وصف التوجيه

	-- ********** الخصائص الهندسية **********
	rotation_angle_x DECIMAL(5,2), -- زاوية الدوران حول المحور X
	rotation_angle_y DECIMAL(5,2), -- زاوية الدوران حول المحور Y
	rotation_angle_z DECIMAL(5,2), -- زاوية الدوران حول المحور Z
	is_standard BOOLEAN DEFAULT TRUE, -- هل هو توجيه قياسي؟

	-- ********** القيود والاشتراطات **********
	allowed_for_tu_types JSONB, -- أنواع الوحدات المسموح بها لهذا التوجيه
	weight_limit DECIMAL(10,2), -- حد الوزن لهذا التوجيه
	requires_special_equipment BOOLEAN DEFAULT FALSE, -- هل يحتاج معدات خاصة؟

	-- ********** المعلومات الإضافية **********
	diagram_url TEXT, -- رابط رسم توضيحي للتوجيه
	safety_instructions TEXT, -- تعليمات السلامة

	-- ********** أعمدة التتبع **********
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE product_categories (
	-- Primary Identifiers
	category_id BIGSERIAL PRIMARY KEY,               -- المفتاح الأساسي التلقائي
	category_code VARCHAR(64) UNIQUE NOT NULL,         -- المعرف الفريد للتصنيف

	-- Core Category Info
	category_name VARCHAR(256) NOT NULL,                     -- اسم التصنيف الرئيسي
	class_type VARCHAR(32),                                  -- نوع الفئة (للتصنيف الداخلي)
	description VARCHAR(2048),                               -- الوصف التفصيلي

	-- Hierarchy Management
	parent_id BIGINT REFERENCES product_categories(category_id) ON DELETE SET NULL, -- رابط التصنيف الأب
	level INTEGER DEFAULT 1,                                 -- عمق التصنيف في الهيكل
	sort_order INTEGER DEFAULT 0,                            -- ترتيب العرض في القوائم

	-- Status Flags
	is_active BOOLEAN DEFAULT TRUE,                         -- حالة التفعيل (نشط/معطل)
	is_featured BOOLEAN DEFAULT FALSE,                      -- تصنيف مميز على الواجهة

	-- SEO Optimization
	slug VARCHAR(100) UNIQUE,                               -- رابط وصفي للSEO
	meta_title VARCHAR(100),                                -- عنوان متوافق مع محركات البحث
	meta_description TEXT,                          -- وصف متوافق مع محركات البحث

	-- Visual Representation
	image_url VARCHAR(255),                                 -- رابط الصورة الرئيسية
	icon VARCHAR(50),                                       -- أيقونة التصنيف
	color_code VARCHAR(7),                                  -- لون التصنيف (كود HEX)

	-- Business Logic
	inventory_type VARCHAR(20) DEFAULT 'PHYSICAL',          -- نوع المخزون (رقمي/مادي)
	tax_class VARCHAR(50),                                  -- فئة الضريبة المطبقة
	transaction_count NUMERIC(10),                          -- عدد العمليات المرتبطة

	-- System
	custom_attributes JSONB,                                -- سمات مخصصة (تخزين JSON)

	-- Auditing
	create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

-- Indexes moved and corrected
CREATE INDEX idx_cat_parent ON product_categories(parent_id); -- Corrected column name
CREATE INDEX idx_cat_active ON product_categories(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_cat_slug ON product_categories(slug);


CREATE TABLE product_families (
	-- Primary Identifiers (Your original columns)
	family_id BIGSERIAL PRIMARY KEY,        -- المفتاح الأساسي التلقائي للعائلة
	family_code VARCHAR(64) UNIQUE NOT NULL,  -- المعرف الفريد للعائلة
	family_name VARCHAR(256) NOT NULL,              -- الاسم الرسمي للعائلة

	-- Classification
	class_type VARCHAR(32),                         -- نوع الفئة (STANDARD, VIP, etc.)
	description VARCHAR(2048),                      -- الوصف الأساسي للعائلة
	transaction_count NUMERIC(10),                  -- عدد المعاملات المرتبطة

	-- New Hierarchy/Taxonomy Columns
	parent_id BIGINT REFERENCES product_families(family_id), -- العائلة الأم
	category_id BIGINT REFERENCES product_categories(category_id), -- التصنيف الرئيسي -- !! CHANGED: data type from INTEGER to BIGINT to match product_categories.category_id
	segment VARCHAR(50),                           -- القطاع السوقي (premium, budget, etc.)

	-- Lifecycle Management
	lifecycle_stage VARCHAR(20) DEFAULT 'ACTIVE'   		-- Lifecycle stage - مرحلة دورة الحياة
		CHECK (lifecycle_stage IN ('PLANNING', 'ACTIVE', 'PHASE_OUT', 'DISCONTINUED')),
	launch_date DATE,                              -- Launch date - تاريخ الإطلاق الرسمي
	end_of_life_date DATE                          -- End of life date - تاريخ نهاية الدعم
		CHECK (end_of_life_date IS NULL OR end_of_life_date >= launch_date),

	-- New Business Attributes
	is_active BOOLEAN DEFAULT TRUE,                -- حالة التفعيل
	is_featured BOOLEAN DEFAULT FALSE,             -- تمييز العائلة
	target_market VARCHAR(50),                     -- السوق المستهدف (B2B, B2C, etc.)

	-- New Visual/SEO Columns
	image_url VARCHAR(255),                        -- رابط الصورة الرئيسية
	thumbnail_url VARCHAR(255),                    -- رابط الصورة المصغرة
	slug VARCHAR(100) UNIQUE,                      -- رابط SEO-friendly

	-- Your Original Audit Columns
	create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- Warranty and Returns
	warranty_period_months INTEGER                -- Warranty period in months
		CHECK (warranty_period_months IS NULL OR warranty_period_months > 0),
	return_window_days INTEGER DEFAULT 14         -- Return window in days
		CHECK (return_window_days > 0),

	-- Advanced
	attributes JSONB DEFAULT '{}',                             -- Custom attributes
	search_keywords TEXT[],                       -- Search keywords

	-- Constraints
	CONSTRAINT valid_lifecycle CHECK (lifecycle_stage IN (
		'PLANNING', 'ACTIVE', 'PHASE_OUT', 'DISCONTINUED'
	)),
	CONSTRAINT valid_dates CHECK (
		end_of_life_date IS NULL OR end_of_life_date >= launch_date
	)
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

-- Index moved and corrected
CREATE INDEX idx_family_parent ON product_families(parent_id); -- Corrected column name
CREATE INDEX idx_family_category ON product_families(category_id);
CREATE INDEX idx_family_active ON product_families(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_family_slug ON product_families(slug);


CREATE TABLE products (
	-- المعلومات الأساسية
	product_id VARCHAR(20) PRIMARY KEY,                     -- المعرف الفريد للمنتج
	product_name VARCHAR(100) NOT NULL,                    -- اسم المنتج
	product_description TEXT,                              -- وصف تفصيلي للمنتج

	-- التصنيف
	category_id BIGINT                                   -- التصنيف الرئيسي (مفتاح خارجي) -- !! CHANGED: data type from INTEGER to BIGINT
		REFERENCES product_categories(category_id),
	family_id BIGINT                                     -- العائلة المنتجة (مفتاح خارجي) -- !! CHANGED: data type from INTEGER to BIGINT
		REFERENCES product_families(family_id),

	-- رموز التعريف
	barcode VARCHAR(50) UNIQUE,                           -- الباركود (فريد)
	sku VARCHAR(50) UNIQUE,                               -- رمز المخزون (فريد)
	upc VARCHAR(50) UNIQUE,                                      -- الرمز الشريطي العالمي

	-- القياسات والأبعاد
	weight DECIMAL(10,2)                                  -- وزن المنتج
		CHECK (weight > 0),                               -- يجب أن يكون الوزن أكبر من الصفر
	weight_unit VARCHAR(10)                               -- وحدة الوزن (مفتاح خارجي)
		REFERENCES units_of_measure(uom_id),
	length DECIMAL(10,2)                                  -- الطول
		CHECK (length > 0),                               -- يجب أن يكون الطول أكبر من الصفر
	width DECIMAL(10,2)                                   -- العرض
		CHECK (width > 0),                                -- يجب أن يكون العرض أكبر من الصفر
	height DECIMAL(10,2)                                  -- الارتفاع
		CHECK (height > 0),                               -- يجب أن يكون الارتفاع أكبر من الصفر
	dimension_unit VARCHAR(10)                            -- وحدة الأبعاد (مفتاح خارجي)
		REFERENCES units_of_measure(uom_id),
	volume DECIMAL(10,2)                                  -- الحجم
		CHECK (volume > 0),                               -- يجب أن يكون الحجم أكبر من الصفر
	volume_unit VARCHAR(10)                               -- وحدة الحجم (مفتاح خارجي)
		REFERENCES units_of_measure(uom_id),

	-- إدارة المخزون
	min_stock_level DECIMAL(10,2)                         -- الحد الأدنى للمخزون
		CHECK (min_stock_level >= 0),                     -- يجب أن يكون الحد الأدنى للمخزون موجباً
	max_stock_level DECIMAL(10,2)                         -- الحد الأقصى للمخزون
		CHECK (max_stock_level > 0),                      -- يجب أن يكون الحد الأقصى للمخزون أكبر من الصفر
	reorder_point DECIMAL(10,2)                           -- نقطة إعادة الطلب
		CHECK (reorder_point >= 0),                       -- يجب أن تكون نقطة إعادة الطلب موجبة

	-- إدارة المستودعات
	STACKABLE_COLLI BOOLEAN DEFAULT TRUE,                 -- إمكانية التكديس (نعم/لا)
	MIN_UOM_ID VARCHAR(10)                                -- أصغر وحدة قياس للمنتج
		REFERENCES units_of_measure(uom_id),
	MIN_UOM_ROUNDING_RULE VARCHAR(20) DEFAULT 'NONE',     -- قاعدة تقريب أصغر وحدة (UP/DOWN/NONE)
	WEIGHT_VALIDATION VARCHAR(20) DEFAULT 'NONE',         -- طريقة التحقق من الوزن (NONE/STRICT/TOLERANCE)
	VELOCITY VARCHAR(10),                                 -- سرعة تداول المنتج (HIGH/MEDIUM/LOW)
	TRANSACTION_COUNT INTEGER DEFAULT 0,                  -- عدد عمليات التداول للمنتج
	SHELF_LIFE_CONTROLLED BOOLEAN DEFAULT FALSE,          -- هل المنتج له تاريخ صلاحية؟
	SCAN_VALIDATION_MODE VARCHAR(20) DEFAULT 'NONE',      -- طريقة التحقق عند المسح (NONE/UPC/SERIAL)
	RELEVANT_DATE_FOR_ALLOCATION DATE,                    -- التاريخ المعتمد للتوزيع (FIFO/FEFO)
	MAX_USED_TU_PER_PRODUCT INTEGER,                      -- الحد الأقصى لوحدات النقل للمنتج
	LOCAL BOOLEAN DEFAULT FALSE,                          -- هل المنتج محلي الصنع؟
	HOST_UOM_RATIO DECIMAL(10,2),                         -- نسبة تحويل وحدة القياس للمضيف
	DEFAULT_UOM_RATIO DECIMAL(10,2),                      -- نسبة التحويل الافتراضية للوحدات
	CLASS_TYPE VARCHAR(30),                               -- نوع تصنيف المنتج (HAZARDOUS/FRAGILE/etc.)

	-- الحالة والتواريخ
	is_active BOOLEAN DEFAULT TRUE,                       -- حالة تفعيل المنتج
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ الإنشاء
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ التحديث
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

-- Indexes removed as requested by "** to delete **" comment in original


CREATE TABLE product_attributes (
	-- المعرفات الأساسية
	attribute_id SERIAL PRIMARY KEY,                     -- المعرف الفريد للسمة (تلقائي)
	attribute_name VARCHAR(100) NOT NULL,               -- اسم السمة (مثل: "اللون"، "الحجم")
	attribute_code VARCHAR(50) UNIQUE NOT NULL,         -- كود السمة (للاستخدام البرمجي)

	-- معلومات وصفية
	description TEXT,                                   -- وصف تفصيلي للسمة
	notes TEXT,                                        -- ملاحظات إضافية

	-- إعدادات السمة
	attribute_type VARCHAR(20) NOT NULL,               -- نوع السمة (text, number, select, etc.)
	data_type VARCHAR(20) NOT NULL,                    -- نوع البيانات (varchar, integer, decimal, etc.)
	is_required BOOLEAN DEFAULT FALSE,                 -- هل السمة مطلوبة؟
	is_filterable BOOLEAN DEFAULT FALSE,               -- هل يمكن استخدامها للتصفية؟
	is_visible BOOLEAN DEFAULT TRUE,                   -- هل تظهر للعملاء؟
	is_comparable BOOLEAN DEFAULT FALSE,               -- هل يمكن المقارنة بناء عليها؟
	is_searchable BOOLEAN DEFAULT FALSE,               -- هل يمكن البحث بها؟

	-- إعدادات القيم
	default_value TEXT,                                -- القيمة الافتراضية
	validation_regex VARCHAR(255),                    -- نمط التحقق (Regex)
	min_value DECIMAL(15,4),                          -- القيمة الدنيا (للأرقام)
	max_value DECIMAL(15,4),                          -- القيمة القصوى (للأرقام)
	decimal_places INTEGER,                           -- عدد المنازل العشرية

	-- التصنيف والترتيب
	attribute_group VARCHAR(50),                      -- مجموعة السمات
	sort_order INTEGER DEFAULT 0,                     -- ترتيب الظهور

	-- إعدادات متقدمة
	is_system_attribute BOOLEAN DEFAULT FALSE,        							-- هل سمة نظامية؟
	is_configurable BOOLEAN DEFAULT FALSE,           							-- هل تستخدم للمنتجات القابلة للتكوين؟
	is_variant_attribute BOOLEAN DEFAULT FALSE,      							-- هل تستخدم لإنشاء متغيرات؟
	validation_message VARCHAR(255), 											-- رسالة خطأ التحقق
	depends_on_attribute INTEGER REFERENCES product_attributes(attribute_id), 	-- سمات معتمدة على أخرى

	-- التواريخ والمستخدمين
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ الإنشاء
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث
    deleted_by VARCHAR(36), -- المستخدم الذي قام بالحذف

	-- القيود
	CONSTRAINT chk_attribute_type CHECK (attribute_type IN ('text', 'number', 'select', 'multiselect', 'date', 'boolean')),
	CONSTRAINT chk_data_type CHECK (data_type IN ('varchar', 'integer', 'decimal', 'date', 'boolean', 'text'))
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE product_attribute_values (
	value_id SERIAL PRIMARY KEY,                     -- المعرف الفريد للقيمة
	attribute_id INTEGER NOT NULL,                   -- معرف السمة
	product_id VARCHAR(20) NOT NULL,                     -- معرف المنتج -- !! CHANGED: data type from INTEGER to VARCHAR(20)
	attribute_value TEXT NOT NULL,                   -- قيمة السمة
	value_label VARCHAR(255),                        -- تسمية القيمة (للعرض)

	-- للمتغيرات القابلة للتحديد
	is_default BOOLEAN NOT NULL DEFAULT FALSE,               -- هل هي القيمة الافتراضية؟
	sort_order INTEGER DEFAULT 0,                   -- ترتيب الظهور في القوائم
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ الإنشاء
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث
    deleted_by VARCHAR(36), -- المستخدم الذي قام بالحذف

	-- المفاتيح الخارجية
	FOREIGN KEY (attribute_id) REFERENCES product_attributes(attribute_id) ON DELETE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed

	-- القيود
	CONSTRAINT unique_product_attribute UNIQUE (product_id, attribute_id)
);

CREATE TABLE product_attribute_options (
	option_id SERIAL PRIMARY KEY,                   -- المعرف الفريد للخيار
	attribute_id INTEGER NOT NULL,                  -- معرف السمة
	option_value VARCHAR(255) NOT NULL,             -- قيمة الخيار
	option_label VARCHAR(255) NOT NULL,             -- تسمية الخيار (للعرض)
	sort_order INTEGER DEFAULT 0,                   -- ترتيب الظهور
	is_active BOOLEAN DEFAULT TRUE,					-- لتتمكن من تعطيل خيارات معينة دون حذفها
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ الإنشاء
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث
    deleted_by VARCHAR(36), -- المستخدم الذي قام بالحذف

	-- المفتاح الخارجي
	FOREIGN KEY (attribute_id) REFERENCES product_attributes(attribute_id) ON DELETE CASCADE
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE warehouses (
	-- المعرفات الأساسية
	warehouse_id VARCHAR(10) PRIMARY KEY,                  -- معرف فريد للمستودع
	warehouse_name VARCHAR(100) NOT NULL,                  -- اسم المستودع
	warehouse_code VARCHAR(20) UNIQUE,                     -- رمز فريد للمستودع
	-- معلومات العنوان
	address TEXT,                                          -- العنوان التفصيلي
	city VARCHAR(50),                                      -- المدينة
	state VARCHAR(50),                                     -- الولاية/المحافظة
	country VARCHAR(50),                                   -- الدولة
	postal_code VARCHAR(20),                               -- الرمز البريدي

	-- معلومات الاتصال
	contact_person VARCHAR(100),                           -- اسم الشخص المسؤول
	contact_email VARCHAR(100),                            -- بريد إلكتروني للتواصل
	contact_phone VARCHAR(20),                             -- رقم هاتف للتواصل
	secondary_contact_phone VARCHAR(20),                   -- رقم هاتف احتياطي

	-- الخصائص الفنية
	total_area DECIMAL(10,2),                              -- المساحة الإجمالية للمستودع (بالمتر المربع مثلاً)
	area_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس المساحة
	storage_capacity INTEGER,                              -- السعة التخزينية (عدد الوحدات/المنصات)
	warehouse_type VARCHAR(50),                            -- نوع المستودع (مبرد، جاف، خطر، إلخ)
	temperature_controlled BOOLEAN DEFAULT FALSE,          -- هل المستودع يدعم التحكم في درجة الحرارة؟
	min_temperature DECIMAL(5,2),                          -- أدنى درجة حرارة مدعومة
	max_temperature DECIMAL(5,2),                          -- أعلى درجة حرارة مدعومة
	temperature_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الحرارة

	-- الحالة والتدقيق
	is_active BOOLEAN DEFAULT TRUE,                        -- حالة التفعيل
	operational_status VARCHAR(20) DEFAULT 'operational',  -- الحالة التشغيلية (operational, maintenance, closed)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- إعدادات إضافية
	timezone VARCHAR(50),                                  -- المنطقة الزمنية للمستودع
	operating_hours JSONB,                                 -- ساعات العمل (مثل {"mon": "08:00-17:00", "tue": ...})
	custom_attributes JSONB                                -- سمات مخصصة لتخزين بيانات ديناميكية
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE zones (
	-- المعرفات الأساسية
	zone_id VARCHAR(15) PRIMARY KEY,                       -- معرف فريد للمنطقة
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- رابط المستودع
	zone_name VARCHAR(100) NOT NULL,                       -- اسم المنطقة
	zone_code VARCHAR(20) UNIQUE,                          -- رمز فريد للمنطقة

	-- الخصائص
	zone_type VARCHAR(50) NOT NULL CHECK (zone_type IN ('receiving', 'shipping', 'storage', 'picking', 'packing', 'staging')), -- نوع المنطقة
	description TEXT,                                      -- وصف تفصيلي
	area DECIMAL(10,2),                                    -- مساحة المنطقة
	area_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس المساحة
	capacity INTEGER,                                      -- السعة (عدد الوحدات/المنصات)
	priority INTEGER DEFAULT 0,                            -- أولوية المنطقة (للعمليات)

	-- الإحداثيات
	center_x DOUBLE PRECISION NOT NULL,  -- إحداثي X لمركز المنطقة -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	center_y DOUBLE PRECISION NOT NULL,  -- إحداثي Y لمركز المنطقة -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الإحداثيات

	-- التحكم البيئي
	temperature_controlled BOOLEAN DEFAULT FALSE,          -- هل المنطقة تدعم التحكم في درجة الحرارة؟
	min_temperature DECIMAL(5,2),                          -- أدنى درجة حرارة
	max_temperature DECIMAL(5,2),                          -- أعلى درجة حرارة
	temperature_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الحرارة
	-- الحالة والتدقيق
	is_active BOOLEAN DEFAULT TRUE,                        -- حالة التفعيل
	status VARCHAR(20) DEFAULT 'operational',              -- الحالة (operational, maintenance, blocked)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- إعدادات إضافية
	custom_attributes JSONB                               -- سمات مخصصة (مثل "عدد العاملين" أو "نوع الأرضية")
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE aisles (
	-- المعرفات الأساسية
	aisle_id VARCHAR(20) PRIMARY KEY,                      -- معرف فريد للممر
	zone_id VARCHAR(15) NOT NULL REFERENCES zones(zone_id), -- رابط المنطقة
	aisle_name VARCHAR(50) NOT NULL,                       -- اسم الممر
	aisle_code VARCHAR(20) UNIQUE,                         -- رمز فريد للممر

	-- الخصائص
	description TEXT,                                      -- وصف تفصيلي
	length DECIMAL(10,2),                                  -- طول الممر
	width DECIMAL(10,2),                                   -- عرض الممر
	height DECIMAL(10,2),                                  -- ارتفاع الممر
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الأبعاد
	capacity INTEGER,                                      -- السعة (عدد الرفوف/المنصات)
	aisle_direction VARCHAR(20),                           -- اتجاه الممر (north-south, east-west)

	-- الحالة والتدقيق
	is_active BOOLEAN DEFAULT TRUE,                        -- حالة التفعيل
	status VARCHAR(20) DEFAULT 'operational',              -- الحالة (operational, blocked)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- الإحداثيات
	start_x DOUBLE PRECISION NOT NULL,  										-- إحداثي X لبداية الممر -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	start_y DOUBLE PRECISION NOT NULL,  										-- إحداثي Y لبداية الممر -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	end_x DOUBLE PRECISION NOT NULL,    										-- إحداثي X لنهاية الممر -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	end_y DOUBLE PRECISION NOT NULL,    										-- إحداثي Y لنهاية الممر -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	center_x DOUBLE PRECISION,          										-- إحداثي X لمركز الممر (اختياري) -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	center_y DOUBLE PRECISION,          										-- إحداثي Y لمركز الممر (اختياري) -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), 	-- وحدة قياس الإحداثيات

	-- إعدادات إضافية
	custom_attributes JSONB                               -- سمات مخصصة
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE racks (
	-- المعرفات الأساسية
	rack_id VARCHAR(25) PRIMARY KEY,                       -- معرف فريد للرف
	aisle_id VARCHAR(20) NOT NULL REFERENCES aisles(aisle_id), -- رابط الممر
	rack_name VARCHAR(50) NOT NULL,                        -- اسم الرف
	rack_code VARCHAR(20) UNIQUE,                          -- رمز فريد للرف

	-- الخصائص
	rack_type VARCHAR(50) CHECK (rack_type IN ('pallet', 'shelving', 'cantilever', 'drive-in')), -- نوع الرف
	description TEXT,                                      -- وصف تفصيلي
	length DECIMAL(10,2),                                  -- طول الرف
	width DECIMAL(10,2),                                   -- عرض الرف
	height DECIMAL(10,2),                                  -- ارتفاع الرف
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الأبعاد
	max_weight DECIMAL(10,2),                              -- الحد الأقصى للوزن
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الوزن
	capacity INTEGER,                                      -- السعة (عدد المستويات/المنصات)
	rack_system VARCHAR(50),                            	-- نظام الرف (ثابت، متحرك، إلخ)
	total_levels INTEGER,                               	-- عدد المستويات

	-- الإحداثيات
	center_x DOUBLE PRECISION NOT NULL,  										-- إحداثي X لمركز الرف -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	center_y DOUBLE PRECISION NOT NULL,  										-- إحداثي Y لمركز الرف -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), 	-- وحدة قياس الإحداثيات

	-- الحالة والتدقيق
	is_active BOOLEAN DEFAULT TRUE,                        -- حالة التفعيل
	status VARCHAR(20) DEFAULT 'operational',              -- الحالة (operational, maintenance)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- إعدادات إضافية
	custom_attributes JSONB                               -- سمات مخصصة
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE levels (
	-- المعرفات الأساسية
	level_id VARCHAR(30) PRIMARY KEY,                      -- معرف فريد للمستوى
	rack_id VARCHAR(25) NOT NULL REFERENCES racks(rack_id), -- رابط الرف
	level_name VARCHAR(50) NOT NULL,                       -- اسم المستوى
	level_code VARCHAR(20) UNIQUE,                         -- رمز فريد للمستوى

	-- الخصائص
	level_number INT NOT NULL,                             -- رقم المستوى (1, 2, 3...)
	height DECIMAL(10,2),                                  -- ارتفاع المستوى
	height_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الارتفاع
	max_weight DECIMAL(10,2),                              -- الحد الأقصى للوزن
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الوزن
	length DECIMAL(10,2),                                  -- طول المستوى
	width DECIMAL(10,2),                                   -- عرض المستوى
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الأبعاد
	capacity INTEGER,                                      -- السعة (عدد المواقع/المنصات)

	-- الإحداثيات
	relative_x DOUBLE PRECISION,  												-- إحداثي X نسبي داخل الرف -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	relative_y DOUBLE PRECISION,  												-- إحداثي Y نسبي داخل الرف -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	z_position DOUBLE PRECISION,  												-- الموقع على محور Z (الارتفاع) -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), 	-- وحدة قياس الإحداثيات

	-- الحالة والتدقيق
	is_active BOOLEAN DEFAULT TRUE,                        -- حالة التفعيل
	status VARCHAR(20) DEFAULT 'operational',              -- الحالة (operational, blocked)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- إعدادات إضافية
	custom_attributes JSONB                               -- سمات مخصصة
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE locations (
	-- المعرفات الأساسية
	location_id VARCHAR(35) PRIMARY KEY,                   -- معرف فريد للموقع
	level_id VARCHAR(30) NOT NULL REFERENCES levels(level_id), -- رابط المستوى
	location_name VARCHAR(50) NOT NULL,                    -- اسم الموقع
	location_code VARCHAR(20) UNIQUE,                      -- رمز فريد للموقع

	-- الخصائص
	location_type VARCHAR(50) CHECK (location_type IN ('picking', 'storage', 'bulk', 'returns')), -- نوع الموقع
	position INT,                                          -- الموضع داخل المستوى (1, 2, 3...)
	barcode VARCHAR(50) UNIQUE,                            -- باركود لتحديد الموقع
	location_priority VARCHAR(50) CHECK (location_priority IN ('HIGH', 'MEDIUM', 'LOW')), -- لأولوية الموقع في عمليات الانتقاء. -- !! CHANGED: Mismatched check constraint name location_type corrected to location_priority

	--Bins > if we are use the bins table as bin can move with all goods -------------------------------------------------------
	-- current_bin_id VARCHAR(20) REFERENCES bins(bin_id), -- الصندوق الحالي (NULL إذا كان فارغاً) -- !! COMMENTED OUT: bins table not yet created

	--Bins > if we are not using the bins table as bin can move with all goods +++++++++++++++++++++++++++++++++++++++++++++++++
	bin_type VARCHAR(20), 									-- نوع الحاوية/الصندوق (يمكن إضافته هنا بدلاً من جدول منفصل)
	bin_volume DECIMAL(10,2), 								-- حجم الحاوية
	bin_max_weight DECIMAL(10,2), 							-- أقصى حمل للحاوية

	-- القياسات
	length DECIMAL(10,2),                                  -- طول الموقع
	width DECIMAL(10,2),                                   -- عرض الموقع
	height DECIMAL(10,2),                                  -- ارتفاع الموقع
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الأبعاد
	volume DECIMAL(10,2),                                  -- الحجم
	volume_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الحجم
	max_weight DECIMAL(10,2),                              -- الحد الأقصى للوزن
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الوزن

	-- الإحداثيات
	relative_x DOUBLE PRECISION,  												-- إحداثي X نسبي داخل المستوى -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	relative_y DOUBLE PRECISION,  												-- إحداثي Y نسبي داخل المستوى -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	z_position DOUBLE PRECISION,  												-- الموقع على محور Z (اختياري) -- !! CHANGED: data type DOUBLE to DOUBLE PRECISION
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), 	-- وحدة قياس الإحداثيات

	-- الحالة والتدقيق
	is_active BOOLEAN DEFAULT TRUE,                        -- حالة التفعيل
	status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'blocked')), -- حالة الموقع
	last_occupied_at TIMESTAMP,                            -- آخر تاريخ تم احتلاله
	last_vacated_at TIMESTAMP,                             -- آخر تاريخ تم إخلاؤه
	last_inventory_date TIMESTAMP,                      	-- تاريخ آخر جرد
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,        -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- إعدادات إضافية
	custom_attributes JSONB                               -- سمات مخصصة
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE bin_types (
	type_id VARCHAR(20) PRIMARY KEY, -- المعرف الفريد لنوع الصندوق
	type_code VARCHAR(10) UNIQUE NOT NULL, -- كود مختصر لنوع الصندوق
	type_name VARCHAR(50) NOT NULL, -- الاسم الرسمي للنوع
	description TEXT, -- وصف عام للنوع
	storage_class VARCHAR(20), -- فئة التخزين (A, B, C)

	-- المواصفات القياسية
	standard_length DECIMAL(6,2) NOT NULL, -- الطول القياسي بالسنتيمتر
	standard_width DECIMAL(6,2) NOT NULL, -- العرض القياسي بالسنتيمتر
	standard_height DECIMAL(6,2) NOT NULL, -- الارتفاع القياسي بالسنتيمتر
	standard_volume DECIMAL(10,2), -- الحجم القياسي (محسوب تلقائياً)
	standard_weight DECIMAL(10,2), -- الوزن القياسي للصندوق فارغ
	max_payload DECIMAL(10,2) NOT NULL, -- أقصى حمولة مسموحة

	-- خصائص التخزين
	is_stackable BOOLEAN DEFAULT TRUE, -- هل يمكن تكديس هذا النوع؟
	max_stack_count INTEGER DEFAULT 1, -- أقصى عدد للتكديس
	stackable_with JSONB, -- أنواع الصناديق التي يمكن تكديسها معها

	-- الخصائص المادية
	material VARCHAR(30) NOT NULL, -- المادة المصنوعة منها (بلاستيك، معدن، خشب)
	color VARCHAR(20), -- اللون الأساسي
	is_transparent BOOLEAN DEFAULT FALSE, -- هل الصندوق شفاف؟
	is_foldable BOOLEAN DEFAULT FALSE, -- هل يمكن طي الصندوق؟

	-- متطلبات خاصة
	requires_cleaning BOOLEAN DEFAULT FALSE, -- هل يحتاج تنظيفاً دورياً؟
	cleaning_frequency_days INTEGER, -- عدد الأيام بين كل تنظيف
	is_hazardous_material BOOLEAN DEFAULT FALSE, -- هل يستخدم للمواد الخطرة؟
	temperature_range VARCHAR(20), -- المدى الحراري (مثل "0-40 درجة")

	-- الترميز البصري
	default_barcode_prefix VARCHAR(10), -- بادئة باركود افتراضية
	default_color_code VARCHAR(10), -- كود لون افتراضي
	label_position VARCHAR(20), -- موقع الملصق (أعلى، جانب، إلخ)

	-- التكاليف والمعلومات المالية
	average_cost DECIMAL(12,2), -- متوسط سعر الشراء
	expected_lifespan_months INTEGER, -- العمر الافتراضي بالأشهر
	depreciation_rate DECIMAL(5,2), -- نسبة الإهلاك السنوية

	-- معلومات إضافية
	custom_fields JSONB, -- حقول مخصصة إضافية
	notes TEXT, -- ملاحظات إضافية

	-- التواريخ
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	is_active BOOLEAN DEFAULT TRUE, -- هل هذا النوع نشط؟
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed

	-- COMMENT ON TABLE bin_types IS 'جدول يحوي المواصفات القياسية لأنواع الصناديق المختلفة المستخدمة في المستودع';
);

CREATE TABLE bins (
	bin_id VARCHAR(20) PRIMARY KEY, -- المعرف الفريد للصندوق (مثل: BIN-001)
	bin_barcode VARCHAR(50) UNIQUE, -- الباركود الفريد للصندوق
	qr_code VARCHAR(50), -- كود QR للصندوق
	rfid_tag VARCHAR(50), -- رقم بطاقة RFID إن وجدت
	bin_name VARCHAR(100), -- اسم وصفي للصندوق
	bin_category VARCHAR(20), -- فئة الصندوق (قياسي، كبير، مبرد، إلخ)
	bin_status VARCHAR(20) DEFAULT 'متاح', -- (متاح، مشغول، معطّل، تحت الصيانة، مفقود)
	current_location_id VARCHAR(35) REFERENCES locations(location_id), -- الموقع الحالي للصندوق -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(35)
	bin_type VARCHAR(20) REFERENCES bin_types(type_id), -- نوع الصندوق

	-- المواصفات الفيزيائية
	length DECIMAL(6,2), -- الطول بالسنتيمتر
	width DECIMAL(6,2), -- العرض بالسنتيمتر
	height DECIMAL(6,2), -- الارتفاع بالسنتيمتر
	volume DECIMAL(10,2), -- الحجم بالمتر المكعب
	tare_weight DECIMAL(10,2), -- وزن الصندوق فارغ
	max_weight DECIMAL(10,2), -- أقصى وزن يحمله
	max_volume DECIMAL(10,2), -- أقصى حجم يستوعبه

	-- إضافة حقول للتحسين
	optimal_fill_percentage DECIMAL(5,2), -- النسبة المثالية للملء
	current_fill_percentage DECIMAL(5,2), -- النسبة الحالية للملء

	-- معلومات التصنيع
	manufacturer VARCHAR(100), -- اسم الشركة المصنعة
	manufacturing_date DATE, -- تاريخ التصنيع
	material VARCHAR(50), -- المادة المصنوع منها (بلاستيك، معدن، خشب)
	serial_number VARCHAR(50), -- الرقم التسلسلي

	-- معلومات السلامة
	is_hazardous BOOLEAN DEFAULT FALSE, -- هل يستخدم لمواد خطرة؟
	requires_cleaning BOOLEAN DEFAULT FALSE, -- هل يحتاج تنظيما دوريا؟
	last_cleaned_date DATE, -- تاريخ آخر تنظيف

	-- معلومات التتبع
	is_active BOOLEAN DEFAULT TRUE, -- هل الصندوق نشط؟
	owned_by VARCHAR(50), -- مالك الصندوق (قد يكون شركة أو قسم)
	purchase_date DATE, -- تاريخ الشراء
	purchase_price DECIMAL(12,2), -- سعر الشراء
	expected_lifespan_months INTEGER, -- العمر المتوقع بالأشهر

	-- معلومات إضافية
	custom_fields JSONB, -- حقول مخصصة إضافية
	notes TEXT, -- ملاحظات عامة

	-- التواريخ
	last_inventory_check TIMESTAMP, 												-- آخر تاريخ جرد للصندوق
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed

	--COMMENT ON TABLE bins IS 'جدول تفاصيل الصناديق/الحاويات القابلة للنقل في المستودع';
);

-- Now that 'bins' table exists, add the FK constraint to 'locations' if needed
-- ALTER TABLE locations ADD CONSTRAINT fk_location_bin FOREIGN KEY (current_bin_id) REFERENCES bins(bin_id); -- Uncomment if this column is used


CREATE TABLE bin_movements (
	movement_id BIGSERIAL PRIMARY KEY, -- رقم تسلسلي للحركة
	bin_id VARCHAR(20) NOT NULL REFERENCES bins(bin_id), -- الصندوق المنقول

	-- معلومات الموقع المصدر والهدف
	from_location_id VARCHAR(35) REFERENCES locations(location_id), -- الموقع الأصلي (قد يكون NULL لأول مرة) -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(35)
	from_location_type VARCHAR(20), -- نوع الموقع المصدر
	to_location_id VARCHAR(35) NOT NULL REFERENCES locations(location_id), -- الموقع الجديد -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(35)
	to_location_type VARCHAR(20), -- نوع الموقع الهدف

	-- تفاصيل الحركة
	movement_type VARCHAR(30) NOT NULL, -- (نقل، انتقاء، إعادة تخزين، جرد، تنظيف)
	movement_reason VARCHAR(100), -- سبب الحركة (تعديل مخزون، إعادة ترتيب، إلخ)
	movement_method VARCHAR(20), -- طريقة النقل (يدوي، روبوت، رافعة)

	-- المسؤول عن الحركة
    moved_by VARCHAR(36), -- المستخدم الذي قام بالنقل -- !! CHANGED: Removed FOREIGN KEY for initial creation
	team_id VARCHAR(20), -- الفريق المسؤول

	-- معلومات الجلسة/العملية
	session_id VARCHAR(50), -- جلسة العمل المرتبطة
	work_order_id VARCHAR(50), -- رقم أمر العمل
	reference_doc VARCHAR(50), -- مستند مرجعي (أمر تحويل، إلخ)

	-- بيانات الحركة
	distance_moved DECIMAL(10,2), -- المسافة المقطوعة بالأمتار
	movement_duration_seconds INTEGER, -- مدة الحركة بالثواني

	-- حالة الحركة
	status VARCHAR(20) DEFAULT 'مكتمل', -- (مخطط، قيد التنفيذ، مكتمل، فاشل)
	is_verified BOOLEAN DEFAULT FALSE, -- هل تم التحقق من الحركة؟
	verification_method VARCHAR(20), -- طريقة التحقق (بصمة، مسح، إلخ)
    approved_by VARCHAR(36), -- الشخص الذي وافق على المهمة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات إضافية
	equipment_used VARCHAR(50), -- المعدات المستخدمة (رافعة رقم X)
	temperature_at_move DECIMAL(5,2), -- درجة الحرارة أثناء النقل
	notes TEXT, -- ملاحظات إضافية
	custom_fields JSONB, -- حقول مخصصة
	-- movement_path GEOGRAPHY, -- مسار الحركة (للتتبع المكاني) -- !! COMMENTED OUT: Requires PostGIS extension
	movement_priority INTEGER, -- أولوية الحركة (1-10)

	-- التواريخ
	scheduled_time TIMESTAMP, -- الوقت المخطط للحركة
	movement_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- وقت التنفيذ الفعلي
	completed_time TIMESTAMP, -- وقت الانتهاء
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, moved_by, approved_by using ALTER TABLE later if needed

	-- COMMENT ON TABLE bin_movements IS 'جدول تفاصيل حركات الصناديق بين المواقع في المستودع';
);

CREATE TABLE bin_contents (
	content_id BIGSERIAL PRIMARY KEY, -- المعرف الفريد لمحتوى الصندوق
	bin_id VARCHAR(20) NOT NULL REFERENCES bins(bin_id), -- الصندوق المرتبط
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- المنتج المخزّن
	batch_number VARCHAR(50), -- رقم الدفعة (إن وجد)
	serial_number VARCHAR(50), -- الرقم التسلسلي (إن وجد)

	-- معلومات الكمية
	quantity DECIMAL(10,2) NOT NULL, -- الكمية الحالية
	uom VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس

	min_quantity DECIMAL(10,2), -- الحد الأدنى للكمية
	max_quantity DECIMAL(10,2), -- الحد الأقصى للكمية

	-- معلومات التخزين
	storage_condition VARCHAR(20), -- ظروف التخزين (عادي، مبرد، مجمد)
	putaway_date TIMESTAMP, -- تاريخ التخزين الأول
	last_accessed TIMESTAMP, -- تاريخ آخر وصول
	expiration_date DATE, -- تاريخ انتهاء الصلاحية

	-- معلومات الجودة
	quality_status VARCHAR(20) DEFAULT 'جيد', -- حالة الجودة
	inspection_required BOOLEAN DEFAULT FALSE, -- هل يحتاج فحصاً؟
	last_inspection_date TIMESTAMP, -- تاريخ آخر فحص
	inspection_due_date DATE, -- تاريخ الفحص القادم

	-- معلومات التتبع
	source_document VARCHAR(50), -- المستند المصدر (أمر شراء، إلخ)
	source_reference VARCHAR(50), -- المرجع المصدر
	is_locked BOOLEAN DEFAULT FALSE, -- هل المحتوى مقفل؟
	lock_reason TEXT, -- سبب القفل

	-- إضافة حقول للتحليل
	turnover_rate DECIMAL(10,2), -- معدل الدوران
	days_in_stock INTEGER, -- الأيام في المخزون

	-- معلومات إضافية
	custom_fields JSONB, -- حقول مخصصة
	notes TEXT, -- ملاحظات
	last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed

	-- القيود
	CONSTRAINT positive_quantity CHECK (quantity >= 0),
	UNIQUE(bin_id, product_id, batch_number, serial_number) -- لمنع التكرار

	-- COMMENT ON TABLE bin_contents IS 'جدول تفصيلي لمحتويات الصناديق يُظهر العلاقة بين الصناديق والمنتجات المخزنة فيها';
);

CREATE TABLE inventory (
	-- المفاتيح الأساسية والهويات
	inventory_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لسجل المخزون
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- رقم تعريف المنتج (مرتبط بجدول المنتجات)
	location_id VARCHAR(35) NOT NULL REFERENCES locations(location_id), -- رقم تعريف الموقع (مرتبط بجدول المواقع)

	-- معلومات الكميات والمقاييس
	quantity DECIMAL(10,2) NOT NULL, -- الكمية المتوفرة حالياً
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس (مرتبط بجدول وحدات القياس)
	min_stock_level DECIMAL(10,2), -- الحد الأدنى للكمية المسموح بها
	max_stock_level DECIMAL(10,2), -- الحد الأقصى للكمية المسموح بها
	reorder_point DECIMAL(10,2), -- نقطة إعادة الطلب

	-- معلومات التتبع
	lot_number VARCHAR(50), -- رقم الدفعة (للتتبع بالدفعات)
	serial_number VARCHAR(50), -- الرقم التسلسلي (للتتبع الفردي)

	-- معلومات التواريخ
	production_date DATE, -- تاريخ تصنيع المنتج
	expiry_date DATE, -- تاريخ انتهاء الصلاحية
	last_movement_date TIMESTAMP, -- تاريخ آخر حركة للمخزون

	-- حالة المخزون
	status VARCHAR(20) DEFAULT 'available', -- الحالة (متاح/محجوز/تالف/منتهي)
	is_active BOOLEAN DEFAULT TRUE, -- نشط أو غير نشط
	quality_status VARCHAR(20), -- تقييم الجودة (جيد/معيب/إلخ)

	-- معلومات التخزين
	temperature_zone VARCHAR(20), -- متطلبات التخزين (عادي/مبرد/مجمد)
	weight DECIMAL(10,2), -- وزن الوحدة
	dimensions VARCHAR(50), -- الأبعاد (طول×عرض×ارتفاع)
	hazard_class VARCHAR(20), -- تصنيف الخطورة إن وجد

	-- معلومات المورد والملكية
	owner_id VARCHAR(36), -- مالك المخزون (للشركات المتعددة)
	supplier_id VARCHAR(36), -- المورد الأساسي لهذا الصنف

	-- معلومات الجمارك
	customs_info TEXT, -- بيانات جمركية للمستوردات

	-- معلومات التعريف
	barcode VARCHAR(50), -- باركود الصنف
	rfid_tag VARCHAR(50), -- بطاقة RFID

	-- معلومات المراجعة والموافقة
	last_audit_date DATE, -- تاريخ آخر مراجعة
	audit_notes TEXT, -- ملاحظات المراجعة
	approval_date TIMESTAMP, -- تاريخ الموافقة
    approved_by VARCHAR(36), -- الشخص الذي وافق على المهمة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات السجل الزمني
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- وقت إنشاء السجل
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- وقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, approved_by using ALTER TABLE later if needed
);

CREATE TABLE inventory_movements (
	-- المفاتيح الأساسية والهويات
	movement_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لحركة المخزون
	inventory_id VARCHAR(36) NOT NULL REFERENCES inventory(inventory_id), -- رقم العنصر في المخزون (مرتبط بجدول المخزون)

	-- معلومات المواقع
	source_location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع المنشأ (مرتبط بجدول المواقع)
	destination_location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع الوجهة (مرتبط بجدول المواقع)

	-- معلومات الكميات والنقل
	quantity DECIMAL(10,2) NOT NULL, -- الكمية المنقولة
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس (مرتبط بجدول وحدات القياس)
	movement_type VARCHAR(20) NOT NULL, -- نوع الحركة (استلام/صرف/نقل/تعديل)
	movement_reason VARCHAR(50), -- سبب الحركة (تعديل/تصحيح/صرف عادي)

	-- معلومات المراجع
	reference_id VARCHAR(36), -- رقم المستند المرجعي (أمر شراء/بيع/إلخ)
	reference_type VARCHAR(20), -- نوع المستند المرجعي
	batch_number VARCHAR(50), -- رقم الدفعة إن وجد

	-- معلومات التنفيذ
	movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التنفيذ
    performed_by VARCHAR(36), -- المسؤول عن التنفيذ (مرتبط بجدول المستخدمين) -- !! CHANGED: Removed FOREIGN KEY for initial creation
	system_generated BOOLEAN DEFAULT FALSE, -- هل الحركة تلقائية؟

	-- معلومات الموافقة
	approval_status VARCHAR(20) DEFAULT 'pending', -- حالة الموافقة (معلق/معتمد/مرفوض)
	approval_date TIMESTAMP, -- تاريخ الموافقة
    approved_by VARCHAR(36), -- الشخص الذي وافق على المهمة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- المعلومات المالية
	transaction_value DECIMAL(12,2), -- القيمة المالية للحركة
	currency VARCHAR(3), -- العملة المستخدمة
	movement_cost DECIMAL(10,2), -- تكلفة تنفيذ الحركة

	-- معلومات النقل والشحن
	transport_mode VARCHAR(20), -- وسيلة النقل المستخدمة
	carrier_id VARCHAR(36), -- معرف الناقل
	tracking_number VARCHAR(50), -- رقم تتبع الشحنة
	expected_arrival TIMESTAMP, -- تاريخ الوصول المتوقع
	actual_arrival TIMESTAMP, -- تاريخ الوصول الفعلي

	-- معلومات السجل
	notes TEXT, -- ملاحظات إضافية
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, performed_by, approved_by using ALTER TABLE later if needed
);

CREATE TABLE inventory_counts (
	-- المفاتيح الأساسية والهويات
	count_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لعملية الجرد
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- المستودع المستهدف (مرتبط بجدول المستودعات)

	-- معلومات أساسية عن الجرد
	count_name VARCHAR(100), -- اسم أو وصف عملية الجرد
	count_type VARCHAR(20) NOT NULL, -- نوع الجرد (دوري/كامل/جزئي)
	status VARCHAR(20) DEFAULT 'planned', -- حالة العملية (مخطط/قيد التنفيذ/مكتمل/ملغى)

	-- تواريخ الجرد
	start_date TIMESTAMP, -- تاريخ البدء الفعلي
	end_date TIMESTAMP, -- تاريخ الانتهاء الفعلي
	expected_completion TIMESTAMP, -- التاريخ المتوقع للانتهاء

	-- معلومات الفريق
	team_leader VARCHAR(36), -- قائد فريق الجرد -- !! CHANGED: Removed FOREIGN KEY for initial creation
	count_team TEXT, -- قائمة أعضاء فريق الجرد

	-- إعدادات الجرد
	count_method VARCHAR(20), -- طريقة الجرد (يدوي/ماسح ضوئي/إلخ)
	count_frequency VARCHAR(20), -- التكرار (يومي/أسبوعي/شهري/إلخ)
	count_zone VARCHAR(20), -- المنطقة المستهدفة في المستودع
	count_category VARCHAR(20), -- الفئة المستهدفة (صنف معين/كل الأصناف)
	variance_threshold DECIMAL(5,2), -- نسبة التباين المقبولة

	-- معلومات الموافقة
	is_approved BOOLEAN DEFAULT FALSE, -- حالة الموافقة على الجرد
	approved_at TIMESTAMP, -- تاريخ الموافقة
    approved_by VARCHAR(36), -- المسؤول عن الموافقة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات الجرد المعاد
	is_recount BOOLEAN DEFAULT FALSE, -- هل هذه عملية جرد معاد؟
	original_count_id VARCHAR(36), -- معرف الجرد الأصلي في حال كان معاداً

	-- معلومات إضافية
	priority VARCHAR(10), -- مستوى الأولوية (عالي/متوسط/منخفض)
	notes TEXT, -- ملاحظات وملاحظات إضافية

	-- معلومات السجل الزمني
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء السجل
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, team_leader, approved_by using ALTER TABLE later if needed
);

CREATE TABLE inventory_count_details (
	-- المفاتيح الأساسية والهويات
	count_detail_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لتفاصيل الجرد
	count_id VARCHAR(36) NOT NULL REFERENCES inventory_counts(count_id), -- معرف عملية الجرد (مرتبط بجدول الجرد)
	inventory_id VARCHAR(36) NOT NULL REFERENCES inventory(inventory_id), -- معرف العنصر في المخزون (مرتبط بجدول المخزون)

	-- معلومات الكميات
	expected_quantity DECIMAL(10,2), -- الكمية المتوقعة حسب السجلات
	counted_quantity DECIMAL(10,2), -- الكمية الفعلية المعدودة
	recount_quantity DECIMAL(10,2), -- الكمية في حالة إعادة العد
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس (مرتبط بجدول وحدات القياس)

	-- معلومات التباين
	variance DECIMAL(10,2), -- الفرق بين المتوقع والمعدود
	variance_percentage DECIMAL(10,2), -- نسبة التباين بين المتوقع والمعدود

	-- معلومات عملية العد
	status VARCHAR(20) DEFAULT 'pending', -- حالة العد (معلق/معدود/معدل)
	count_method VARCHAR(20), -- الطريقة المستخدمة في العد
	device_id VARCHAR(36), -- الجهاز المستخدم في عملية العد

	-- معلومات المسؤولين عن العد
    counted_by VARCHAR(36), -- الشخص الذي قام بالعد الأولي -- !! CHANGED: Removed FOREIGN KEY for initial creation
	counted_at TIMESTAMP, -- تاريخ ووقت العد الأولي
    recount_by VARCHAR(36), -- المسؤول عن إعادة العد -- !! CHANGED: Removed FOREIGN KEY for initial creation
	recount_at TIMESTAMP, -- تاريخ ووقت إعادة العد
	recount_status VARCHAR(20), -- حالة عملية إعادة العد

	-- معلومات التعديلات
	adjustment_id VARCHAR(36), -- معرف سجل التعديل
    adjustment_by VARCHAR(36), -- المسؤول عن التعديل -- !! CHANGED: Removed FOREIGN KEY for initial creation
	adjustment_date TIMESTAMP, -- تاريخ التعديل

	-- معلومات التحقق
	location_verified BOOLEAN, -- هل تم التحقق من صحة الموقع؟
	batch_verified BOOLEAN, -- هل تم التحقق من صحة الدفعة؟
	expiry_verified BOOLEAN, -- هل تم التحقق من تاريخ الصلاحية؟
	item_condition VARCHAR(20), -- حالة العنصر أثناء العد (جيد/تالف/إلخ)

	-- معلومات إضافية
	notes TEXT, -- ملاحظات إضافية حول عملية العد

	-- معلومات السجل الزمني
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء السجل
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, counted_by, recount_by, adjustment_by using ALTER TABLE later if needed
);

CREATE TABLE inventory_reservations (
	-- المعلومات الأساسية
	reservation_id VARCHAR(36) PRIMARY KEY,
	reservation_number VARCHAR(50) UNIQUE NOT NULL,

	-- العلاقات بالجداول الأخرى
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	inventory_id VARCHAR(36) REFERENCES inventory(inventory_id),
	location_id VARCHAR(35) REFERENCES locations(location_id),

	-- معلومات الكمية
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),

	-- معلومات الحجز
	reservation_type VARCHAR(20) NOT NULL CHECK (reservation_type IN ('sale', 'transfer', 'production', 'quality_check')),
	status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'released', 'fulfilled', 'cancelled')),

	-- المراجع
	reference_id VARCHAR(36), -- يمكن أن يكون order_id, transfer_id, etc.
	reference_type VARCHAR(30), -- نوع المرجع مثل 'sales_order', 'purchase_order'

	-- التواريخ
	reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	expires_at TIMESTAMP,
	released_at TIMESTAMP,

	-- معلومات المستخدم
	reserved_by VARCHAR(36) NOT NULL, -- !! CHANGED: Removed FOREIGN KEY for initial creation
	released_by VARCHAR(36), -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات إضافية
	notes TEXT,
	priority INTEGER DEFAULT 5,

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, reserved_by, released_by using ALTER TABLE later if needed

	-- القيود
	CONSTRAINT chk_inv_res_quantity CHECK (quantity > 0), -- Renamed constraint
	CONSTRAINT chk_inv_res_dates CHECK (expires_at IS NULL OR expires_at > reserved_at) -- Renamed constraint
);

CREATE TABLE transport_unit_types (
	-- الأعمدة الأساسية
	tu_type_id VARCHAR(20) PRIMARY KEY, -- المعرف الفريد لنوع وحدة النقل
	type_name VARCHAR(50) NOT NULL, -- اسم نوع وحدة النقل
	description TEXT, -- وصف لنوع وحدة النقل

	-- أبعاد الوحدة
	length DECIMAL(10,2), -- الطول لوحدة النقل
	width DECIMAL(10,2), -- العرض لوحدة النقل
	height DECIMAL(10,2), -- الارتفاع لوحدة النقل
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الأبعاد (متر، قدم، إلخ)
	volume DECIMAL(10,2), -- الحجم الإجمالي لوحدة النقل (حسابياً)
	volume_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الحجم

	-- مواصفات الوزن
	max_weight DECIMAL(10,2), -- الحد الأقصى للوزن الذي تتحمله وحدة النقل
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة قياس الوزن (كجم، رطل، إلخ)

	-- معلومات التصنيع
	manufacturer VARCHAR(100), -- الشركة المصنعة لوحدة النقل
	model VARCHAR(50), -- موديل وحدة النقل
	material VARCHAR(50), -- المادة المصنوعة منها وحدة النقل
	color VARCHAR(20), -- لون وحدة النقل

	-- معلومات إدارية
	is_active BOOLEAN DEFAULT TRUE, -- حالة النشاط (نشط/غير نشط)
	image_url TEXT, -- رابط صورة وحدة النقل
	custom_fields JSONB, -- حقول مخصصة إضافية

	-- أعمدة التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE IF NOT EXISTS transport_units (
	-- ********** الأعمدة الأساسية والهوية **********
	tu_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لوحدة النقل
	tu_type_id VARCHAR(20) NOT NULL REFERENCES transport_unit_types(tu_type_id), -- نوع وحدة النقل (مرجعي)
	tu_code VARCHAR(50) UNIQUE, -- كود وحدة النقل (مسلسل)
	barcode VARCHAR(50), -- الباركود لوحدة النقل

	-- ********** التصنيف والأنواع **********
	class_type VARCHAR(20) REFERENCES class_types(class_type_id), -- نوع الفئة التي تنتمي إليها الوحدة (مرجعي)
	product_velocity VARCHAR(20), -- سرعة تداول المنتج (عالية/متوسطة/منخفضة)

	-- ********** الموقع والإحداثيات **********
	current_location_id VARCHAR(35) REFERENCES locations(location_id), -- الموقع الحالي (مرجعي)
	zone_id VARCHAR(15) REFERENCES zones(zone_id), -- المنطقة الحالية (مرجعي) -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(15)
	x_position DECIMAL(10,2), -- الموقع الأفقي في المستودع
	y_position DECIMAL(10,2), -- الموقع الرأسي في المستودع
	z_position DECIMAL(10,2), -- الموقع العمودي (الارتفاع)
	orientation VARCHAR(10) REFERENCES tu_orientation_types(orientation_code), -- اتجاه/توجيه الوحدة (مرجعي)

	-- ********** الحالة والتتبع **********
	status VARCHAR(20) DEFAULT 'available', -- الحالة (متاح، مستخدم، تالف، معطل)
	status_date TIMESTAMP, -- تاريخ آخر تغيير للحالة
	yard_process_status VARCHAR(30), -- حالة المعالجة في الساحة
	transaction_count INTEGER DEFAULT 0, -- عدد العمليات على الوحدة
	last_move_date TIMESTAMP, -- تاريخ آخر حركة للوحدة

	-- ********** العلاقات والارتباطات **********
	parent_tu_id VARCHAR(36) REFERENCES transport_units(tu_id), -- الوحدة الأم (للوحدات المتداخلة)
	owner_id VARCHAR(36), -- المالك/المشغل للوحدة (مرجعي) -- !! CHANGED: Removed FOREIGN KEY for initial creation
	order_id VARCHAR(36), -- معرف الأمر المرتبط
	order_tu_plan_id VARCHAR(36), -- معرف خطة توزيع الوحدات للأمر
	shipment_id VARCHAR(36), -- معرف الشحنة المرتبطة
	shipping_lane_request_id VARCHAR(36), -- معرف مسار الشحن

	-- ********** عمليات التصنيع والصيانة **********
	manufacturing_date DATE, -- تاريخ التصنيع
	expected_lifespan INTEGER, -- العمر الافتراضي بالسنوات
	last_maintenance_date DATE, -- تاريخ آخر صيانة
	next_maintenance_date DATE, -- تاريخ الصيانة القادمة
	inspection_notes TEXT, -- ملاحظات التفتيش
	pick_confirmation_posted BOOLEAN DEFAULT FALSE, -- تأكيد استلام البضاعة
	order_process_status VARCHAR(30), -- حالة معالجة الأمر

	-- ********** المعلومات المالية والتأجير **********
	purchase_cost DECIMAL(15,2), -- تكلفة شراء وحدة النقل
	current_value DECIMAL(15,2), -- القيمة الحالية لوحدة النقل
	depreciation_rate DECIMAL(5,2), -- معدل الإهلاك السنوي
	is_leased BOOLEAN DEFAULT FALSE, -- هل الوحدة مؤجرة؟
	lease_expiry_date DATE, -- تاريخ انتهاء الإيجار

	-- ********** معلومات إدارية **********
	is_active BOOLEAN DEFAULT TRUE, -- حالة النشاط (نشط/غير نشط)
	image_url TEXT, -- رابط صورة وحدة النقل
	custom_fields JSONB, -- حقول مخصصة إضافية

	-- ********** أعمدة التتبع **********
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, owner_id using ALTER TABLE later if needed
);

CREATE TABLE transport_unit_contents (
	-- الأعمدة الأساسية
	content_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للمحتوى
	tu_id VARCHAR(36) NOT NULL REFERENCES transport_units(tu_id), -- وحدة النقل التي تحتوي على الصنف
	inventory_id VARCHAR(36) NOT NULL REFERENCES inventory(inventory_id), -- الصنف المخزني

	-- معلومات الكمية
	quantity DECIMAL(10,2) NOT NULL, -- الكمية
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس

	-- معلومات التتبع
	batch_number VARCHAR(50), -- رقم الدفعة
	serial_number VARCHAR(50), -- الرقم المسلسل للصنف
	expiry_date DATE, -- تاريخ انتهاء الصلاحية (للأصناف القابلة للانتهاء)

	-- معلومات الحالة
	status VARCHAR(20), -- حالة المحتوى (جيد، تالف، منتهي الصلاحية)
	notes TEXT, -- ملاحظات
    added_by VARCHAR(36), -- المستخدم الذي أضاف المحتوى -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات الإضافة والإزالة
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإضافة
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	removal_reason TEXT, -- سبب الإزالة

	-- معلومات إضافية
	custom_fields JSONB, -- حقول مخصصة إضافية

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, added_by using ALTER TABLE later if needed
);

CREATE TABLE business_partners (
	-- المعلومات الأساسية
	partner_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للشريك
	partner_name VARCHAR(100) NOT NULL, -- اسم الشريك التجاري
	partner_code VARCHAR(50) UNIQUE, -- كود الشريك (فريد)
	partner_type VARCHAR(20) NOT NULL, -- نوع الشريك (مورد، عميل، ناقل، إلخ)

	-- معلومات الاتصال الأساسية
	contact_person VARCHAR(100), -- اسم الشخص المسؤول عن التواصل
	contact_email VARCHAR(100), -- البريد الإلكتروني للتواصل
	contact_phone VARCHAR(20), -- رقم هاتف التواصل
	fax_number VARCHAR(20), -- رقم الفاكس
	website VARCHAR(100), -- موقع الويب للشريك

	-- العنوان الرئيسي
	address TEXT, -- العنوان الرئيسي
	city VARCHAR(50), -- المدينة
	state VARCHAR(50), -- المحافظة/الولاية
	country VARCHAR(50), -- الدولة
	postal_code VARCHAR(20), -- الرمز البريدي

	-- المعلومات المالية
	tax_id VARCHAR(50), -- الرقم الضريبي
	payment_terms VARCHAR(50), -- شروط الدفع
	credit_limit DECIMAL(15,2), -- الحد الائتماني المسموح للشريك
	currency VARCHAR(3), -- العملة المستخدمة في التعامل مع الشريك

	-- معلومات البنك
	bank_name VARCHAR(100), -- اسم البنك
	bank_account VARCHAR(50), -- رقم الحساب البنكي
	iban VARCHAR(50), -- رقم الآيبان
	swift_code VARCHAR(20), -- كود السويفت

	-- العلاقات والتسلسل الهرمي
	parent_partner_id VARCHAR(36) REFERENCES business_partners(partner_id), -- معرف الشريك الرئيسي (في حالة الفروع)

	-- التصنيفات
	is_vendor BOOLEAN DEFAULT FALSE, -- هل هو مورد؟
	is_customer BOOLEAN DEFAULT FALSE, -- هل هو عميل؟
	is_carrier BOOLEAN DEFAULT FALSE, -- هل هو ناقل؟
	is_active BOOLEAN DEFAULT TRUE, -- هل الشريك نشط؟

	-- ملاحظات إضافية
	notes TEXT, -- ملاحظات إضافية

	-- معلومات التتبع والسجلات
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ آخر تعديل
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE partner_addresses (
	-- المعرفات والعلاقات
	address_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للعنوان
	partner_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id), -- المعرف الفريد للشريك

	-- نوع العنوان
	address_type VARCHAR(20) NOT NULL, -- نوع العنوان (فوترة، شحن، إلخ)
	address_name VARCHAR(100), -- اسم وصف للعنوان
	is_default BOOLEAN DEFAULT FALSE, -- هل هو العنوان الافتراضي؟

	-- تفاصيل العنوان
	address_line1 TEXT NOT NULL, -- السطر الأول من العنوان
	address_line2 TEXT, -- السطر الثاني من العنوان
	city VARCHAR(50) NOT NULL, -- المدينة
	state VARCHAR(50), -- المحافظة/الولاية
	country VARCHAR(50) NOT NULL, -- الدولة
	postal_code VARCHAR(20), -- الرمز البريدي

	-- الإحداثيات الجغرافية
	latitude DECIMAL(10,8), -- خط العرض الجغرافي
	longitude DECIMAL(11,8), -- خط الطول الجغرافي
	directions TEXT, -- إرشادات الوصول للعنوان

	-- معلومات الاتصال لهذا العنوان
	contact_person VARCHAR(100), -- اسم الشخص المسؤول في هذا العنوان
	contact_email VARCHAR(100), -- البريد الإلكتروني للتواصل لهذا العنوان
	contact_phone VARCHAR(20), -- رقم هاتف التواصل لهذا العنوان

	-- حالة العنوان
	is_active BOOLEAN DEFAULT TRUE, -- هل العنوان نشط؟

	-- ملاحظات إضافية
	notes TEXT, -- ملاحظات إضافية

	-- معلومات التتبع والسجلات
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ آخر تعديل
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE purchase_orders (
-- source_type -- cancellation_reason -- tax_included
	-- المعلومات الأساسية
	po_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لأمر الشراء
	po_number VARCHAR(50) UNIQUE NOT NULL, -- رقم أمر الشراء (فريد)
	supplier_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id), -- المرجع للمورد من جدول الشركاء
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- المستودع المستلم للبضاعة
	source_type VARCHAR(10) NOT NULL, -- لتحديد مصدر الأمر (مثل "يدوي"، "نظام ERP"، "طلب تلقائي").

	-- التواريخ
	order_date DATE NOT NULL, -- تاريخ إنشاء الأمر
	expected_delivery_date DATE, -- تاريخ التسليم المتوقع
	actual_delivery_date DATE, -- تاريخ التسليم الفعلي

	-- الحالة والموافقة
	status VARCHAR(20) DEFAULT 'draft', -- حالة الأمر (مسودة/مؤكد/مستلم/ملغي)
	approval_status VARCHAR(20), -- حالة الموافقة
	approved_at TIMESTAMP, -- تاريخ الموافقة
    approved_by VARCHAR(36), -- الشخص الذي قام بالموافقة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- المعلومات المالية
	total_amount DECIMAL(15,2), -- القيمة الإجمالية قبل الضريبة
	tax_amount DECIMAL(15,2), -- قيمة الضريبة المضافة
	discount_amount DECIMAL(15,2), -- قيمة الخصم إن وجد
	currency VARCHAR(3) DEFAULT 'SAR', -- العملة الافتراضية ريال سعودي
	tax_included BOOLEAN DEFAULT FALSE, -- للإشارة إلى ما إذا كان المبلغ الإجمالي (total_amount) يشمل الضريبة أم لا، مما يوضح الحسابات المالية.

	-- شروط التعاقد
	payment_terms VARCHAR(50), -- شروط الدفع
	shipping_terms VARCHAR(50), -- شروط الشحن
	incoterms VARCHAR(20), -- شروط التجارة الدولية

	-- معلومات إضافية
	priority VARCHAR(10) DEFAULT 'normal', -- أولوية الطلب
	source_document VARCHAR(100), -- مستند مرجعي (طلب شراء/عرض سعر)
	cancellation_reason TEXT, -- إذا تم إلغاء الأمر (status = 'cancelled')، يمكن تسجيل سبب الإلغاء لأغراض التوثيق والتحليل.

	-- الملاحظات
	notes TEXT, -- ملاحظات عامة
	internal_notes TEXT, -- ملاحظات داخلية

	-- بيانات التعقب
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	closed_at TIMESTAMP, -- تاريخ الإقفال
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	revision_number INT DEFAULT 0, -- لتتبع عدد المرات التي تم فيها تعديل أمر الشراء (مثل تغيير الكميات أو الشروط).

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, approved_by using ALTER TABLE later if needed
);

CREATE TABLE purchase_order_items (
	-- المعرفات
	po_item_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للصنف
	po_id VARCHAR(36) NOT NULL REFERENCES purchase_orders(po_id), -- المرجع لأمر الشراء
	line_number INT NOT NULL, -- رقم السطر في الأمر

	-- معلومات المنتج
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- المنتج المرجعي
	product_name VARCHAR(100), -- اسم المنتج (نسخة احتياطية)
	product_code VARCHAR(50), -- كود المنتج (نسخة احتياطية)
	supplier_product_code VARCHAR(50),	-- قد يستخدم المورد كودًا مختلفًا للمنتج عن الكود الداخلي
	quality_inspection_status VARCHAR(20), -- لتتبع حالة فحص الجودة للكمية المستلمة (مثل "قيد الفحص"، "مقبول"، "مرفوض")

	-- الكميات
	ordered_quantity DECIMAL(10,2) NOT NULL, -- الكمية المطلوبة
	received_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المستلمة
	rejected_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المرفوضة

	-- الحسابات المولدة
	remaining_quantity DECIMAL(10,2) GENERATED ALWAYS AS (ordered_quantity - received_quantity) STORED, -- الكمية المتبقية

	-- وحدة القياس
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس المرجعية
	uom_name VARCHAR(50), -- اسم الوحدة (نسخة احتياطية)

	-- المعلومات المالية
	unit_price DECIMAL(15,2) NOT NULL, -- سعر الوحدة
	tax_rate DECIMAL(5,2) DEFAULT 0.15, -- نسبة الضريبة (15% افتراضيا)
	tax_amount DECIMAL(15,2), -- قيمة الضريبة
	discount_percent DECIMAL(5,2), -- نسبة الخصم
	discount_amount DECIMAL(15,2), -- قيمة الخصم
	total_price DECIMAL(15,2) NOT NULL, -- السعر الإجمالي للسطر

	-- معلومات التسليم
	expected_delivery_date DATE, -- تاريخ التسليم المتوقع
	actual_delivery_date DATE, -- تاريخ التسليم الفعلي
	reason_for_rejection TEXT, -- إذا كانت هناك كمية مرفوضة (rejected_quantity)، يمكن توثيق السبب (مثل "تالف"، "غير مطابق").

	-- حالة الصنف
	status VARCHAR(20) DEFAULT 'pending', -- حالة السطر (معلق/مستلم/ملغي)
	inventory_status VARCHAR(20), -- حالة التخزين

	-- معلومات التخزين
	location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع التخزين -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(35) and column name shelf_id to location_id
	batch_number VARCHAR(50), -- رقم الدفعة
	expiry_date DATE, -- تاريخ الانتهاء

	-- ملاحظات
	notes TEXT, -- ملاحظات خاصة بالسطر

	-- بيانات التعقب
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE sales_orders (
	-- المعلومات الأساسية
	so_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لأمر البيع
	so_number VARCHAR(50) UNIQUE NOT NULL, -- رقم أمر البيع (فريد)
	customer_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id), -- العميل المرجعي
	customer_po_number VARCHAR(50), -- رقم طلب العميل
	order_type VARCHAR(20), -- لتحديد نوع أمر البيع (مثل "تجزئة"، "جملة"، "تصدير"). يساعد في تصنيف الأوامر وتحليلها.

	-- معلومات المستودع
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- المستودع المسحب منه

	-- التواريخ
	order_date DATE NOT NULL, -- تاريخ إنشاء الأمر
	requested_delivery_date DATE, -- تاريخ التسليم المطلوب
	promised_delivery_date DATE, -- تاريخ التسليم الموعود
	actual_delivery_date DATE, -- تاريخ التسليم الفعلي

	-- العناوين
	shipping_address_id VARCHAR(36) REFERENCES partner_addresses(address_id), -- عنوان الشحن
	billing_address_id VARCHAR(36) REFERENCES partner_addresses(address_id), -- عنوان الفاتورة

	-- معلومات المندوب
	sales_rep_id VARCHAR(36), -- مندوب المبيعات -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- الحالة والموافقة
	status VARCHAR(20) DEFAULT 'draft', -- حالة الطلب
	approval_status VARCHAR(20), -- حالة الموافقة
	approved_at TIMESTAMP, -- تاريخ الموافقة
    approved_by VARCHAR(36), -- الشخص الذي قام بالموافقة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- المعلومات المالية
	total_amount DECIMAL(15,2), -- المبلغ الإجمالي
	tax_amount DECIMAL(15,2), -- قيمة الضريبة
	discount_amount DECIMAL(15,2), -- قيمة الخصم
	currency VARCHAR(3) DEFAULT 'SAR', -- العملة

	-- معلومات الدفع
	payment_terms VARCHAR(50), -- شروط الدفع
	payment_status VARCHAR(20) DEFAULT 'unpaid', -- حالة الدفع

	-- معلومات الشحن
	shipping_method VARCHAR(50), -- طريقة الشحن
	shipping_status VARCHAR(20), -- حالة الشحن
	carrier_id VARCHAR(36) REFERENCES business_partners(partner_id), -- شركة الشحن
	tracking_number VARCHAR(100), -- رقم التتبع
	freight_charge DECIMAL(15,2), -- تكلفة الشحن

	-- معلومات إضافية
	priority VARCHAR(10) DEFAULT 'normal', -- أولوية الطلب
	source_document VARCHAR(100), -- مستند مرجعي
	return_status VARCHAR(20), -- للإشارة إلى ما إذا كان هناك مرتجعات مرتبطة بالأمر (مثل "لا يوجد"، "جزئي"، "كامل"). مفيد لإدارة المرتجعات.
	channel VARCHAR(20), -- لتحديد قناة البيع (مثل "موقع إلكتروني"، "متجر"، "تطبيق"). هذا مهم في الأنظمة متعددة القنوات.

	-- الملاحظات
	notes TEXT, -- ملاحظات عامة
	internal_notes TEXT, -- ملاحظات داخلية

	-- بيانات التعقب
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	closed_at TIMESTAMP, -- تاريخ الإقفال

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, sales_rep_id, approved_by using ALTER TABLE later if needed
);

CREATE TABLE sales_order_items (
	-- المعرفات
	so_item_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للسطر
	so_id VARCHAR(36) NOT NULL REFERENCES sales_orders(so_id), -- المرجع لأمر البيع
	line_number INT NOT NULL, -- رقم السطر في الأمر

	-- معلومات المنتج
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- المنتج المرجعي
	product_name VARCHAR(100), -- اسم المنتج (نسخة احتياطية)
	product_code VARCHAR(50), -- كود المنتج (نسخة احتياطية)

	-- الكميات
	ordered_quantity DECIMAL(10,2) NOT NULL, -- الكمية المطلوبة
	allocated_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المخصصة
	picked_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المجهزة
	packed_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المعبأة
	shipped_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المشحونة
	delivered_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المسلمة
	returned_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المرتجعة

	-- وحدة القياس
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس المرجعية
	uom_name VARCHAR(50), -- اسم الوحدة (نسخة احتياطية)

	-- المعلومات المالية
	unit_price DECIMAL(15,2) NOT NULL, -- سعر الوحدة
	tax_rate DECIMAL(5,2) DEFAULT 0.15, -- نسبة الضريبة
	tax_amount DECIMAL(15,2), -- قيمة الضريبة
	discount_percent DECIMAL(5,2), -- نسبة الخصم
	discount_amount DECIMAL(15,2), -- قيمة الخصم
	total_price DECIMAL(15,2) NOT NULL, -- السعر الإجمالي للسطر

	-- معلومات التسليم
	requested_delivery_date DATE, -- تاريخ التسليم المطلوب
	actual_delivery_date DATE, -- تاريخ التسليم الفعلي

	-- حالة الصنف
	status VARCHAR(20) DEFAULT 'pending', -- حالة السطر

	-- معلومات الدفعة
	batch_number VARCHAR(50), -- رقم الدفعة
	expiry_date DATE, -- تاريخ الانتهاء

	-- معلومات الموقع
	location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع التخزين -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(35) and column name shelf_id to location_id

	-- ملاحظات
	notes TEXT, -- ملاحظات خاصة بالسطر
	reason_for_return TEXT, -- إذا كانت هناك كمية مرتجعة (returned_quantity)، يمكن توثيق السبب (مثل "عيب"، "خطأ في الطلب").

	-- بيانات التعقب
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	picked_at TIMESTAMP, -- تلتسجيل تاريخ ووقت تجهيز الكمية (picked_quantity)، مما يوفر تفاصيل دقيقة عن عملية التجهيز. -- !! CHANGED: DEFAULT CURRENT_TIMESTAMP removed
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	--FOREIGN KEY (reservation_id) REFERENCES inventory_reservations(reservation_id) -- !! COMMENTED OUT: Need to confirm if this FK is needed and correct
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE shipments (
	-- Basic Information
	shipment_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للشحنة
	shipment_number VARCHAR(50) UNIQUE NOT NULL, -- رقم الشحنة (فريد)
	status VARCHAR(20) DEFAULT 'draft', -- حالة الشحنة: مسودة، جاري التجهيز، معبأة، مشحونة، مسلمة، ملغاة

	-- Dates
	shipment_date TIMESTAMP, -- تاريخ الشحن
	estimated_delivery_date TIMESTAMP, -- التاريخ المتوقع للتسليم
	actual_delivery_date TIMESTAMP, -- التاريخ الفعلي للتسليم
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	approved_at TIMESTAMP, -- تاريخ ووقت الموافقة على الشحنة
    approved_by VARCHAR(36), -- الشخص الذي وافق على المهمة -- !! CHANGED: Removed FOREIGN KEY for initial creation
	cancelled_at TIMESTAMP, -- تاريخ ووقت إلغاء الشحنة
    cancelled_by VARCHAR(36), -- معرف المستخدم الذي ألغى الشحنة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- References
	so_id VARCHAR(36) REFERENCES sales_orders(so_id), -- معرف أمر البيع المرتبط
	customer_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id), -- معرف العميل
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- معرف المستودع
	carrier_id VARCHAR(36) REFERENCES business_partners(partner_id), -- معرف شركة الشحن
	shipping_address_id VARCHAR(36) REFERENCES partner_addresses(address_id), -- معرف عنوان الشحن

	-- Shipping Details
	tracking_number VARCHAR(100), -- رقم تتبع الشحنة
	shipping_method VARCHAR(50), -- طريقة الشحن (سريع، عادي، إلخ)
	shipping_cost DECIMAL(12,2), -- تكلفة الشحن
	weight DECIMAL(10,2), -- الوزن الكلي للشحنة
	volume DECIMAL(10,2), -- الحجم الكلي للشحنة

	-- Insurance
	is_insured BOOLEAN DEFAULT FALSE, -- هل الشحنة مؤمنة؟
	insurance_amount DECIMAL(12,2), -- مبلغ التأمين

	-- Priority & Type
	priority INTEGER DEFAULT 1, -- أولوية الشحنة (1-عادي، 2-متوسط، 3-عاجل)
	is_return BOOLEAN DEFAULT FALSE, -- هل هذه شحنة مرتجعات؟

	-- Notes & Reasons
	notes TEXT, -- ملاحظات
	return_reason TEXT, -- سبب الإرجاع إن وجد
	cancellation_reason TEXT, -- سبب الإلغاء
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, approved_by, cancelled_by using ALTER TABLE later if needed
);

CREATE TABLE shipment_items (
	-- Basic Information
	shipment_item_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لصنف الشحنة
	shipment_id VARCHAR(36) NOT NULL REFERENCES shipments(shipment_id), -- معرف الشحنة
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- معرف المنتج
	shipped_quantity DECIMAL(10,2) NOT NULL, -- الكمية المشحونة

	-- References
	so_item_id VARCHAR(36) REFERENCES sales_order_items(so_item_id), -- معرف صنف أمر البيع
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس
	source_location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع المصدر في المستودع

	-- Batch/Serial Information
	lot_number VARCHAR(50), -- رقم الدفعة
	batch_code VARCHAR(50), -- كود الدفعة
	serial_number VARCHAR(100), -- الرقم التسلسلي (للمنتجات المسلسلة)
	expiry_date DATE, -- تاريخ الانتهاء

	-- Pricing
	unit_price DECIMAL(12,2), -- سعر الوحدة
	tax_amount DECIMAL(12,2), -- قيمة الضريبة
	discount_amount DECIMAL(12,2), -- قيمة الخصم
	total_amount DECIMAL(12,2), -- الإجمالي بعد الضريبة والخصم

	-- Physical Attributes
	weight DECIMAL(10,2), -- وزن الصنف
	volume DECIMAL(10,2), -- حجم الصنف
	item_condition VARCHAR(20), -- حالة الصنف (جديد، تالف، إلخ)

	-- Return Information
	is_backorder BOOLEAN DEFAULT FALSE, -- هل هذا الصنف مؤجل للتسليم؟
	return_quantity DECIMAL(10,2), -- الكمية المرتجعة (في حال كانت شحنة مرتجعات)
	return_reason TEXT, -- سبب الإرجاع للصنف

	-- Dates
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- Notes
	notes TEXT, -- ملاحظات

    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE receipts (
	-- معلومات أساسية
	receipt_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لفاتورة الاستلام
	receipt_number VARCHAR(50) UNIQUE NOT NULL, -- رقم فاتورة الاستلام (فريد)
	status VARCHAR(20) DEFAULT 'draft', -- حالة الفاتورة: مسودة، قيد المعالجة، مكتمل، ملغى

	-- معلومات التواريخ
	receipt_date TIMESTAMP NOT NULL, -- تاريخ الاستلام الفعلي
	expected_delivery_date TIMESTAMP, -- تاريخ التسليم المتوقع
	actual_delivery_date TIMESTAMP, -- تاريخ التسليم الفعلي
	approval_date TIMESTAMP, -- تاريخ الموافقة على الاستلام

	-- معلومات الأطراف ذات الصلة
	supplier_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id), -- المورد الذي تم الاستلام منه
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- المستودع الذي تم الاستلام إليه
	carrier_id VARCHAR(36) REFERENCES business_partners(partner_id), -- شركة الشحن
	approver_id VARCHAR(36), -- الشخص الذي وافق على الاستلام -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات الشحن والتتبع
	tracking_number VARCHAR(100), -- رقم تتبع الشحنة
	shipping_method VARCHAR(50), -- طريقة الشحن (جوي، بحري، بري)
	shipping_cost DECIMAL(10,2), -- تكلفة الشحن

	-- معلومات مالية
	tax_amount DECIMAL(10,2), -- قيمة الضريبة
	discount_amount DECIMAL(10,2), -- قيمة الخصم
	total_amount DECIMAL(10,2), -- القيمة الإجمالية للفاتورة
	currency VARCHAR(3) DEFAULT 'SAR', -- العملة المستخدمة (ريال سعودي افتراضي)
	payment_terms VARCHAR(100), -- شروط الدفع (صافي 30 يوم، إلخ)
	payment_status VARCHAR(20), -- حالة الدفع

	-- معلومات إضافية
	po_id VARCHAR(36) REFERENCES purchase_orders(po_id), -- رقم أمر الشراء المرتبط
	rejection_reason TEXT, -- سبب الرفض إذا تم رفض الاستلام
	notes TEXT, -- ملاحظات عامة

	-- بيانات التتبع والتدقيق
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	is_deleted BOOLEAN DEFAULT FALSE, -- علامة للحذف المنطقي
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- القيود المرجعية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, approver_id using ALTER TABLE later if needed
);

CREATE TABLE receipt_items (
	-- معلومات أساسية
	receipt_item_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لصنف الاستلام
	receipt_id VARCHAR(36) NOT NULL REFERENCES receipts(receipt_id), -- المعرف الفريد لفاتورة الاستلام
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- المنتج الذي تم استلامه

	-- معلومات الكميات
	expected_quantity DECIMAL(10,2), -- الكمية المتوقعة حسب أمر الشراء
	received_quantity DECIMAL(10,2) NOT NULL, -- الكمية المستلمة الفعلية
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس

	-- معلومات الجودة والتخزين
	status VARCHAR(20) DEFAULT 'received', -- حالة الصنف: مستلم، تم التفتيش، تم التخزين، مرفوض
	quality_status VARCHAR(20) DEFAULT 'pending', -- حالة الجودة: معلق، مقبول، مرفوض
	destination_location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع التخزين المستهدف
	current_location_id VARCHAR(35) REFERENCES locations(location_id), -- الموقع الحالي للصنف

	-- معلومات الدفعات والتواريخ
	lot_number VARCHAR(50), -- رقم الدفعة
	product_batch VARCHAR(50), -- دفعة المنتج
	product_serial VARCHAR(50), -- الرقم التسلسلي للمنتج
	expiry_date DATE, -- تاريخ انتهاء الصلاحية
	production_date DATE, -- تاريخ الإنتاج

	-- معلومات التفتيش
	inspector_id VARCHAR(36), -- الشخص الذي قام بالتفتيش -- !! CHANGED: Removed FOREIGN KEY for initial creation
	inspection_date TIMESTAMP, -- تاريخ التفتيش
	quality_notes TEXT, -- ملاحظات الجودة

	-- معلومات التخزين
    putaway_by VARCHAR(36), -- الشخص الذي قام بالتخزين -- !! CHANGED: Removed FOREIGN KEY for initial creation
	putaway_date TIMESTAMP, -- تاريخ التخزين

	-- معلومات مالية
	unit_price DECIMAL(10,2), -- سعر الوحدة
	line_total DECIMAL(10,2), -- الإجمالي للصنف (الكمية × السعر)
	tax_rate DECIMAL(5,2), -- نسبة الضريبة
	discount_rate DECIMAL(5,2), -- نسبة الخصم

	-- معلومات إضافية
	po_item_id VARCHAR(36) REFERENCES purchase_order_items(po_item_id), -- رقم صنف أمر الشراء المرتبط
	rejection_reason TEXT, -- سبب الرفض إذا تم رفض الصنف
	notes TEXT, -- ملاحظات إضافية

	-- بيانات التتبع والتدقيق
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	is_deleted BOOLEAN DEFAULT FALSE, -- علامة للحذف المنطقي
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- القيود المرجعية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, inspector_id, putaway_by using ALTER TABLE later if needed
);

CREATE TABLE tasks (
	-- المعلومات الأساسية
	task_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للمهمة
	task_number VARCHAR(50) UNIQUE NOT NULL, -- رقم المهمة (فريد)
	task_type VARCHAR(20) NOT NULL, -- نوع المهمة: وضع في المخزن، انتقاء، جرد دوري، إلخ
	task_category VARCHAR(30), -- فئة المهمة (مثل: استلام، شحن، جودة)
	priority INT DEFAULT 5, -- الأولوية من 1 (أعلى) إلى 10 (أقل)
	is_urgent BOOLEAN DEFAULT FALSE, -- هل المهمة عاجلة؟

	-- حالة المهمة
	status VARCHAR(20) DEFAULT 'pending', -- الحالة: معلقة، معينة، قيد التنفيذ، مكتملة، ملغاة
	approval_status VARCHAR(20), -- حالة الموافقة
    approved_by VARCHAR(36), -- الشخص الذي وافق على المهمة -- !! CHANGED: Removed FOREIGN KEY for initial creation
	revision_number INT DEFAULT 1, -- رقم المراجعة للمهمة

	-- التوقيتات
	due_date TIMESTAMP, -- تاريخ الاستحقاق
	estimated_duration INT, -- المدة المقدرة لإكمال المهمة (بالدقائق)
	actual_duration INT, -- المدة الفعلية لإكمال المهمة (بالدقائق)
	assigned_at TIMESTAMP, -- تاريخ ووقت إسناد المهمة
	started_at TIMESTAMP, -- تاريخ ووقت بدء المهمة
	completed_at TIMESTAMP, -- تاريخ ووقت إكمال المهمة

	-- المواقع
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id), -- معرف المستودع
	zone_id VARCHAR(15) REFERENCES zones(zone_id), -- معرف المنطقة

	-- المراجع والعلاقات
	reference_id VARCHAR(36), -- المعرف المرجعي (الطلب، الإيصال، إلخ)
	reference_type VARCHAR(20), -- نوع المرجع: أمر شراء، أمر مبيعات، إلخ
	parent_task_id VARCHAR(36) REFERENCES tasks(task_id), -- مهمة رئيسية مرتبطة (للمهام الفرعية)
	batch_id VARCHAR(36), -- معرف الدفعة للمهام المجمعة

	-- الموارد
    assigned_to VARCHAR(36), -- لشخص المسندة إليه المهمة -- !! CHANGED: Removed FOREIGN KEY for initial creation
	equipment_id VARCHAR(36), -- المعدات المستخدمة (مثل الرافعة الشوكية)
	required_skills VARCHAR(100), -- المهارات المطلوبة لإكمال المهمة

	-- معلومات إضافية
	notes TEXT, -- ملاحظات
	cancellation_reason VARCHAR(100), -- سبب الإلغاء

	-- التواريخ النظامية
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	approved_at TIMESTAMP, -- تاريخ ووقت الموافقة
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, assigned_to, approved_by using ALTER TABLE later if needed
);

CREATE TABLE task_details (
	-- المعلومات الأساسية
	task_detail_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لتفصيل المهمة
	task_id VARCHAR(36) NOT NULL REFERENCES tasks(task_id), -- المعرف الفريد للمهمة الرئيسية
	sequence_number INT NOT NULL, -- رقم التسلسل للخطوة

	-- معلومات المنتج
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id), -- المعرف الفريد للمنتج
	quantity DECIMAL(10,2) NOT NULL, -- الكمية
	completed_quantity DECIMAL(10,2) DEFAULT 0, -- الكمية المكتملة
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id), -- وحدة القياس
	lot_number VARCHAR(50), -- رقم الدفعة
	serial_number VARCHAR(50), -- الرقم التسلسلي للمنتج

	-- المواقع
	source_location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع المصدر
	destination_location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع الوجهة
	putaway_strategy VARCHAR(30), -- استراتيجية التخزين
	picking_method VARCHAR(30), -- طريقة الانتقاء

	-- حالة التفصيل
	status VARCHAR(20) DEFAULT 'pending', -- الحالة: معلقة، قيد التنفيذ، مكتملة، ملغاة
	quality_status VARCHAR(20), -- حالة الجودة (جيد، تالف، إلخ)
	variance_reason VARCHAR(100), -- سبب التباين في الكمية
	scan_confirmation BOOLEAN DEFAULT FALSE, -- تأكيد المسح الضوئي

	-- الخصائص الفيزيائية
	weight DECIMAL(10,2), -- الوزن
	volume DECIMAL(10,2), -- الحجم

	-- متطلات خاصة
	temperature_requirements VARCHAR(30), -- متطلبات درجة الحرارة
	is_hazardous BOOLEAN DEFAULT FALSE, -- هل المنتج خطير؟
	handling_instructions TEXT, -- تعليمات التعامل مع المنتج

	-- التوقيتات
	started_at TIMESTAMP, -- تاريخ ووقت البدء
	completed_at TIMESTAMP, -- تاريخ ووقت الإكمال
	expiry_date DATE, -- تاريخ انتهاء الصلاحية للدفعة

	-- معلومات المسح
    scanned_by VARCHAR(36), -- الشخص الذي قام بالمسح -- !! CHANGED: Removed FOREIGN KEY for initial creation
	scanned_at TIMESTAMP, -- تاريخ ووقت المسح

	-- معلومات إضافية
	notes TEXT, -- ملاحظات

	-- التواريخ النظامية
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- المفاتيح الخارجية
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, scanned_by using ALTER TABLE later if needed
);

CREATE TABLE cycle_count_schedules (
	-- المعلومات الأساسية
	schedule_id VARCHAR(36) PRIMARY KEY,
	schedule_name VARCHAR(100) NOT NULL,

	-- العلاقات بالجداول الأخرى
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	zone_id VARCHAR(15) REFERENCES zones(zone_id),

	-- تكرار الجرد
	frequency_type VARCHAR(20) NOT NULL CHECK (frequency_type IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom')),
	frequency_value INTEGER, -- مثل كل 3 أيام إذا frequency_type = 'custom'
	week_day VARCHAR(10), -- إذا frequency_type = 'weekly'
	month_day INTEGER, -- إذا frequency_type = 'monthly'

	-- معايير الجرد
	count_method VARCHAR(30) CHECK (count_method IN ('random', 'location_based', 'product_based', 'value_based')),
	priority VARCHAR(20) DEFAULT 'medium',

	-- التنبيهات
	notify_before_days INTEGER,
	notify_users JSONB, -- قائمة بالمستخدمين الذين يتم إشعارهم

	-- الحالة
	is_active BOOLEAN DEFAULT TRUE,
	last_execution_date TIMESTAMP,
	next_execution_date TIMESTAMP,

	-- معلومات إضافية
	description TEXT,

	-- التتبع
	created_by VARCHAR(36) NOT NULL, -- !! CHANGED: Removed FOREIGN KEY for initial creation
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by VARCHAR(36), -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE damaged_goods (
	-- المعلومات الأساسية
	damage_id VARCHAR(36) PRIMARY KEY,
	damage_number VARCHAR(50) UNIQUE NOT NULL,

	-- العلاقات بالجداول الأخرى
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	inventory_id VARCHAR(36) REFERENCES inventory(inventory_id),
	location_id VARCHAR(35) REFERENCES locations(location_id),
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),

	-- معلومات الكمية
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),

	-- معلومات التلف
	damage_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	damage_type VARCHAR(30) NOT NULL CHECK (damage_type IN ('broken', 'expired', 'contaminated', 'leaked', 'other')),
	damage_severity VARCHAR(20) CHECK (damage_severity IN ('minor', 'moderate', 'severe', 'total')),
	damage_reason TEXT,

	-- الإجراءات المتخذة
	action_taken VARCHAR(30) CHECK (action_taken IN ('return_to_supplier', 'destroy', 'recycle', 'repair', 'sell_as_is', 'other')),
	action_description TEXT,
	action_cost DECIMAL(10,2),

	-- المسؤولية
	responsible_party VARCHAR(30) CHECK (responsible_party IN ('supplier', 'warehouse', 'carrier', 'customer', 'unknown')),
	employee_id VARCHAR(36), -- الموظف المسجل للحالة -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- الموافقات
	approved_by VARCHAR(36), -- !! CHANGED: Removed FOREIGN KEY for initial creation
	approval_date TIMESTAMP,

	-- التعويضات
	compensation_amount DECIMAL(10,2),
	compensation_currency VARCHAR(3) DEFAULT 'SAR',
	compensation_status VARCHAR(20),

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- القيود
	CONSTRAINT chk_damaged_goods_quantity CHECK (quantity > 0) -- Renamed constraint
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by, employee_id, approved_by using ALTER TABLE later if needed
);

CREATE TABLE roles (
	-- المعلومات الأساسية
	role_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للدور
	role_name VARCHAR(50) UNIQUE NOT NULL, -- اسم الدور (يجب أن يكون فريداً)

	-- الوصف والمعلومات
	description TEXT, -- وصف مفصل للدور
	level INTEGER DEFAULT 0, -- مستوى الدور (للترتيب الهرمي)

	-- حالة الدور
	is_active BOOLEAN DEFAULT TRUE, -- حالة تفعيل الدور
	is_system_role BOOLEAN DEFAULT FALSE, -- هل هو دور نظام لا يمكن حذفه؟
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- معلومات التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE user_roles (
	-- المعرف الأساسي
	user_role_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لعلاقة المستخدم بالدور

	-- المفاتيح الخارجية
	user_id VARCHAR(36) NOT NULL, -- المعرف الفريد للمستخدم -- !! CHANGED: Removed FOREIGN KEY for initial creation
	role_id VARCHAR(36) NOT NULL REFERENCES roles(role_id), -- المعرف الفريد للدور
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id), -- المعرف الفريد للمستودع (إذا كان الدور خاص بمستودع)
    assigned_by VARCHAR(36), -- لمستخدم الذي قام بتعيين الدور -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- معلومات التفعيل
	is_active BOOLEAN DEFAULT TRUE, -- حالة تفعيل العلاقة

	-- معلومات الصلاحية
	expiry_date TIMESTAMP, -- تاريخ انتهاء الصلاحية إذا كانت مؤقتة

	-- معلومات التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- معلومات إضافية
	notes TEXT, -- ملاحظات إضافية

	-- القيود
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	UNIQUE (user_id, role_id, warehouse_id)
	-- Add FOREIGN KEY constraints for user_id, assigned_by, created_by, updated_by, deleted_by using ALTER TABLE later (AFTER users table is created)
);

CREATE TABLE permissions (
	-- المعلومات الأساسية
	permission_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للصلاحية
	permission_name VARCHAR(100) UNIQUE NOT NULL, -- اسم الصلاحية (يجب أن يكون فريداً)
	permission_code VARCHAR(50) UNIQUE, -- كود الصلاحية (للاستخدام البرمجي)

	-- التصنيف
	module VARCHAR(50) NOT NULL, -- الوحدة التابعة لها (مثل: المخزون، الطلبات)
	category VARCHAR(50), -- فئة الصلاحية (مثل: القراءة، الكتابة)

	-- الوصف
	description TEXT, -- وصف مفصل للصلاحية

	-- حالة الصلاحية
	is_active BOOLEAN DEFAULT TRUE, -- حالة تفعيل الصلاحية
	is_system_permission BOOLEAN DEFAULT FALSE, -- هل هي صلاحية نظام لا يمكن حذفها؟

	-- معلومات التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE role_permissions (
	-- المعرف الأساسي
	role_permission_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد لعلاقة الدور بالصلاحية

	-- المفاتيح الخارجية
	role_id VARCHAR(36) NOT NULL REFERENCES roles(role_id), -- المعرف الفريد للدور
	permission_id VARCHAR(36) NOT NULL REFERENCES permissions(permission_id), -- المعرف الفريد للصلاحية

	-- معلومات التفعيل
	is_active BOOLEAN DEFAULT TRUE, -- حالة تفعيل العلاقة

	-- معلومات الصلاحية
	expiry_date TIMESTAMP, -- تاريخ انتهاء الصلاحية إذا كانت مؤقتة

	-- معلومات التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

	-- معلومات إضافية
	notes TEXT, -- ملاحظات إضافية

	-- القيود
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	UNIQUE (role_id, permission_id)
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE system_logs (
	-- الأساسيات
	log_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد للسجل
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت الإنشاء

	-- تصنيف السجل
	log_type VARCHAR(20) NOT NULL, -- نوع السجل: معلومات، تحذير، خطأ، تدقيق
	module VARCHAR(50) NOT NULL, -- الوحدة/النظام المصدر
	action VARCHAR(50) NOT NULL, -- الإجراء المنفذ

	-- تفاصيل الحدث
	description TEXT, -- الوصف التفصيلي
	severity VARCHAR(20), -- مستوى الخطورة (منخفض، متوسط، عالي، حرج)
	status_code INTEGER, -- كود الحالة (مثل 200، 404، 500)

	-- الكيان المتأثر
	entity_type VARCHAR(50), -- نوع الكيان (مستخدم، منتج، طلب...)
	entity_id VARCHAR(36), -- معرف الكيان

	-- معلومات المستخدم
	user_id VARCHAR(36), -- المستخدم المسؤول -- !! CHANGED: Removed FOREIGN KEY for initial creation
	ip_address VARCHAR(50), -- عنوان IP
	user_agent TEXT, -- معلومات الجهاز/المتصفح
	session_id VARCHAR(50), -- معرف جلسة المستخدم

	-- بيانات تقنية
	request_data JSONB, -- بيانات الطلب (لطلبات API)
	response_data JSONB, -- بيانات الاستجابة
	duration INTEGER, -- مدة التنفيذ (ميلي ثانية)
	metadata JSONB, -- بيانات إضافية

	-- معلومات إدارية
	is_archived BOOLEAN DEFAULT FALSE, -- هل تم أرشفة السجل؟
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for user_id, created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE system_settings (
	-- الأساسيات
	setting_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد
	setting_key VARCHAR(100) UNIQUE NOT NULL, -- المفتاح (فريد)
	setting_value TEXT, -- القيمة

	-- تصنيف الإعداد
	setting_type VARCHAR(20) NOT NULL, -- النوع: نص، رقم، منطقي، JSON
	category VARCHAR(50), -- الفئة (عام، أمان، واجهة...)
	group_name VARCHAR(50), -- المجموعة

	-- التحكم
	is_system BOOLEAN DEFAULT FALSE, -- إعداد نظام (لا يمكن حذفه)
	is_public BOOLEAN DEFAULT FALSE, -- متاح للقراءة العامة
	is_encrypted BOOLEAN DEFAULT FALSE, -- القيمة مشفرة

	-- القيود
	min_value NUMERIC, -- الحد الأدنى للقيمة
	max_value NUMERIC, -- الحد الأقصى
	options JSONB, -- الخيارات المتاحة (للقوائم)

	-- الوثائق
	description TEXT, -- الشرح المفصل
	version VARCHAR(20), -- إصدار الإعداد

	-- التتبع
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- تاريخ ووقت آخر تحديث
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE notifications (
	-- الأساسيات
	notification_id VARCHAR(36) PRIMARY KEY, -- المعرف الفريد
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإرسال

	-- المستهدف
	user_id VARCHAR(36) NOT NULL, -- المستلم -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- المحتوى
	notification_type VARCHAR(50) NOT NULL, -- النوع (تنبيه، تحديث...)
	title VARCHAR(100) NOT NULL, -- العنوان
	message TEXT, -- المحتوى
	icon VARCHAR(50), -- الأيقونة

	-- الحالة
	is_read BOOLEAN DEFAULT FALSE, -- مقروء/غير مقروء
	is_archived BOOLEAN DEFAULT FALSE, -- مؤرشف
	read_at TIMESTAMP, -- وقت القراءة

	-- الإجراءات
	entity_type VARCHAR(50), -- نوع الكيان المرتبط
	entity_id VARCHAR(36), -- معرف الكيان
	action_url VARCHAR(255), -- رابط الإجراء

	-- إعدادات متقدمة
	priority VARCHAR(20) DEFAULT 'normal', -- الأولوية (عادية، عالية)
	sender_id VARCHAR(36), -- المرسل (إذا كان مستخدمًا)
	expires_at TIMESTAMP, -- تاريخ الانتهاء
	channel VARCHAR(20), -- قناة الإرسال (إشعار، بريد، SMS)
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)

    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for user_id, created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE returns (
	-- الأساسيات
	return_id VARCHAR(36) PRIMARY KEY, -- معرف الإرجاع
	so_id VARCHAR(36) REFERENCES sales_orders(so_id), -- رقم أمر البيع المرتبط
	customer_id VARCHAR(36) REFERENCES business_partners(partner_id), -- العميل

	-- التفاصيل
	return_date TIMESTAMP, -- تاريخ الإرجاع
	return_type VARCHAR(20), -- نوع الإرجاع (استبدال، استرداد، إصلاح)
	reason VARCHAR(100), -- سبب الإرجاع
	status VARCHAR(20), -- حالة الإرجاع
	approval_status VARCHAR(20), -- حالة الموافقة
	is_damaged BOOLEAN DEFAULT FALSE, -- هل البضاعة تالفة؟

	-- المالية
	refund_amount DECIMAL(10,2), -- مبلغ الاسترداد
	refund_method VARCHAR(20), -- طريقة الاسترداد
	refund_date TIMESTAMP, -- تاريخ الاسترداد

	-- الموقع
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id), -- المستودع المستهدف -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(10)

	-- الملاحظات
	damage_description TEXT, -- وصف التلف
	notes TEXT, -- ملاحظات عامة

	-- الموافقات
	approval_date TIMESTAMP, -- تاريخ الموافقة
	approved_by VARCHAR(36), -- المصدق -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المنشئ -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_by VARCHAR(36), -- المعدل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for approved_by, created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE return_items (
	-- الأساسيات
	return_item_id VARCHAR(36) PRIMARY KEY, -- معرف العنصر
	return_id VARCHAR(36) REFERENCES returns(return_id), -- الإرجاع المرتبط
	product_id VARCHAR(20) REFERENCES products(product_id), -- المنتج

	-- الكميات
	quantity DECIMAL(10,2), -- الكمية
	uom_id VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة القياس

	-- الحالة
	condition VARCHAR(20), -- حالة المنتج
	disposition VARCHAR(20), -- التصرف المقترح
	inspection_result VARCHAR(20), -- نتيجة الفحص

	-- التعريف
	serial_number VARCHAR(50), -- الرقم التسلسلي
	batch_number VARCHAR(50), -- رقم الدفعة

	-- المالية
	unit_price DECIMAL(10,2), -- سعر الوحدة
	total_amount DECIMAL(10,2), -- المبلغ الإجمالي
	discount_amount DECIMAL(10,2), -- الخصم
	tax_amount DECIMAL(10,2), -- الضريبة

	-- الملاحظات
	notes TEXT, -- ملاحظات

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المنشئ -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_by VARCHAR(36), -- المعدل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE quality_inspections (
	-- الأساسيات
	inspection_id VARCHAR(36) PRIMARY KEY, -- معرف الفحص
	receipt_id VARCHAR(36) REFERENCES receipts(receipt_id), -- الاستلام المرتبط
	product_id VARCHAR(20) REFERENCES products(product_id), -- المنتج

	-- التفاصيل
	inspection_date TIMESTAMP, -- تاريخ الفحص
	inspection_type VARCHAR(20), -- نوع الفحص
	result VARCHAR(20), -- النتيجة

	-- العينات
	sample_size INTEGER, -- حجم العينة
	defects_found INTEGER, -- عدد العيوب
	defect_description TEXT, -- وصف العيوب

	-- الإجراءات
	recommended_action VARCHAR(50), -- الإجراء الموصى به
	is_reinspection BOOLEAN DEFAULT FALSE, -- فحص متكرر؟
	original_inspection_id VARCHAR(36), -- الفحص الأصلي

	-- المسؤولون
	inspector_id VARCHAR(36), -- المفتش -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- الملاحظات
	notes TEXT, -- ملاحظات

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المنشئ -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_by VARCHAR(36), -- المعدل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for inspector_id, created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE lot_tracking (
	-- الأساسيات
	lot_id VARCHAR(36) PRIMARY KEY, -- معرف الدفعة
	product_id VARCHAR(20) REFERENCES products(product_id), -- المنتج
	supplier_id VARCHAR(36) REFERENCES business_partners(partner_id), -- المورد

	-- التواريخ
	production_date DATE, -- تاريخ الإنتاج
	expiry_date DATE, -- تاريخ الانتهاء

	-- الأرقام
	lot_number VARCHAR(50), -- رقم الدفعة
	receipt_id VARCHAR(36) REFERENCES receipts(receipt_id), -- معرف الاستلام

	-- الكميات
	quantity DECIMAL(10,2), -- الكمية الإجمالية
	remaining_quantity DECIMAL(10,2), -- الكمية المتبقية
	uom_id VARCHAR(10) REFERENCES units_of_measure(uom_id), -- وحدة القياس

	-- الموقع
	location_id VARCHAR(35) REFERENCES locations(location_id), -- موقع التخزين -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(35)

	-- الحالة
	status VARCHAR(20), -- الحالة
	quality_status VARCHAR(20), -- حالة الجودة
	is_quarantined BOOLEAN DEFAULT FALSE, -- تحت الحجر؟

	-- الفحص
	inspection_id VARCHAR(36) REFERENCES quality_inspections(inspection_id), -- الفحص

	-- الملاحظات
	quarantine_reason TEXT, -- سبب الحجر
	notes TEXT, -- ملاحظات

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المنشئ -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_by VARCHAR(36), -- المعدل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE kpi_metrics (
	-- الأساسيات
	metric_id VARCHAR(36) PRIMARY KEY, -- معرف المؤشر
	metric_name VARCHAR(100), -- الاسم
	metric_description TEXT, -- الوصف

	-- القياس
	metric_unit VARCHAR(20), -- الوحدة
	target_value DECIMAL(10,2), -- الهدف
	benchmark_value DECIMAL(10,2), -- القيمة المرجعية

	-- الحدود
	min_threshold DECIMAL(10,2), -- الحد الأدنى
	max_threshold DECIMAL(10,2), -- الحد الأقصى

	-- التصنيف
	category VARCHAR(50), -- الفئة
	department VARCHAR(50), -- القسم

	-- التكرار
	frequency VARCHAR(20), -- التكرار
	calculation_method VARCHAR(50), -- طريقة الحساب

	-- الحالة
	is_active BOOLEAN DEFAULT TRUE, -- نشط؟

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المنشئ -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_by VARCHAR(36), -- المعدل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE kpi_values (
	-- الأساسيات
	value_id VARCHAR(36) PRIMARY KEY, -- معرف القيمة
	metric_id VARCHAR(36) REFERENCES kpi_metrics(metric_id), -- المؤشر
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id), -- المستودع -- !! CHANGED: Data type VARCHAR(20) to VARCHAR(10)

	-- القياس
	measurement_date TIMESTAMP, -- تاريخ القياس
	actual_value DECIMAL(10,2), -- القيمة الفعلية

	-- التحليل
	variance DECIMAL(10,2), -- الانحراف
	variance_percentage DECIMAL(5,2), -- نسبة الانحراف

	-- المصدر
	data_source VARCHAR(50), -- مصدر البيانات
	shift VARCHAR(20), -- الوردية

	-- الموافقة
	is_approved BOOLEAN DEFAULT FALSE, -- تمت الموافقة؟
	approved_by VARCHAR(36), -- المصدق -- !! CHANGED: Removed FOREIGN KEY for initial creation
	approval_date TIMESTAMP, -- تاريخ الموافقة

	-- الملاحظات
	notes TEXT, -- ملاحظات

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36), -- المنشئ -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_by VARCHAR(36), -- المعدل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for approved_by, created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE putaway_rules (
	-- المعلومات الأساسية
	rule_id VARCHAR(36) PRIMARY KEY,
	rule_name VARCHAR(100) NOT NULL,
	rule_priority INTEGER NOT NULL, -- الأولوية في التطبيق (1 = الأعلى أولوية)

	-- شروط التطبيق
	product_id VARCHAR(20) REFERENCES products(product_id),
	product_category_id BIGINT REFERENCES product_categories(category_id), -- !! CHANGED: data type from INTEGER to BIGINT
	product_family_id BIGINT REFERENCES product_families(family_id), -- !! CHANGED: data type from INTEGER to BIGINT
	product_attribute JSONB, -- سمات المنتج المطلوبة لتطبيق القاعدة

	-- خصائص المنتج
	min_weight DECIMAL(10,2),
	max_weight DECIMAL(10,2),
	min_volume DECIMAL(10,2),
	max_volume DECIMAL(10,2),
	hazardous_material BOOLEAN,
	temperature_requirements VARCHAR(30),

	-- الوجهة المحددة
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id),
	zone_id VARCHAR(15) REFERENCES zones(zone_id),
	aisle_id VARCHAR(20) REFERENCES aisles(aisle_id),
	rack_id VARCHAR(25) REFERENCES racks(rack_id),
	level_id VARCHAR(30) REFERENCES levels(level_id),
	location_type VARCHAR(30),

	-- إعدادات التخزين
	max_quantity_per_location DECIMAL(10,2),
	stacking_limit INTEGER,
	allow_mixing BOOLEAN DEFAULT FALSE,
	mixing_restrictions JSONB, -- قيود المزج مع منتجات أخرى

	-- الحالة
	is_active BOOLEAN DEFAULT TRUE,

	-- التتبع
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل -- !! CHANGED: Removed FOREIGN KEY for initial creation
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث -- !! CHANGED: Removed FOREIGN KEY for initial creation
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation

	-- القيود
	CONSTRAINT chk_putaway_rule_scope CHECK (  -- Renamed constraint
		product_id IS NOT NULL OR
		product_category_id IS NOT NULL OR
		product_family_id IS NOT NULL OR
		product_attribute IS NOT NULL
	)
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

CREATE TABLE picking_strategies (
	-- المعلومات الأساسية
	strategy_id VARCHAR(36) PRIMARY KEY,
	strategy_name VARCHAR(100) NOT NULL UNIQUE,
	strategy_code VARCHAR(50) NOT NULL UNIQUE,

	-- وصف الاستراتيجية
	description TEXT,
	strategy_type VARCHAR(30) NOT NULL CHECK (strategy_type IN ('FIFO', 'LIFO', 'FEFO', 'LEFO', 'BATCH', 'ZONE', 'WAVE')),

	-- معايير التطبيق
	apply_to_product_category BIGINT REFERENCES product_categories(category_id), -- !! CHANGED: data type from INTEGER to BIGINT
	apply_to_product_family BIGINT REFERENCES product_families(family_id), -- !! CHANGED: data type from INTEGER to BIGINT
	apply_to_warehouse VARCHAR(10) REFERENCES warehouses(warehouse_id),
	apply_to_zone VARCHAR(15) REFERENCES zones(zone_id),

	-- إعدادات الاستراتيجية
	is_default BOOLEAN DEFAULT FALSE,
	priority INTEGER DEFAULT 5,
	parameters JSONB, -- معايير إضافية للاستراتيجية

	-- الحالة
	is_active BOOLEAN DEFAULT TRUE,

	-- التتبع
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	created_by VARCHAR(36) NOT NULL, -- !! CHANGED: Removed FOREIGN KEY for initial creation
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by VARCHAR(36), -- !! CHANGED: Removed FOREIGN KEY for initial creation
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف -- !! CHANGED: Removed FOREIGN KEY for initial creation
	-- Add FOREIGN KEY constraints for created_by, updated_by, deleted_by using ALTER TABLE later if needed
);

-- يمكنك إضافة قيود المفاتيح الخارجية لـ created_by, updated_by, deleted_by هنا باستخدام ALTER TABLE
-- مثال:
-- ALTER TABLE units_of_measure ADD CONSTRAINT fk_uom_created_by FOREIGN KEY (created_by) REFERENCES users(user_id);
-- ALTER TABLE units_of_measure ADD CONSTRAINT fk_uom_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id);
-- ALTER TABLE units_of_measure ADD CONSTRAINT fk_uom_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(user_id);
-- ... كرر لبقية الجداول ...


--- END OF FILE Creating of DB_JustDB - Copy_fixed.txt ---
```

**وهذا ملف جديد يحتوي فقط على أوامر `CREATE TABLE` و `CREATE INDEX` بالترتيب الصحيح:**

```sql
--- START OF FILE Creating of DB_JustDB_reordered_only.txt ---

-- ملاحظة: يجب إنشاء جدول 'users' قبل تنفيذ هذا السكربت.
-- CREATE TABLE users ( user_id VARCHAR(36) PRIMARY KEY, ... ); -- مثال

CREATE TABLE units_of_measure (
	uom_id VARCHAR(10) PRIMARY KEY,                     -- المعرف الفريد للوحدة (مثل: 'KG', 'L', 'M')
	uom_name VARCHAR(50) NOT NULL,                     -- اسم الوحدة (مثل: 'كيلوجرام', 'لتر', 'متر')
	uom_type VARCHAR(20) NOT NULL,                     -- نوع الوحدة: وزن (weight)، حجم (volume)، طول (length)، كمية (quantity)
	description TEXT,                                  -- وصف تفصيلي للوحدة (اختياري)
	conversion_factor DECIMAL(10,4),                   -- عامل التحويل للوحدة الأساسية (مثال: 1000 إذا كانت الوحدة بالجرام والوحدة الأساسية بالكيلوجرام)
	base_uom_id VARCHAR(10),                          -- معرف الوحدة الأساسية المرتبطة (للتحويل بين الوحدات)
	is_active BOOLEAN NOT NULL DEFAULT TRUE,                  -- هل الوحدة مفعلة؟ (true/false)
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- تاريخ إنشاء الوحدة (تلقائي)
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ تحديث الوحدة (يتغير تلقائيًا عند التعديل)
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
	system VARCHAR(20),                               -- النظام الذي تنتمي إليه الوحدة (متري 'metric'، إمبراطوري 'imperial'، مخصص 'custom')
	category VARCHAR(50),                             -- الفئة (مثل: 'طبخ', 'صناعي', 'طبي')
	symbol VARCHAR(10),                               -- رمز الوحدة (مثل: 'kg', 'L', 'm')
	is_base_unit BOOLEAN NOT NULL DEFAULT FALSE,               -- هل هذه الوحدة أساسية؟ (لا تحتاج تحويلًا)
	decimal_precision INTEGER DEFAULT 2,			  -- عدد المنازل العشرية
	measurement_accuracy DECIMAL(10,4),				  -- دقة القياس
	industry_standard BOOLEAN DEFAULT FALSE,		  -- هل هي وحدة معيارية في الصناعة؟
	notes TEXT,                                       -- ملاحظات إضافية (اختياري)
	sort_order INTEGER,                               -- ترتيب العرض في القوائم (اختياري)
	created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف

	FOREIGN KEY (base_uom_id) REFERENCES units_of_measure(uom_id)
);

CREATE TABLE IF NOT EXISTS class_types (
	class_type_id VARCHAR(20) PRIMARY KEY, -- معرف فريد لنوع الفئة
	class_name VARCHAR(50) NOT NULL, -- اسم الفئة
	class_code VARCHAR(20) UNIQUE, -- كود مختصر للفئة
	parent_class_id VARCHAR(20), -- الفئة الأب (للهيكل الهرمي)
	level INTEGER, -- مستوى الفئة في الهيكل الهرمي
	is_system BOOLEAN DEFAULT FALSE, -- هل هي فئة نظامية؟
	description TEXT, -- وصف الفئة
	image_url TEXT, -- صورة توضيحية للفئة
	color_code VARCHAR(10), -- كود اللون للتمثيل البصري
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث
    deleted_by VARCHAR(36),  -- المستخدم الذي قام بالحذف

	FOREIGN KEY (parent_class_id) REFERENCES class_types(class_type_id)
);

CREATE TABLE IF NOT EXISTS tu_orientation_types (
	orientation_code VARCHAR(10) PRIMARY KEY, -- كود فريد لتوجيه الوحدة
	orientation_name VARCHAR(50) NOT NULL, -- اسم التوجيه
	description TEXT, -- وصف التوجيه
	rotation_angle_x DECIMAL(5,2), -- زاوية الدوران حول المحور X
	rotation_angle_y DECIMAL(5,2), -- زاوية الدوران حول المحور Y
	rotation_angle_z DECIMAL(5,2), -- زاوية الدوران حول المحور Z
	is_standard BOOLEAN DEFAULT TRUE, -- هل هو توجيه قياسي؟
	allowed_for_tu_types JSONB, -- أنواع الوحدات المسموح بها لهذا التوجيه
	weight_limit DECIMAL(10,2), -- حد الوزن لهذا التوجيه
	requires_special_equipment BOOLEAN DEFAULT FALSE, -- هل يحتاج معدات خاصة؟
	diagram_url TEXT, -- رابط رسم توضيحي للتوجيه
	safety_instructions TEXT, -- تعليمات السلامة
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ ووقت آخر تحديث
	deleted_at TIMESTAMP,                                  -- تاريخ الحذف (لدعم Soft Delete)
    created_by VARCHAR(36), -- المستخدم الذي أنشأ السجل
    updated_by VARCHAR(36), -- المستخدم الذي قام بالتحديث
    deleted_by VARCHAR(36)  -- المستخدم الذي قام بالحذف
);

CREATE TABLE product_categories (
	category_id BIGSERIAL PRIMARY KEY,
	category_code VARCHAR(64) UNIQUE NOT NULL,
	category_name VARCHAR(256) NOT NULL,
	class_type VARCHAR(32),
	description VARCHAR(2048),
	parent_id BIGINT REFERENCES product_categories(category_id) ON DELETE SET NULL,
	level INTEGER DEFAULT 1,
	sort_order INTEGER DEFAULT 0,
	is_active BOOLEAN DEFAULT TRUE,
	is_featured BOOLEAN DEFAULT FALSE,
	slug VARCHAR(100) UNIQUE,
	meta_title VARCHAR(100),
	meta_description TEXT,
	image_url VARCHAR(255),
	icon VARCHAR(50),
	color_code VARCHAR(7),
	inventory_type VARCHAR(20) DEFAULT 'PHYSICAL',
	tax_class VARCHAR(50),
	transaction_count NUMERIC(10),
	custom_attributes JSONB,
	create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE INDEX idx_cat_parent ON product_categories(parent_id);
CREATE INDEX idx_cat_active ON product_categories(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_cat_slug ON product_categories(slug);

CREATE TABLE product_families (
	family_id BIGSERIAL PRIMARY KEY,
	family_code VARCHAR(64) UNIQUE NOT NULL,
	family_name VARCHAR(256) NOT NULL,
	class_type VARCHAR(32),
	description VARCHAR(2048),
	transaction_count NUMERIC(10),
	parent_id BIGINT REFERENCES product_families(family_id),
	category_id BIGINT REFERENCES product_categories(category_id),
	segment VARCHAR(50),
	lifecycle_stage VARCHAR(20) DEFAULT 'ACTIVE' CHECK (lifecycle_stage IN ('PLANNING', 'ACTIVE', 'PHASE_OUT', 'DISCONTINUED')),
	launch_date DATE,
	end_of_life_date DATE CHECK (end_of_life_date IS NULL OR end_of_life_date >= launch_date),
	is_active BOOLEAN DEFAULT TRUE,
	is_featured BOOLEAN DEFAULT FALSE,
	target_market VARCHAR(50),
	image_url VARCHAR(255),
	thumbnail_url VARCHAR(255),
	slug VARCHAR(100) UNIQUE,
	create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	warranty_period_months INTEGER CHECK (warranty_period_months IS NULL OR warranty_period_months > 0),
	return_window_days INTEGER DEFAULT 14 CHECK (return_window_days > 0),
	attributes JSONB DEFAULT '{}',
	search_keywords TEXT[],
	CONSTRAINT valid_lifecycle CHECK (lifecycle_stage IN ('PLANNING', 'ACTIVE', 'PHASE_OUT', 'DISCONTINUED')),
	CONSTRAINT valid_dates CHECK (end_of_life_date IS NULL OR end_of_life_date >= launch_date)
);

CREATE INDEX idx_family_parent ON product_families(parent_id);
CREATE INDEX idx_family_category ON product_families(category_id);
CREATE INDEX idx_family_active ON product_families(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_family_slug ON product_families(slug);

CREATE TABLE products (
	product_id VARCHAR(20) PRIMARY KEY,
	product_name VARCHAR(100) NOT NULL,
	product_description TEXT,
	category_id BIGINT REFERENCES product_categories(category_id),
	family_id BIGINT REFERENCES product_families(family_id),
	barcode VARCHAR(50) UNIQUE,
	sku VARCHAR(50) UNIQUE,
	upc VARCHAR(50) UNIQUE,
	weight DECIMAL(10,2) CHECK (weight > 0),
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	length DECIMAL(10,2) CHECK (length > 0),
	width DECIMAL(10,2) CHECK (width > 0),
	height DECIMAL(10,2) CHECK (height > 0),
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	volume DECIMAL(10,2) CHECK (volume > 0),
	volume_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	min_stock_level DECIMAL(10,2) CHECK (min_stock_level >= 0),
	max_stock_level DECIMAL(10,2) CHECK (max_stock_level > 0),
	reorder_point DECIMAL(10,2) CHECK (reorder_point >= 0),
	STACKABLE_COLLI BOOLEAN DEFAULT TRUE,
	MIN_UOM_ID VARCHAR(10) REFERENCES units_of_measure(uom_id),
	MIN_UOM_ROUNDING_RULE VARCHAR(20) DEFAULT 'NONE',
	WEIGHT_VALIDATION VARCHAR(20) DEFAULT 'NONE',
	VELOCITY VARCHAR(10),
	TRANSACTION_COUNT INTEGER DEFAULT 0,
	SHELF_LIFE_CONTROLLED BOOLEAN DEFAULT FALSE,
	SCAN_VALIDATION_MODE VARCHAR(20) DEFAULT 'NONE',
	RELEVANT_DATE_FOR_ALLOCATION DATE,
	MAX_USED_TU_PER_PRODUCT INTEGER,
	LOCAL BOOLEAN DEFAULT FALSE,
	HOST_UOM_RATIO DECIMAL(10,2),
	DEFAULT_UOM_RATIO DECIMAL(10,2),
	CLASS_TYPE VARCHAR(30),
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE product_attributes (
	attribute_id SERIAL PRIMARY KEY,
	attribute_name VARCHAR(100) NOT NULL,
	attribute_code VARCHAR(50) UNIQUE NOT NULL,
	description TEXT,
	notes TEXT,
	attribute_type VARCHAR(20) NOT NULL,
	data_type VARCHAR(20) NOT NULL,
	is_required BOOLEAN DEFAULT FALSE,
	is_filterable BOOLEAN DEFAULT FALSE,
	is_visible BOOLEAN DEFAULT TRUE,
	is_comparable BOOLEAN DEFAULT FALSE,
	is_searchable BOOLEAN DEFAULT FALSE,
	default_value TEXT,
	validation_regex VARCHAR(255),
	min_value DECIMAL(15,4),
	max_value DECIMAL(15,4),
	decimal_places INTEGER,
	attribute_group VARCHAR(50),
	sort_order INTEGER DEFAULT 0,
	is_system_attribute BOOLEAN DEFAULT FALSE,
	is_configurable BOOLEAN DEFAULT FALSE,
	is_variant_attribute BOOLEAN DEFAULT FALSE,
	validation_message VARCHAR(255),
	depends_on_attribute INTEGER REFERENCES product_attributes(attribute_id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	CONSTRAINT chk_attribute_type CHECK (attribute_type IN ('text', 'number', 'select', 'multiselect', 'date', 'boolean')),
	CONSTRAINT chk_data_type CHECK (data_type IN ('varchar', 'integer', 'decimal', 'date', 'boolean', 'text'))
);

CREATE TABLE product_attribute_values (
	value_id SERIAL PRIMARY KEY,
	attribute_id INTEGER NOT NULL,
	product_id VARCHAR(20) NOT NULL,
	attribute_value TEXT NOT NULL,
	value_label VARCHAR(255),
	is_default BOOLEAN NOT NULL DEFAULT FALSE,
	sort_order INTEGER DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	FOREIGN KEY (attribute_id) REFERENCES product_attributes(attribute_id) ON DELETE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
	CONSTRAINT unique_product_attribute UNIQUE (product_id, attribute_id)
);

CREATE TABLE product_attribute_options (
	option_id SERIAL PRIMARY KEY,
	attribute_id INTEGER NOT NULL,
	option_value VARCHAR(255) NOT NULL,
	option_label VARCHAR(255) NOT NULL,
	sort_order INTEGER DEFAULT 0,
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	FOREIGN KEY (attribute_id) REFERENCES product_attributes(attribute_id) ON DELETE CASCADE
);

CREATE TABLE warehouses (
	warehouse_id VARCHAR(10) PRIMARY KEY,
	warehouse_name VARCHAR(100) NOT NULL,
	warehouse_code VARCHAR(20) UNIQUE,
	address TEXT,
	city VARCHAR(50),
	state VARCHAR(50),
	country VARCHAR(50),
	postal_code VARCHAR(20),
	contact_person VARCHAR(100),
	contact_email VARCHAR(100),
	contact_phone VARCHAR(20),
	secondary_contact_phone VARCHAR(20),
	total_area DECIMAL(10,2),
	area_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	storage_capacity INTEGER,
	warehouse_type VARCHAR(50),
	temperature_controlled BOOLEAN DEFAULT FALSE,
	min_temperature DECIMAL(5,2),
	max_temperature DECIMAL(5,2),
	temperature_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	is_active BOOLEAN DEFAULT TRUE,
	operational_status VARCHAR(20) DEFAULT 'operational',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	timezone VARCHAR(50),
	operating_hours JSONB,
	custom_attributes JSONB
);

CREATE TABLE zones (
	zone_id VARCHAR(15) PRIMARY KEY,
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	zone_name VARCHAR(100) NOT NULL,
	zone_code VARCHAR(20) UNIQUE,
	zone_type VARCHAR(50) NOT NULL CHECK (zone_type IN ('receiving', 'shipping', 'storage', 'picking', 'packing', 'staging')),
	description TEXT,
	area DECIMAL(10,2),
	area_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	capacity INTEGER,
	priority INTEGER DEFAULT 0,
	center_x DOUBLE PRECISION NOT NULL,
	center_y DOUBLE PRECISION NOT NULL,
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	temperature_controlled BOOLEAN DEFAULT FALSE,
	min_temperature DECIMAL(5,2),
	max_temperature DECIMAL(5,2),
	temperature_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	is_active BOOLEAN DEFAULT TRUE,
	status VARCHAR(20) DEFAULT 'operational',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	custom_attributes JSONB
);

CREATE TABLE aisles (
	aisle_id VARCHAR(20) PRIMARY KEY,
	zone_id VARCHAR(15) NOT NULL REFERENCES zones(zone_id),
	aisle_name VARCHAR(50) NOT NULL,
	aisle_code VARCHAR(20) UNIQUE,
	description TEXT,
	length DECIMAL(10,2),
	width DECIMAL(10,2),
	height DECIMAL(10,2),
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	capacity INTEGER,
	aisle_direction VARCHAR(20),
	is_active BOOLEAN DEFAULT TRUE,
	status VARCHAR(20) DEFAULT 'operational',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	start_x DOUBLE PRECISION NOT NULL,
	start_y DOUBLE PRECISION NOT NULL,
	end_x DOUBLE PRECISION NOT NULL,
	end_y DOUBLE PRECISION NOT NULL,
	center_x DOUBLE PRECISION,
	center_y DOUBLE PRECISION,
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	custom_attributes JSONB
);

CREATE TABLE racks (
	rack_id VARCHAR(25) PRIMARY KEY,
	aisle_id VARCHAR(20) NOT NULL REFERENCES aisles(aisle_id),
	rack_name VARCHAR(50) NOT NULL,
	rack_code VARCHAR(20) UNIQUE,
	rack_type VARCHAR(50) CHECK (rack_type IN ('pallet', 'shelving', 'cantilever', 'drive-in')),
	description TEXT,
	length DECIMAL(10,2),
	width DECIMAL(10,2),
	height DECIMAL(10,2),
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	max_weight DECIMAL(10,2),
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	capacity INTEGER,
	rack_system VARCHAR(50),
	total_levels INTEGER,
	center_x DOUBLE PRECISION NOT NULL,
	center_y DOUBLE PRECISION NOT NULL,
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	is_active BOOLEAN DEFAULT TRUE,
	status VARCHAR(20) DEFAULT 'operational',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	custom_attributes JSONB
);

CREATE TABLE levels (
	level_id VARCHAR(30) PRIMARY KEY,
	rack_id VARCHAR(25) NOT NULL REFERENCES racks(rack_id),
	level_name VARCHAR(50) NOT NULL,
	level_code VARCHAR(20) UNIQUE,
	level_number INT NOT NULL,
	height DECIMAL(10,2),
	height_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	max_weight DECIMAL(10,2),
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	length DECIMAL(10,2),
	width DECIMAL(10,2),
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	capacity INTEGER,
	relative_x DOUBLE PRECISION,
	relative_y DOUBLE PRECISION,
	z_position DOUBLE PRECISION,
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	is_active BOOLEAN DEFAULT TRUE,
	status VARCHAR(20) DEFAULT 'operational',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	custom_attributes JSONB
);

CREATE TABLE locations (
	location_id VARCHAR(35) PRIMARY KEY,
	level_id VARCHAR(30) NOT NULL REFERENCES levels(level_id),
	location_name VARCHAR(50) NOT NULL,
	location_code VARCHAR(20) UNIQUE,
	location_type VARCHAR(50) CHECK (location_type IN ('picking', 'storage', 'bulk', 'returns')),
	position INT,
	barcode VARCHAR(50) UNIQUE,
	location_priority VARCHAR(50) CHECK (location_priority IN ('HIGH', 'MEDIUM', 'LOW')),
	-- current_bin_id VARCHAR(20) REFERENCES bins(bin_id), -- FK to bins added later if needed
	bin_type VARCHAR(20),
	bin_volume DECIMAL(10,2),
	bin_max_weight DECIMAL(10,2),
	length DECIMAL(10,2),
	width DECIMAL(10,2),
	height DECIMAL(10,2),
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	volume DECIMAL(10,2),
	volume_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	max_weight DECIMAL(10,2),
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	relative_x DOUBLE PRECISION,
	relative_y DOUBLE PRECISION,
	z_position DOUBLE PRECISION,
	coordinate_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	is_active BOOLEAN DEFAULT TRUE,
	status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'blocked')),
	last_occupied_at TIMESTAMP,
	last_vacated_at TIMESTAMP,
	last_inventory_date TIMESTAMP,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	custom_attributes JSONB
);

CREATE TABLE bin_types (
	type_id VARCHAR(20) PRIMARY KEY,
	type_code VARCHAR(10) UNIQUE NOT NULL,
	type_name VARCHAR(50) NOT NULL,
	description TEXT,
	storage_class VARCHAR(20),
	standard_length DECIMAL(6,2) NOT NULL,
	standard_width DECIMAL(6,2) NOT NULL,
	standard_height DECIMAL(6,2) NOT NULL,
	standard_volume DECIMAL(10,2),
	standard_weight DECIMAL(10,2),
	max_payload DECIMAL(10,2) NOT NULL,
	is_stackable BOOLEAN DEFAULT TRUE,
	max_stack_count INTEGER DEFAULT 1,
	stackable_with JSONB,
	material VARCHAR(30) NOT NULL,
	color VARCHAR(20),
	is_transparent BOOLEAN DEFAULT FALSE,
	is_foldable BOOLEAN DEFAULT FALSE,
	requires_cleaning BOOLEAN DEFAULT FALSE,
	cleaning_frequency_days INTEGER,
	is_hazardous_material BOOLEAN DEFAULT FALSE,
	temperature_range VARCHAR(20),
	default_barcode_prefix VARCHAR(10),
	default_color_code VARCHAR(10),
	label_position VARCHAR(20),
	average_cost DECIMAL(12,2),
	expected_lifespan_months INTEGER,
	depreciation_rate DECIMAL(5,2),
	custom_fields JSONB,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE bins (
	bin_id VARCHAR(20) PRIMARY KEY,
	bin_barcode VARCHAR(50) UNIQUE,
	qr_code VARCHAR(50),
	rfid_tag VARCHAR(50),
	bin_name VARCHAR(100),
	bin_category VARCHAR(20),
	bin_status VARCHAR(20) DEFAULT 'متاح',
	current_location_id VARCHAR(35) REFERENCES locations(location_id),
	bin_type VARCHAR(20) REFERENCES bin_types(type_id),
	length DECIMAL(6,2),
	width DECIMAL(6,2),
	height DECIMAL(6,2),
	volume DECIMAL(10,2),
	tare_weight DECIMAL(10,2),
	max_weight DECIMAL(10,2),
	max_volume DECIMAL(10,2),
	optimal_fill_percentage DECIMAL(5,2),
	current_fill_percentage DECIMAL(5,2),
	manufacturer VARCHAR(100),
	manufacturing_date DATE,
	material VARCHAR(50),
	serial_number VARCHAR(50),
	is_hazardous BOOLEAN DEFAULT FALSE,
	requires_cleaning BOOLEAN DEFAULT FALSE,
	last_cleaned_date DATE,
	is_active BOOLEAN DEFAULT TRUE,
	owned_by VARCHAR(50),
	purchase_date DATE,
	purchase_price DECIMAL(12,2),
	expected_lifespan_months INTEGER,
	custom_fields JSONB,
	notes TEXT,
	last_inventory_check TIMESTAMP,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE bin_movements (
	movement_id BIGSERIAL PRIMARY KEY,
	bin_id VARCHAR(20) NOT NULL REFERENCES bins(bin_id),
	from_location_id VARCHAR(35) REFERENCES locations(location_id),
	from_location_type VARCHAR(20),
	to_location_id VARCHAR(35) NOT NULL REFERENCES locations(location_id),
	to_location_type VARCHAR(20),
	movement_type VARCHAR(30) NOT NULL,
	movement_reason VARCHAR(100),
	movement_method VARCHAR(20),
    moved_by VARCHAR(36),
	team_id VARCHAR(20),
	session_id VARCHAR(50),
	work_order_id VARCHAR(50),
	reference_doc VARCHAR(50),
	distance_moved DECIMAL(10,2),
	movement_duration_seconds INTEGER,
	status VARCHAR(20) DEFAULT 'مكتمل',
	is_verified BOOLEAN DEFAULT FALSE,
	verification_method VARCHAR(20),
    approved_by VARCHAR(36),
	equipment_used VARCHAR(50),
	temperature_at_move DECIMAL(5,2),
	notes TEXT,
	custom_fields JSONB,
	-- movement_path GEOGRAPHY, -- Requires PostGIS
	movement_priority INTEGER,
	scheduled_time TIMESTAMP,
	movement_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	completed_time TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE bin_contents (
	content_id BIGSERIAL PRIMARY KEY,
	bin_id VARCHAR(20) NOT NULL REFERENCES bins(bin_id),
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	batch_number VARCHAR(50),
	serial_number VARCHAR(50),
	quantity DECIMAL(10,2) NOT NULL,
	uom VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	min_quantity DECIMAL(10,2),
	max_quantity DECIMAL(10,2),
	storage_condition VARCHAR(20),
	putaway_date TIMESTAMP,
	last_accessed TIMESTAMP,
	expiration_date DATE,
	quality_status VARCHAR(20) DEFAULT 'جيد',
	inspection_required BOOLEAN DEFAULT FALSE,
	last_inspection_date TIMESTAMP,
	inspection_due_date DATE,
	source_document VARCHAR(50),
	source_reference VARCHAR(50),
	is_locked BOOLEAN DEFAULT FALSE,
	lock_reason TEXT,
	turnover_rate DECIMAL(10,2),
	days_in_stock INTEGER,
	custom_fields JSONB,
	notes TEXT,
	last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	CONSTRAINT positive_quantity CHECK (quantity >= 0),
	UNIQUE(bin_id, product_id, batch_number, serial_number)
);

CREATE TABLE inventory (
	inventory_id VARCHAR(36) PRIMARY KEY,
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	location_id VARCHAR(35) NOT NULL REFERENCES locations(location_id),
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	min_stock_level DECIMAL(10,2),
	max_stock_level DECIMAL(10,2),
	reorder_point DECIMAL(10,2),
	lot_number VARCHAR(50),
	serial_number VARCHAR(50),
	production_date DATE,
	expiry_date DATE,
	last_movement_date TIMESTAMP,
	status VARCHAR(20) DEFAULT 'available',
	is_active BOOLEAN DEFAULT TRUE,
	quality_status VARCHAR(20),
	temperature_zone VARCHAR(20),
	weight DECIMAL(10,2),
	dimensions VARCHAR(50),
	hazard_class VARCHAR(20),
	owner_id VARCHAR(36),
	supplier_id VARCHAR(36),
	customs_info TEXT,
	barcode VARCHAR(50),
	rfid_tag VARCHAR(50),
	last_audit_date DATE,
	audit_notes TEXT,
	approval_date TIMESTAMP,
    approved_by VARCHAR(36),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE inventory_movements (
	movement_id VARCHAR(36) PRIMARY KEY,
	inventory_id VARCHAR(36) NOT NULL REFERENCES inventory(inventory_id),
	source_location_id VARCHAR(35) REFERENCES locations(location_id),
	destination_location_id VARCHAR(35) REFERENCES locations(location_id),
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	movement_type VARCHAR(20) NOT NULL,
	movement_reason VARCHAR(50),
	reference_id VARCHAR(36),
	reference_type VARCHAR(20),
	batch_number VARCHAR(50),
	movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(36),
	system_generated BOOLEAN DEFAULT FALSE,
	approval_status VARCHAR(20) DEFAULT 'pending',
	approval_date TIMESTAMP,
    approved_by VARCHAR(36),
	transaction_value DECIMAL(12,2),
	currency VARCHAR(3),
	movement_cost DECIMAL(10,2),
	transport_mode VARCHAR(20),
	carrier_id VARCHAR(36),
	tracking_number VARCHAR(50),
	expected_arrival TIMESTAMP,
	actual_arrival TIMESTAMP,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE inventory_counts (
	count_id VARCHAR(36) PRIMARY KEY,
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	count_name VARCHAR(100),
	count_type VARCHAR(20) NOT NULL,
	status VARCHAR(20) DEFAULT 'planned',
	start_date TIMESTAMP,
	end_date TIMESTAMP,
	expected_completion TIMESTAMP,
	team_leader VARCHAR(36),
	count_team TEXT,
	count_method VARCHAR(20),
	count_frequency VARCHAR(20),
	count_zone VARCHAR(20),
	count_category VARCHAR(20),
	variance_threshold DECIMAL(5,2),
	is_approved BOOLEAN DEFAULT FALSE,
	approved_at TIMESTAMP,
    approved_by VARCHAR(36),
	is_recount BOOLEAN DEFAULT FALSE,
	original_count_id VARCHAR(36),
	priority VARCHAR(10),
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE inventory_count_details (
	count_detail_id VARCHAR(36) PRIMARY KEY,
	count_id VARCHAR(36) NOT NULL REFERENCES inventory_counts(count_id),
	inventory_id VARCHAR(36) NOT NULL REFERENCES inventory(inventory_id),
	expected_quantity DECIMAL(10,2),
	counted_quantity DECIMAL(10,2),
	recount_quantity DECIMAL(10,2),
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	variance DECIMAL(10,2),
	variance_percentage DECIMAL(10,2),
	status VARCHAR(20) DEFAULT 'pending',
	count_method VARCHAR(20),
	device_id VARCHAR(36),
    counted_by VARCHAR(36),
	counted_at TIMESTAMP,
    recount_by VARCHAR(36),
	recount_at TIMESTAMP,
	recount_status VARCHAR(20),
	adjustment_id VARCHAR(36),
    adjustment_by VARCHAR(36),
	adjustment_date TIMESTAMP,
	location_verified BOOLEAN,
	batch_verified BOOLEAN,
	expiry_verified BOOLEAN,
	item_condition VARCHAR(20),
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE inventory_reservations (
	reservation_id VARCHAR(36) PRIMARY KEY,
	reservation_number VARCHAR(50) UNIQUE NOT NULL,
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	inventory_id VARCHAR(36) REFERENCES inventory(inventory_id),
	location_id VARCHAR(35) REFERENCES locations(location_id),
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	reservation_type VARCHAR(20) NOT NULL CHECK (reservation_type IN ('sale', 'transfer', 'production', 'quality_check')),
	status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'released', 'fulfilled', 'cancelled')),
	reference_id VARCHAR(36),
	reference_type VARCHAR(30),
	reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	expires_at TIMESTAMP,
	released_at TIMESTAMP,
	reserved_by VARCHAR(36) NOT NULL,
	released_by VARCHAR(36),
	notes TEXT,
	priority INTEGER DEFAULT 5,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	CONSTRAINT chk_inv_res_quantity CHECK (quantity > 0),
	CONSTRAINT chk_inv_res_dates CHECK (expires_at IS NULL OR expires_at > reserved_at)
);

CREATE TABLE transport_unit_types (
	tu_type_id VARCHAR(20) PRIMARY KEY,
	type_name VARCHAR(50) NOT NULL,
	description TEXT,
	length DECIMAL(10,2),
	width DECIMAL(10,2),
	height DECIMAL(10,2),
	dimension_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	volume DECIMAL(10,2),
	volume_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	max_weight DECIMAL(10,2),
	weight_unit VARCHAR(10) REFERENCES units_of_measure(uom_id),
	manufacturer VARCHAR(100),
	model VARCHAR(50),
	material VARCHAR(50),
	color VARCHAR(20),
	is_active BOOLEAN DEFAULT TRUE,
	image_url TEXT,
	custom_fields JSONB,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE IF NOT EXISTS transport_units (
	tu_id VARCHAR(36) PRIMARY KEY,
	tu_type_id VARCHAR(20) NOT NULL REFERENCES transport_unit_types(tu_type_id),
	tu_code VARCHAR(50) UNIQUE,
	barcode VARCHAR(50),
	class_type VARCHAR(20) REFERENCES class_types(class_type_id),
	product_velocity VARCHAR(20),
	current_location_id VARCHAR(35) REFERENCES locations(location_id),
	zone_id VARCHAR(15) REFERENCES zones(zone_id),
	x_position DECIMAL(10,2),
	y_position DECIMAL(10,2),
	z_position DECIMAL(10,2),
	orientation VARCHAR(10) REFERENCES tu_orientation_types(orientation_code),
	status VARCHAR(20) DEFAULT 'available',
	status_date TIMESTAMP,
	yard_process_status VARCHAR(30),
	transaction_count INTEGER DEFAULT 0,
	last_move_date TIMESTAMP,
	parent_tu_id VARCHAR(36) REFERENCES transport_units(tu_id),
	owner_id VARCHAR(36),
	order_id VARCHAR(36),
	order_tu_plan_id VARCHAR(36),
	shipment_id VARCHAR(36),
	shipping_lane_request_id VARCHAR(36),
	manufacturing_date DATE,
	expected_lifespan INTEGER,
	last_maintenance_date DATE,
	next_maintenance_date DATE,
	inspection_notes TEXT,
	pick_confirmation_posted BOOLEAN DEFAULT FALSE,
	order_process_status VARCHAR(30),
	purchase_cost DECIMAL(15,2),
	current_value DECIMAL(15,2),
	depreciation_rate DECIMAL(5,2),
	is_leased BOOLEAN DEFAULT FALSE,
	lease_expiry_date DATE,
	is_active BOOLEAN DEFAULT TRUE,
	image_url TEXT,
	custom_fields JSONB,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE transport_unit_contents (
	content_id VARCHAR(36) PRIMARY KEY,
	tu_id VARCHAR(36) NOT NULL REFERENCES transport_units(tu_id),
	inventory_id VARCHAR(36) NOT NULL REFERENCES inventory(inventory_id),
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	batch_number VARCHAR(50),
	serial_number VARCHAR(50),
	expiry_date DATE,
	status VARCHAR(20),
	notes TEXT,
    added_by VARCHAR(36),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	removal_reason TEXT,
	custom_fields JSONB,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE business_partners (
	partner_id VARCHAR(36) PRIMARY KEY,
	partner_name VARCHAR(100) NOT NULL,
	partner_code VARCHAR(50) UNIQUE,
	partner_type VARCHAR(20) NOT NULL,
	contact_person VARCHAR(100),
	contact_email VARCHAR(100),
	contact_phone VARCHAR(20),
	fax_number VARCHAR(20),
	website VARCHAR(100),
	address TEXT,
	city VARCHAR(50),
	state VARCHAR(50),
	country VARCHAR(50),
	postal_code VARCHAR(20),
	tax_id VARCHAR(50),
	payment_terms VARCHAR(50),
	credit_limit DECIMAL(15,2),
	currency VARCHAR(3),
	bank_name VARCHAR(100),
	bank_account VARCHAR(50),
	iban VARCHAR(50),
	swift_code VARCHAR(20),
	parent_partner_id VARCHAR(36) REFERENCES business_partners(partner_id),
	is_vendor BOOLEAN DEFAULT FALSE,
	is_customer BOOLEAN DEFAULT FALSE,
	is_carrier BOOLEAN DEFAULT FALSE,
	is_active BOOLEAN DEFAULT TRUE,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE partner_addresses (
	address_id VARCHAR(36) PRIMARY KEY,
	partner_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id),
	address_type VARCHAR(20) NOT NULL,
	address_name VARCHAR(100),
	is_default BOOLEAN DEFAULT FALSE,
	address_line1 TEXT NOT NULL,
	address_line2 TEXT,
	city VARCHAR(50) NOT NULL,
	state VARCHAR(50),
	country VARCHAR(50) NOT NULL,
	postal_code VARCHAR(20),
	latitude DECIMAL(10,8),
	longitude DECIMAL(11,8),
	directions TEXT,
	contact_person VARCHAR(100),
	contact_email VARCHAR(100),
	contact_phone VARCHAR(20),
	is_active BOOLEAN DEFAULT TRUE,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE purchase_orders (
	po_id VARCHAR(36) PRIMARY KEY,
	po_number VARCHAR(50) UNIQUE NOT NULL,
	supplier_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id),
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	source_type VARCHAR(10) NOT NULL,
	order_date DATE NOT NULL,
	expected_delivery_date DATE,
	actual_delivery_date DATE,
	status VARCHAR(20) DEFAULT 'draft',
	approval_status VARCHAR(20),
	approved_at TIMESTAMP,
    approved_by VARCHAR(36),
	total_amount DECIMAL(15,2),
	tax_amount DECIMAL(15,2),
	discount_amount DECIMAL(15,2),
	currency VARCHAR(3) DEFAULT 'SAR',
	tax_included BOOLEAN DEFAULT FALSE,
	payment_terms VARCHAR(50),
	shipping_terms VARCHAR(50),
	incoterms VARCHAR(20),
	priority VARCHAR(10) DEFAULT 'normal',
	source_document VARCHAR(100),
	cancellation_reason TEXT,
	notes TEXT,
	internal_notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	closed_at TIMESTAMP,
	deleted_at TIMESTAMP,
	revision_number INT DEFAULT 0,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE purchase_order_items (
	po_item_id VARCHAR(36) PRIMARY KEY,
	po_id VARCHAR(36) NOT NULL REFERENCES purchase_orders(po_id),
	line_number INT NOT NULL,
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	product_name VARCHAR(100),
	product_code VARCHAR(50),
	supplier_product_code VARCHAR(50),
	quality_inspection_status VARCHAR(20),
	ordered_quantity DECIMAL(10,2) NOT NULL,
	received_quantity DECIMAL(10,2) DEFAULT 0,
	rejected_quantity DECIMAL(10,2) DEFAULT 0,
	remaining_quantity DECIMAL(10,2) GENERATED ALWAYS AS (ordered_quantity - received_quantity) STORED,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	uom_name VARCHAR(50),
	unit_price DECIMAL(15,2) NOT NULL,
	tax_rate DECIMAL(5,2) DEFAULT 0.15,
	tax_amount DECIMAL(15,2),
	discount_percent DECIMAL(5,2),
	discount_amount DECIMAL(15,2),
	total_price DECIMAL(15,2) NOT NULL,
	expected_delivery_date DATE,
	actual_delivery_date DATE,
	reason_for_rejection TEXT,
	status VARCHAR(20) DEFAULT 'pending',
	inventory_status VARCHAR(20),
	location_id VARCHAR(35) REFERENCES locations(location_id),
	batch_number VARCHAR(50),
	expiry_date DATE,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE sales_orders (
	so_id VARCHAR(36) PRIMARY KEY,
	so_number VARCHAR(50) UNIQUE NOT NULL,
	customer_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id),
	customer_po_number VARCHAR(50),
	order_type VARCHAR(20),
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	order_date DATE NOT NULL,
	requested_delivery_date DATE,
	promised_delivery_date DATE,
	actual_delivery_date DATE,
	shipping_address_id VARCHAR(36) REFERENCES partner_addresses(address_id),
	billing_address_id VARCHAR(36) REFERENCES partner_addresses(address_id),
	sales_rep_id VARCHAR(36),
	status VARCHAR(20) DEFAULT 'draft',
	approval_status VARCHAR(20),
	approved_at TIMESTAMP,
    approved_by VARCHAR(36),
	total_amount DECIMAL(15,2),
	tax_amount DECIMAL(15,2),
	discount_amount DECIMAL(15,2),
	currency VARCHAR(3) DEFAULT 'SAR',
	payment_terms VARCHAR(50),
	payment_status VARCHAR(20) DEFAULT 'unpaid',
	shipping_method VARCHAR(50),
	shipping_status VARCHAR(20),
	carrier_id VARCHAR(36) REFERENCES business_partners(partner_id),
	tracking_number VARCHAR(100),
	freight_charge DECIMAL(15,2),
	priority VARCHAR(10) DEFAULT 'normal',
	source_document VARCHAR(100),
	return_status VARCHAR(20),
	channel VARCHAR(20),
	notes TEXT,
	internal_notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	closed_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE sales_order_items (
	so_item_id VARCHAR(36) PRIMARY KEY,
	so_id VARCHAR(36) NOT NULL REFERENCES sales_orders(so_id),
	line_number INT NOT NULL,
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	product_name VARCHAR(100),
	product_code VARCHAR(50),
	ordered_quantity DECIMAL(10,2) NOT NULL,
	allocated_quantity DECIMAL(10,2) DEFAULT 0,
	picked_quantity DECIMAL(10,2) DEFAULT 0,
	packed_quantity DECIMAL(10,2) DEFAULT 0,
	shipped_quantity DECIMAL(10,2) DEFAULT 0,
	delivered_quantity DECIMAL(10,2) DEFAULT 0,
	returned_quantity DECIMAL(10,2) DEFAULT 0,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	uom_name VARCHAR(50),
	unit_price DECIMAL(15,2) NOT NULL,
	tax_rate DECIMAL(5,2) DEFAULT 0.15,
	tax_amount DECIMAL(15,2),
	discount_percent DECIMAL(5,2),
	discount_amount DECIMAL(15,2),
	total_price DECIMAL(15,2) NOT NULL,
	requested_delivery_date DATE,
	actual_delivery_date DATE,
	status VARCHAR(20) DEFAULT 'pending',
	batch_number VARCHAR(50),
	expiry_date DATE,
	location_id VARCHAR(35) REFERENCES locations(location_id),
	notes TEXT,
	reason_for_return TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	picked_at TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
	-- FOREIGN KEY (reservation_id) REFERENCES inventory_reservations(reservation_id) -- Optional FK
);

CREATE TABLE shipments (
	shipment_id VARCHAR(36) PRIMARY KEY,
	shipment_number VARCHAR(50) UNIQUE NOT NULL,
	status VARCHAR(20) DEFAULT 'draft',
	shipment_date TIMESTAMP,
	estimated_delivery_date TIMESTAMP,
	actual_delivery_date TIMESTAMP,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	approved_at TIMESTAMP,
    approved_by VARCHAR(36),
	cancelled_at TIMESTAMP,
    cancelled_by VARCHAR(36),
	so_id VARCHAR(36) REFERENCES sales_orders(so_id),
	customer_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id),
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	carrier_id VARCHAR(36) REFERENCES business_partners(partner_id),
	shipping_address_id VARCHAR(36) REFERENCES partner_addresses(address_id),
	tracking_number VARCHAR(100),
	shipping_method VARCHAR(50),
	shipping_cost DECIMAL(12,2),
	weight DECIMAL(10,2),
	volume DECIMAL(10,2),
	is_insured BOOLEAN DEFAULT FALSE,
	insurance_amount DECIMAL(12,2),
	priority INTEGER DEFAULT 1,
	is_return BOOLEAN DEFAULT FALSE,
	notes TEXT,
	return_reason TEXT,
	cancellation_reason TEXT,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE shipment_items (
	shipment_item_id VARCHAR(36) PRIMARY KEY,
	shipment_id VARCHAR(36) NOT NULL REFERENCES shipments(shipment_id),
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	shipped_quantity DECIMAL(10,2) NOT NULL,
	so_item_id VARCHAR(36) REFERENCES sales_order_items(so_item_id),
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	source_location_id VARCHAR(35) REFERENCES locations(location_id),
	lot_number VARCHAR(50),
	batch_code VARCHAR(50),
	serial_number VARCHAR(100),
	expiry_date DATE,
	unit_price DECIMAL(12,2),
	tax_amount DECIMAL(12,2),
	discount_amount DECIMAL(12,2),
	total_amount DECIMAL(12,2),
	weight DECIMAL(10,2),
	volume DECIMAL(10,2),
	item_condition VARCHAR(20),
	is_backorder BOOLEAN DEFAULT FALSE,
	return_quantity DECIMAL(10,2),
	return_reason TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	notes TEXT,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE receipts (
	receipt_id VARCHAR(36) PRIMARY KEY,
	receipt_number VARCHAR(50) UNIQUE NOT NULL,
	status VARCHAR(20) DEFAULT 'draft',
	receipt_date TIMESTAMP NOT NULL,
	expected_delivery_date TIMESTAMP,
	actual_delivery_date TIMESTAMP,
	approval_date TIMESTAMP,
	supplier_id VARCHAR(36) NOT NULL REFERENCES business_partners(partner_id),
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	carrier_id VARCHAR(36) REFERENCES business_partners(partner_id),
	approver_id VARCHAR(36),
	tracking_number VARCHAR(100),
	shipping_method VARCHAR(50),
	shipping_cost DECIMAL(10,2),
	tax_amount DECIMAL(10,2),
	discount_amount DECIMAL(10,2),
	total_amount DECIMAL(10,2),
	currency VARCHAR(3) DEFAULT 'SAR',
	payment_terms VARCHAR(100),
	payment_status VARCHAR(20),
	po_id VARCHAR(36) REFERENCES purchase_orders(po_id),
	rejection_reason TEXT,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	is_deleted BOOLEAN DEFAULT FALSE,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE receipt_items (
	receipt_item_id VARCHAR(36) PRIMARY KEY,
	receipt_id VARCHAR(36) NOT NULL REFERENCES receipts(receipt_id),
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	expected_quantity DECIMAL(10,2),
	received_quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	status VARCHAR(20) DEFAULT 'received',
	quality_status VARCHAR(20) DEFAULT 'pending',
	destination_location_id VARCHAR(35) REFERENCES locations(location_id),
	current_location_id VARCHAR(35) REFERENCES locations(location_id),
	lot_number VARCHAR(50),
	product_batch VARCHAR(50),
	product_serial VARCHAR(50),
	expiry_date DATE,
	production_date DATE,
	inspector_id VARCHAR(36),
	inspection_date TIMESTAMP,
	quality_notes TEXT,
    putaway_by VARCHAR(36),
	putaway_date TIMESTAMP,
	unit_price DECIMAL(10,2),
	line_total DECIMAL(10,2),
	tax_rate DECIMAL(5,2),
	discount_rate DECIMAL(5,2),
	po_item_id VARCHAR(36) REFERENCES purchase_order_items(po_item_id),
	rejection_reason TEXT,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	is_deleted BOOLEAN DEFAULT FALSE,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE tasks (
	task_id VARCHAR(36) PRIMARY KEY,
	task_number VARCHAR(50) UNIQUE NOT NULL,
	task_type VARCHAR(20) NOT NULL,
	task_category VARCHAR(30),
	priority INT DEFAULT 5,
	is_urgent BOOLEAN DEFAULT FALSE,
	status VARCHAR(20) DEFAULT 'pending',
	approval_status VARCHAR(20),
    approved_by VARCHAR(36),
	revision_number INT DEFAULT 1,
	due_date TIMESTAMP,
	estimated_duration INT,
	actual_duration INT,
	assigned_at TIMESTAMP,
	started_at TIMESTAMP,
	completed_at TIMESTAMP,
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	zone_id VARCHAR(15) REFERENCES zones(zone_id),
	reference_id VARCHAR(36),
	reference_type VARCHAR(20),
	parent_task_id VARCHAR(36) REFERENCES tasks(task_id),
	batch_id VARCHAR(36),
    assigned_to VARCHAR(36),
	equipment_id VARCHAR(36),
	required_skills VARCHAR(100),
	notes TEXT,
	cancellation_reason VARCHAR(100),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	approved_at TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE task_details (
	task_detail_id VARCHAR(36) PRIMARY KEY,
	task_id VARCHAR(36) NOT NULL REFERENCES tasks(task_id),
	sequence_number INT NOT NULL,
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	quantity DECIMAL(10,2) NOT NULL,
	completed_quantity DECIMAL(10,2) DEFAULT 0,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	lot_number VARCHAR(50),
	serial_number VARCHAR(50),
	source_location_id VARCHAR(35) REFERENCES locations(location_id),
	destination_location_id VARCHAR(35) REFERENCES locations(location_id),
	putaway_strategy VARCHAR(30),
	picking_method VARCHAR(30),
	status VARCHAR(20) DEFAULT 'pending',
	quality_status VARCHAR(20),
	variance_reason VARCHAR(100),
	scan_confirmation BOOLEAN DEFAULT FALSE,
	weight DECIMAL(10,2),
	volume DECIMAL(10,2),
	temperature_requirements VARCHAR(30),
	is_hazardous BOOLEAN DEFAULT FALSE,
	handling_instructions TEXT,
	started_at TIMESTAMP,
	completed_at TIMESTAMP,
	expiry_date DATE,
    scanned_by VARCHAR(36),
	scanned_at TIMESTAMP,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE cycle_count_schedules (
	schedule_id VARCHAR(36) PRIMARY KEY,
	schedule_name VARCHAR(100) NOT NULL,
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	zone_id VARCHAR(15) REFERENCES zones(zone_id),
	frequency_type VARCHAR(20) NOT NULL CHECK (frequency_type IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom')),
	frequency_value INTEGER,
	week_day VARCHAR(10),
	month_day INTEGER,
	count_method VARCHAR(30) CHECK (count_method IN ('random', 'location_based', 'product_based', 'value_based')),
	priority VARCHAR(20) DEFAULT 'medium',
	notify_before_days INTEGER,
	notify_users JSONB,
	is_active BOOLEAN DEFAULT TRUE,
	last_execution_date TIMESTAMP,
	next_execution_date TIMESTAMP,
	description TEXT,
	created_by VARCHAR(36) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by VARCHAR(36),
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    deleted_by VARCHAR(36)
);

CREATE TABLE damaged_goods (
	damage_id VARCHAR(36) PRIMARY KEY,
	damage_number VARCHAR(50) UNIQUE NOT NULL,
	product_id VARCHAR(20) NOT NULL REFERENCES products(product_id),
	inventory_id VARCHAR(36) REFERENCES inventory(inventory_id),
	location_id VARCHAR(35) REFERENCES locations(location_id),
	warehouse_id VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
	quantity DECIMAL(10,2) NOT NULL,
	uom_id VARCHAR(10) NOT NULL REFERENCES units_of_measure(uom_id),
	damage_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	damage_type VARCHAR(30) NOT NULL CHECK (damage_type IN ('broken', 'expired', 'contaminated', 'leaked', 'other')),
	damage_severity VARCHAR(20) CHECK (damage_severity IN ('minor', 'moderate', 'severe', 'total')),
	damage_reason TEXT,
	action_taken VARCHAR(30) CHECK (action_taken IN ('return_to_supplier', 'destroy', 'recycle', 'repair', 'sell_as_is', 'other')),
	action_description TEXT,
	action_cost DECIMAL(10,2),
	responsible_party VARCHAR(30) CHECK (responsible_party IN ('supplier', 'warehouse', 'carrier', 'customer', 'unknown')),
	employee_id VARCHAR(36),
	approved_by VARCHAR(36),
	approval_date TIMESTAMP,
	compensation_amount DECIMAL(10,2),
	compensation_currency VARCHAR(3) DEFAULT 'SAR',
	compensation_status VARCHAR(20),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	CONSTRAINT chk_damaged_goods_quantity CHECK (quantity > 0)
);

CREATE TABLE roles (
	role_id VARCHAR(36) PRIMARY KEY,
	role_name VARCHAR(50) UNIQUE NOT NULL,
	description TEXT,
	level INTEGER DEFAULT 0,
	is_active BOOLEAN DEFAULT TRUE,
	is_system_role BOOLEAN DEFAULT FALSE,
	deleted_at TIMESTAMP,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE user_roles (
	user_role_id VARCHAR(36) PRIMARY KEY,
	user_id VARCHAR(36) NOT NULL,
	role_id VARCHAR(36) NOT NULL REFERENCES roles(role_id),
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id),
    assigned_by VARCHAR(36),
	is_active BOOLEAN DEFAULT TRUE,
	expiry_date TIMESTAMP,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	notes TEXT,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	UNIQUE (user_id, role_id, warehouse_id)
);

CREATE TABLE permissions (
	permission_id VARCHAR(36) PRIMARY KEY,
	permission_name VARCHAR(100) UNIQUE NOT NULL,
	permission_code VARCHAR(50) UNIQUE,
	module VARCHAR(50) NOT NULL,
	category VARCHAR(50),
	description TEXT,
	is_active BOOLEAN DEFAULT TRUE,
	is_system_permission BOOLEAN DEFAULT FALSE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE role_permissions (
	role_permission_id VARCHAR(36) PRIMARY KEY,
	role_id VARCHAR(36) NOT NULL REFERENCES roles(role_id),
	permission_id VARCHAR(36) NOT NULL REFERENCES permissions(permission_id),
	is_active BOOLEAN DEFAULT TRUE,
	expiry_date TIMESTAMP,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	notes TEXT,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	UNIQUE (role_id, permission_id)
);

CREATE TABLE system_logs (
	log_id VARCHAR(36) PRIMARY KEY,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	log_type VARCHAR(20) NOT NULL,
	module VARCHAR(50) NOT NULL,
	action VARCHAR(50) NOT NULL,
	description TEXT,
	severity VARCHAR(20),
	status_code INTEGER,
	entity_type VARCHAR(50),
	entity_id VARCHAR(36),
	user_id VARCHAR(36),
	ip_address VARCHAR(50),
	user_agent TEXT,
	session_id VARCHAR(50),
	request_data JSONB,
	response_data JSONB,
	duration INTEGER,
	metadata JSONB,
	is_archived BOOLEAN DEFAULT FALSE,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE system_settings (
	setting_id VARCHAR(36) PRIMARY KEY,
	setting_key VARCHAR(100) UNIQUE NOT NULL,
	setting_value TEXT,
	setting_type VARCHAR(20) NOT NULL,
	category VARCHAR(50),
	group_name VARCHAR(50),
	is_system BOOLEAN DEFAULT FALSE,
	is_public BOOLEAN DEFAULT FALSE,
	is_encrypted BOOLEAN DEFAULT FALSE,
	min_value NUMERIC,
	max_value NUMERIC,
	options JSONB,
	description TEXT,
	version VARCHAR(20),
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
	notification_id VARCHAR(36) PRIMARY KEY,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	user_id VARCHAR(36) NOT NULL,
	notification_type VARCHAR(50) NOT NULL,
	title VARCHAR(100) NOT NULL,
	message TEXT,
	icon VARCHAR(50),
	is_read BOOLEAN DEFAULT FALSE,
	is_archived BOOLEAN DEFAULT FALSE,
	read_at TIMESTAMP,
	entity_type VARCHAR(50),
	entity_id VARCHAR(36),
	action_url VARCHAR(255),
	priority VARCHAR(20) DEFAULT 'normal',
	sender_id VARCHAR(36),
	expires_at TIMESTAMP,
	channel VARCHAR(20),
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE returns (
	return_id VARCHAR(36) PRIMARY KEY,
	so_id VARCHAR(36) REFERENCES sales_orders(so_id),
	customer_id VARCHAR(36) REFERENCES business_partners(partner_id),
	return_date TIMESTAMP,
	return_type VARCHAR(20),
	reason VARCHAR(100),
	status VARCHAR(20),
	approval_status VARCHAR(20),
	is_damaged BOOLEAN DEFAULT FALSE,
	refund_amount DECIMAL(10,2),
	refund_method VARCHAR(20),
	refund_date TIMESTAMP,
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id),
	damage_description TEXT,
	notes TEXT,
	approval_date TIMESTAMP,
	approved_by VARCHAR(36),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
	updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE return_items (
	return_item_id VARCHAR(36) PRIMARY KEY,
	return_id VARCHAR(36) REFERENCES returns(return_id),
	product_id VARCHAR(20) REFERENCES products(product_id),
	quantity DECIMAL(10,2),
	uom_id VARCHAR(10) REFERENCES units_of_measure(uom_id),
	condition VARCHAR(20),
	disposition VARCHAR(20),
	inspection_result VARCHAR(20),
	serial_number VARCHAR(50),
	batch_number VARCHAR(50),
	unit_price DECIMAL(10,2),
	total_amount DECIMAL(10,2),
	discount_amount DECIMAL(10,2),
	tax_amount DECIMAL(10,2),
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
	updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE quality_inspections (
	inspection_id VARCHAR(36) PRIMARY KEY,
	receipt_id VARCHAR(36) REFERENCES receipts(receipt_id),
	product_id VARCHAR(20) REFERENCES products(product_id),
	inspection_date TIMESTAMP,
	inspection_type VARCHAR(20),
	result VARCHAR(20),
	sample_size INTEGER,
	defects_found INTEGER,
	defect_description TEXT,
	recommended_action VARCHAR(50),
	is_reinspection BOOLEAN DEFAULT FALSE,
	original_inspection_id VARCHAR(36),
	inspector_id VARCHAR(36),
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
	updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE lot_tracking (
	lot_id VARCHAR(36) PRIMARY KEY,
	product_id VARCHAR(20) REFERENCES products(product_id),
	supplier_id VARCHAR(36) REFERENCES business_partners(partner_id),
	production_date DATE,
	expiry_date DATE,
	lot_number VARCHAR(50),
	receipt_id VARCHAR(36) REFERENCES receipts(receipt_id),
	quantity DECIMAL(10,2),
	remaining_quantity DECIMAL(10,2),
	uom_id VARCHAR(10) REFERENCES units_of_measure(uom_id),
	location_id VARCHAR(35) REFERENCES locations(location_id),
	status VARCHAR(20),
	quality_status VARCHAR(20),
	is_quarantined BOOLEAN DEFAULT FALSE,
	inspection_id VARCHAR(36) REFERENCES quality_inspections(inspection_id),
	quarantine_reason TEXT,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
	updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE kpi_metrics (
	metric_id VARCHAR(36) PRIMARY KEY,
	metric_name VARCHAR(100),
	metric_description TEXT,
	metric_unit VARCHAR(20),
	target_value DECIMAL(10,2),
	benchmark_value DECIMAL(10,2),
	min_threshold DECIMAL(10,2),
	max_threshold DECIMAL(10,2),
	category VARCHAR(50),
	department VARCHAR(50),
	frequency VARCHAR(20),
	calculation_method VARCHAR(50),
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36),
	updated_by VARCHAR(36),
    deleted_by VARCHAR(36)
);

CREATE TABLE kpi_values (
	value_id VARCHAR(36) PRIMARY KEY,
	metric_id VARCHAR(36) REFERENCES kpi_metrics(metric_id),
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id),
	measurement_date TIMESTAMP,
	actual_value DECIMAL(10,2),
	variance DECIMAL(10,2),
	variance_percentage DECIMAL(5,2),
	data_source VARCHAR(50),
	shift VARCHAR(20),
	is_approved BOOLEAN DEFAULT FALSE,
	approved_by VARCHAR(36),
	approval_date TIMESTAMP,
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    deleted_by VARCHAR(36),
	created_by VARCHAR(36),
	updated_by VARCHAR(36)
);

CREATE TABLE putaway_rules (
	rule_id VARCHAR(36) PRIMARY KEY,
	rule_name VARCHAR(100) NOT NULL,
	rule_priority INTEGER NOT NULL,
	product_id VARCHAR(20) REFERENCES products(product_id),
	product_category_id BIGINT REFERENCES product_categories(category_id),
	product_family_id BIGINT REFERENCES product_families(family_id),
	product_attribute JSONB,
	min_weight DECIMAL(10,2),
	max_weight DECIMAL(10,2),
	min_volume DECIMAL(10,2),
	max_volume DECIMAL(10,2),
	hazardous_material BOOLEAN,
	temperature_requirements VARCHAR(30),
	warehouse_id VARCHAR(10) REFERENCES warehouses(warehouse_id),
	zone_id VARCHAR(15) REFERENCES zones(zone_id),
	aisle_id VARCHAR(20) REFERENCES aisles(aisle_id),
	rack_id VARCHAR(25) REFERENCES racks(rack_id),
	level_id VARCHAR(30) REFERENCES levels(level_id),
	location_type VARCHAR(30),
	max_quantity_per_location DECIMAL(10,2),
	stacking_limit INTEGER,
	allow_mixing BOOLEAN DEFAULT FALSE,
	mixing_restrictions JSONB,
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP,
    created_by VARCHAR(36),
    updated_by VARCHAR(36),
    deleted_by VARCHAR(36),
	CONSTRAINT chk_putaway_rule_scope CHECK (
		product_id IS NOT NULL OR
		product_category_id IS NOT NULL OR
		product_family_id IS NOT NULL OR
		product_attribute IS NOT NULL
	)
);

CREATE TABLE picking_strategies (
	strategy_id VARCHAR(36) PRIMARY KEY,
	strategy_name VARCHAR(100) NOT NULL UNIQUE,
	strategy_code VARCHAR(50) NOT NULL UNIQUE,
	description TEXT,
	strategy_type VARCHAR(30) NOT NULL CHECK (strategy_type IN ('FIFO', 'LIFO', 'FEFO', 'LEFO', 'BATCH', 'ZONE', 'WAVE')),
	apply_to_product_category BIGINT REFERENCES product_categories(category_id),
	apply_to_product_family BIGINT REFERENCES product_families(family_id),
	apply_to_warehouse VARCHAR(10) REFERENCES warehouses(warehouse_id),
	apply_to_zone VARCHAR(15) REFERENCES zones(zone_id),
	is_default BOOLEAN DEFAULT FALSE,
	priority INTEGER DEFAULT 5,
	parameters JSONB,
	is_active BOOLEAN DEFAULT TRUE,
	deleted_at TIMESTAMP,
	created_by VARCHAR(36) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by VARCHAR(36),
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by VARCHAR(36)
);

-- يمكنك إضافة قيود المفاتيح الخارجية لـ created_by, updated_by, deleted_by هنا باستخدام ALTER TABLE
-- مثال:
-- ALTER TABLE units_of_measure ADD CONSTRAINT fk_uom_created_by FOREIGN KEY (created_by) REFERENCES users(user_id);
-- ALTER TABLE units_of_measure ADD CONSTRAINT fk_uom_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id);
-- ALTER TABLE units_of_measure ADD CONSTRAINT fk_uom_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(user_id);
-- ... كرر لبقية الجداول ...
