import { useState, ReactNode } from "react";
import { Link, useLocation } from "wouter";
import { cn } from "@/lib/utils";
import { 
  ChevronDown, 
  ChevronUp,
  LayoutDashboard, 
  BoxIcon, 
  Package, 
  ShoppingCart, 
  Warehouse, 
  BarChart3, 
  Users, 
  Settings,
  Menu,
  Home
} from "lucide-react";
import { Button } from "./button";
import { Separator } from "./separator";
import { useAuth } from "@/hooks/use-auth";

type MenuItemProps = {
  icon: ReactNode;
  label: string;
  path: string;
  active?: boolean;
  onClick?: () => void;
};

type SubMenuItemProps = {
  label: string;
  path: string;
  active?: boolean;
  onClick?: () => void;
};

type MenuGroupProps = {
  icon: ReactNode;
  label: string;
  children: ReactNode;
  defaultOpen?: boolean;
  onClick?: () => void;
};

const MenuItem = ({ icon, label, path, active, onClick }: MenuItemProps) => (
  <Link 
    href={path}
    className={cn(
      "flex items-center px-4 py-3 text-sm font-medium rounded-md",
      "transition-colors duration-200",
      active
        ? "bg-primary-50 dark:bg-primary-900 text-primary-700 dark:text-primary-100"
        : "text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
    )}
    onClick={onClick}
  >
    <div className="w-5 h-5 mr-3">{icon}</div>
    <span className="sidebar-text">{label}</span>
  </Link>
);

const SubMenuItem = ({ label, path, active, onClick }: SubMenuItemProps) => (
  <Link 
    href={path}
    className={cn(
      "flex items-center px-4 py-2 mt-1 text-sm font-medium",
      "transition-colors duration-200",
      active
        ? "text-primary-700 dark:text-primary-300"
        : "text-gray-600 dark:text-gray-400 hover:text-primary-700 dark:hover:text-primary-300"
    )}
    onClick={onClick}
  >
    <span className="sidebar-text">{label}</span>
  </Link>
);

const MenuGroup = ({ icon, label, children, defaultOpen = false, onClick }: MenuGroupProps) => {
  const [isOpen, setIsOpen] = useState(defaultOpen);
  
  return (
    <div>
      <button
        className="w-full flex items-center px-4 py-3 text-sm font-medium text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-md"
        onClick={() => {
          setIsOpen(!isOpen);
          if (onClick) onClick();
        }}
      >
        <div className="w-5 h-5 mr-3">{icon}</div>
        <span className="sidebar-text">{label}</span>
        <div className="ml-auto sidebar-text">
          {isOpen ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
        </div>
      </button>
      {isOpen && (
        <div className="ml-4 pl-4 border-l border-gray-200 dark:border-gray-700">
          {children}
        </div>
      )}
    </div>
  );
};

type SidebarProps = {
  collapsed: boolean;
  onToggle: () => void;
  onMobileClose?: () => void;
};

export function Sidebar({ collapsed, onToggle, onMobileClose }: SidebarProps) {
  const [location] = useLocation();
  const { user } = useAuth();
  
  if (!user) return null;
  
  const isActive = (path: string) => location === path;
  const isActiveSubPath = (basePath: string) => location.startsWith(basePath);
  
  return (
    <aside
      className={cn(
        "fixed inset-y-0 left-0 z-30 flex flex-col border-r border-gray-200 dark:border-gray-700 shadow-sm bg-white dark:bg-gray-800 transition-all duration-300 transform",
        collapsed ? "w-20" : "w-64",
        "md:translate-x-0"
      )}
    >
      {/* Logo and Branding */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-gray-700">
        <div className="flex items-center">
          <div className="flex items-center justify-center h-10 w-10 rounded-md bg-primary-500 text-white">
            <Warehouse size={24} />
          </div>
          {!collapsed && <span className="ml-2 text-xl font-semibold text-gray-800 dark:text-white">WMS System</span>}
        </div>
        <Button
          variant="ghost"
          size="icon"
          onClick={onToggle}
          className="p-1"
        >
          <Menu className="h-5 w-5" />
        </Button>
      </div>
      
      {/* Navigation Items */}
      <nav className="flex-1 overflow-y-auto py-4 px-2 space-y-1">
        <MenuItem
          icon={<LayoutDashboard />}
          label="Dashboard"
          path="/"
          active={isActive("/")}
          onClick={onMobileClose}
        />
        
        <MenuGroup
          icon={<BoxIcon />}
          label="Inventory"
          defaultOpen={isActiveSubPath("/inventory")}
          onClick={onMobileClose}
        >
          <SubMenuItem
            label="Stock Overview"
            path="/inventory"
            active={isActive("/inventory")}
            onClick={onMobileClose}
          />
          <SubMenuItem
            label="Stock Movements"
            path="/inventory/movements"
            active={isActive("/inventory/movements")}
            onClick={onMobileClose}
          />
          <SubMenuItem
            label="Adjustments"
            path="/inventory/adjustments"
            active={isActive("/inventory/adjustments")}
            onClick={onMobileClose}
          />
        </MenuGroup>
        
        <MenuGroup
          icon={<Package />}
          label="Products"
          defaultOpen={isActiveSubPath("/products")}
          onClick={onMobileClose}
        >
          <SubMenuItem
            label="Product List"
            path="/products"
            active={isActive("/products")}
            onClick={onMobileClose}
          />
          <SubMenuItem
            label="Categories"
            path="/products/categories"
            active={isActive("/products/categories")}
            onClick={onMobileClose}
          />
          <SubMenuItem
            label="Units of Measure"
            path="/products/uom"
            active={isActive("/products/uom")}
            onClick={onMobileClose}
          />
        </MenuGroup>
        
        <MenuItem
          icon={<ShoppingCart />}
          label="Orders"
          path="/orders"
          active={isActiveSubPath("/orders")}
          onClick={onMobileClose}
        />
        
        <MenuItem
          icon={<Warehouse />}
          label="Warehouses"
          path="/warehouses"
          active={isActiveSubPath("/warehouses")}
          onClick={onMobileClose}
        />
        
        <MenuItem
          icon={<BarChart3 />}
          label="Reports"
          path="/reports"
          active={isActiveSubPath("/reports")}
          onClick={onMobileClose}
        />
        
        <MenuItem
          icon={<Users />}
          label="User Management"
          path="/users"
          active={isActiveSubPath("/users")}
          onClick={onMobileClose}
        />
        
        <MenuItem
          icon={<Settings />}
          label="Settings"
          path="/settings"
          active={isActiveSubPath("/settings")}
          onClick={onMobileClose}
        />
      </nav>
      
      {/* User Info */}
      {!collapsed && (
        <div className="p-4 border-t border-gray-200 dark:border-gray-700">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <div className="h-8 w-8 rounded-full bg-primary-100 dark:bg-primary-900 flex items-center justify-center text-primary-700 dark:text-primary-100">
                {user.firstName?.charAt(0)}{user.lastName?.charAt(0)}
              </div>
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-700 dark:text-gray-300">
                {user.firstName} {user.lastName}
              </p>
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {user.isAdmin ? "Administrator" : "User"}
              </p>
            </div>
          </div>
        </div>
      )}
    </aside>
  );
}
