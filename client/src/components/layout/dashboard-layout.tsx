import { useState, useEffect, ReactNode } from "react";
import { Sidebar } from "@/components/ui/sidebar";
import { useAuth } from "@/hooks/use-auth";
import { Link, useLocation } from "wouter";
import { Loader2, Menu, Sun, Moon, Bell, ChevronRight, LogOut, Home } from "lucide-react";
import { Button } from "@/components/ui/button";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { Toaster } from "@/components/ui/toaster";
import { useMobile } from "@/hooks/use-mobile";

interface DashboardLayoutProps {
  children: ReactNode;
}

export function DashboardLayout({ children }: DashboardLayoutProps) {
  const [darkMode, setDarkMode] = useState(
    localStorage.getItem("darkMode") === "true" ||
    (!localStorage.getItem("darkMode") && window.matchMedia('(prefers-color-scheme: dark)').matches)
  );
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { user, logoutMutation } = useAuth();
  const [location] = useLocation();
  const isMobile = useMobile();
  
  // Apply dark mode class to html element
  useEffect(() => {
    const html = document.documentElement;
    if (darkMode) {
      html.classList.add("dark");
      localStorage.setItem("darkMode", "true");
    } else {
      html.classList.remove("dark");
      localStorage.setItem("darkMode", "false");
    }
  }, [darkMode]);
  
  // Close mobile menu on location change
  useEffect(() => {
    setMobileMenuOpen(false);
  }, [location]);
  
  // Default to collapsed sidebar on mobile
  useEffect(() => {
    if (isMobile) {
      setSidebarCollapsed(true);
    }
  }, [isMobile]);
  
  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
  };
  
  const toggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };
  
  const toggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };
  
  const handleLogout = () => {
    logoutMutation.mutate();
  };
  
  if (!user) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-100 dark:bg-gray-900">
        <Loader2 className="h-10 w-10 animate-spin text-primary-500" />
      </div>
    );
  }
  
  // Extract current page name from location
  const getPageName = () => {
    if (location === "/") return "Dashboard";
    
    const path = location.split("/");
    if (path.length > 1) {
      const section = path[1].charAt(0).toUpperCase() + path[1].slice(1);
      if (path.length > 2 && path[2]) {
        const subsection = path[2].charAt(0).toUpperCase() + path[2].slice(1);
        return `${section} - ${subsection}`;
      }
      return section;
    }
    
    return "Dashboard";
  };
  
  return (
    <div className="flex h-screen overflow-hidden bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-200">
      {/* Mobile overlay */}
      {mobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-20 md:hidden"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}
      
      {/* Sidebar - visible on mobile only when menu is open */}
      <div className={`md:block ${mobileMenuOpen ? 'block' : 'hidden'} z-30`}>
        <Sidebar 
          collapsed={sidebarCollapsed} 
          onToggle={toggleSidebar}
          onMobileClose={() => setMobileMenuOpen(false)}
        />
      </div>
      
      {/* Main content */}
      <div className={`flex-1 flex flex-col transition-all duration-300 ${sidebarCollapsed ? 'md:ml-20' : 'md:ml-64'}`}>
        {/* Top Navigation Bar */}
        <header className="bg-white dark:bg-gray-800 shadow-sm z-20 border-b border-gray-200 dark:border-gray-700">
          <div className="px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex">
                {/* Mobile menu button */}
                <Button
                  variant="ghost"
                  size="icon"
                  className="md:hidden"
                  onClick={toggleMobileMenu}
                >
                  <Menu className="h-5 w-5" />
                </Button>
                
                {/* Breadcrumb */}
                <div className="flex items-center">
                  <nav className="flex items-center" aria-label="Breadcrumb">
                    <ol className="flex items-center space-x-1 md:space-x-3">
                      <li className="flex items-center">
                        <Link 
                          href="/"
                          className="text-gray-600 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 flex items-center"
                        >
                          <Home className="w-4 h-4 mr-1" />
                          Home
                        </Link>
                      </li>
                      {location !== "/" && (
                        <li className="flex items-center">
                          <ChevronRight className="w-4 h-4 mx-2 text-gray-400" />
                          <span className="text-gray-600 dark:text-gray-300">{getPageName()}</span>
                        </li>
                      )}
                    </ol>
                  </nav>
                </div>
              </div>
              
              {/* Right Side Nav Items */}
              <div className="flex items-center space-x-4">
                {/* Dark Mode Toggle */}
                <div className="hidden md:flex items-center space-x-2">
                  <Sun className="h-4 w-4 text-gray-600 dark:text-gray-300" />
                  <Switch checked={darkMode} onCheckedChange={toggleDarkMode} />
                  <Moon className="h-4 w-4 text-gray-600 dark:text-gray-300" />
                </div>
                
                {/* Notifications */}
                <Button variant="ghost" size="icon" className="relative">
                  <Bell className="h-5 w-5" />
                  <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-500"></span>
                </Button>
                
                {/* User Menu */}
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="relative h-8 w-8 rounded-full">
                      <Avatar>
                        <AvatarFallback className="bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-100">
                          {user.firstName?.charAt(0)}{user.lastName?.charAt(0)}
                        </AvatarFallback>
                      </Avatar>
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="w-56">
                    <div className="p-2">
                      <p className="text-sm font-medium">{user.firstName} {user.lastName}</p>
                      <p className="text-xs text-muted-foreground">{user.email}</p>
                    </div>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem asChild>
                      <Link 
                        href="/settings/profile"
                        className="flex w-full"
                      >
                        Profile
                      </Link>
                    </DropdownMenuItem>
                    <DropdownMenuItem asChild>
                      <Link 
                        href="/settings"
                        className="flex w-full"
                      >
                        Settings
                      </Link>
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={handleLogout} disabled={logoutMutation.isPending}>
                      <LogOut className="mr-2 h-4 w-4" />
                      <span>{logoutMutation.isPending ? "Logging out..." : "Log out"}</span>
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>
          </div>
        </header>
        
        {/* Content Area */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 bg-gray-100 dark:bg-gray-900">
          {children}
        </main>
        
        {/* Footer */}
        <footer className="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
          <div className="px-4 py-4 sm:px-6 lg:px-8">
            <div className="flex flex-col sm:flex-row items-center justify-between">
              <p className="text-sm text-gray-500 dark:text-gray-400">
                &copy; {new Date().getFullYear()} WMS System. All rights reserved.
              </p>
              <div className="mt-2 sm:mt-0 flex items-center space-x-4">
                <Link 
                  href="/privacy"
                  className="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
                >
                  Privacy Policy
                </Link>
                <Link 
                  href="/terms"
                  className="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
                >
                  Terms of Service
                </Link>
                <Link 
                  href="/support"
                  className="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
                >
                  Contact Support
                </Link>
              </div>
            </div>
          </div>
        </footer>
      </div>
      
      <Toaster />
    </div>
  );
}
