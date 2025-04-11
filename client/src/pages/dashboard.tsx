import { useQuery } from "@tanstack/react-query";
import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { StatCard } from "@/components/ui/stat-card";
import { StatusBadge } from "@/components/ui/status-badge";
import { Separator } from "@/components/ui/separator";
import { 
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, 
  Cell, PieChart, Pie, Sector
} from "recharts";
import { 
  Loader2, 
  Plus, 
  Download, 
  Coins, 
  Package, 
  Clock, 
  AlertTriangle, 
  ChevronRight,
  CheckCircle2,
  Truck,
  AlertOctagon,
  Database
} from "lucide-react";
import { useState } from "react";
import { Link } from "wouter";

export default function Dashboard() {
  const [activeIndex, setActiveIndex] = useState(0);
  
  const { data, isLoading, error } = useQuery({
    queryKey: ["/api/dashboard/stats"],
  });
  
  const { data: activities, isLoading: activitiesLoading } = useQuery({
    queryKey: ["/api/dashboard/activities"],
  });
  
  if (isLoading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-full">
          <Loader2 className="h-10 w-10 animate-spin text-primary-500" />
        </div>
      </DashboardLayout>
    );
  }
  
  if (error) {
    return (
      <DashboardLayout>
        <div className="flex flex-col items-center justify-center h-full">
          <AlertOctagon className="h-10 w-10 text-red-500 mb-2" />
          <h2 className="text-xl font-bold">Error loading dashboard data</h2>
          <p className="text-muted-foreground">Please try again later</p>
        </div>
      </DashboardLayout>
    );
  }
  
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(value);
  };
  
  const renderCategoryColors = () => {
    const colors = ["#3B82F6", "#10B981", "#F59E0B", "#EF4444", "#8B5CF6"];
    
    return data.inventoryLevelsByCategory.map((category: any, index: number) => (
      <div key={index} className="flex items-center mt-2">
        <div className="w-3 h-3 rounded-sm mr-2" style={{ backgroundColor: colors[index % colors.length] }}></div>
        <span className="text-sm">{category.category || "Uncategorized"}</span>
      </div>
    ));
  };
  
  const onPieEnter = (_: any, index: number) => {
    setActiveIndex(index);
  };
  
  const renderActiveShape = (props: any) => {
    const { cx, cy, innerRadius, outerRadius, startAngle, endAngle, fill, payload, value } = props;
  
    return (
      <g>
        <text x={cx} y={cy} dy={-20} textAnchor="middle" fill="#888">
          {payload.category || "Uncategorized"}
        </text>
        <text x={cx} y={cy} dy={10} textAnchor="middle" fill="#333" className="text-xl font-semibold">
          {value}
        </text>
        <text x={cx} y={cy} dy={30} textAnchor="middle" fill="#888">
          Units
        </text>
        <Sector
          cx={cx}
          cy={cy}
          innerRadius={innerRadius}
          outerRadius={outerRadius + 10}
          startAngle={startAngle}
          endAngle={endAngle}
          fill={fill}
        />
        <Sector
          cx={cx}
          cy={cy}
          startAngle={startAngle}
          endAngle={endAngle}
          innerRadius={outerRadius + 12}
          outerRadius={outerRadius + 15}
          fill={fill}
        />
      </g>
    );
  };
  
  const getActivityTypeIcon = (type: string) => {
    switch(type) {
      case 'RECEIVED':
        return <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center">
          <Package className="text-blue-600 dark:text-blue-400 h-4 w-4" />
        </div>;
      case 'SHIPPED':
        return <div className="w-8 h-8 rounded-full bg-green-100 dark:bg-green-900 flex items-center justify-center">
          <Truck className="text-green-600 dark:text-green-400 h-4 w-4" />
        </div>;
      case 'ADJUSTMENT':
        return <div className="w-8 h-8 rounded-full bg-yellow-100 dark:bg-yellow-900 flex items-center justify-center">
          <Database className="text-yellow-600 dark:text-yellow-400 h-4 w-4" />
        </div>;
      default:
        return <div className="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center">
          <Package className="text-gray-600 dark:text-gray-400 h-4 w-4" />
        </div>;
    }
  };
  
  const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6'];
  
  return (
    <DashboardLayout>
      {/* Page Title & Quick Actions */}
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">An overview of your warehouse operations</p>
        </div>
        <div className="mt-4 sm:mt-0 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
          <Button className="inline-flex items-center">
            <Plus className="mr-2 h-4 w-4" /> New Order
          </Button>
          <Button variant="outline" className="inline-flex items-center">
            <Download className="mr-2 h-4 w-4" /> Export
          </Button>
        </div>
      </div>
      
      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard 
          icon={<Coins className="text-primary-600 dark:text-primary-400 h-5 w-5" />}
          title="Total Inventory Value"
          value={formatCurrency(data.inventoryValue || 0)}
          trend={{ direction: "up", value: "5.3% from last month" }}
          iconClassName="bg-primary-100 dark:bg-primary-900"
        />
        
        <StatCard 
          icon={<Package className="text-indigo-600 dark:text-indigo-400 h-5 w-5" />}
          title="Active Products"
          value={data.activeProducts || 0}
          trend={{ direction: "down", value: "2.1% from last month" }}
          iconClassName="bg-indigo-100 dark:bg-indigo-900"
        />
        
        <StatCard 
          icon={<Clock className="text-yellow-600 dark:text-yellow-400 h-5 w-5" />}
          title="Pending Orders"
          value={data.pendingOrders || 0}
          trend={{ direction: "up", value: "10.8% from last month" }}
          iconClassName="bg-yellow-100 dark:bg-yellow-900"
        />
        
        <StatCard 
          icon={<AlertTriangle className="text-red-600 dark:text-red-400 h-5 w-5" />}
          title="Low Stock Items"
          value={data.lowStockItemsCount || 0}
          trend={{ direction: "up", value: "3 more than last week" }}
          iconClassName="bg-red-100 dark:bg-red-900"
        />
      </div>
      
      {/* Charts & Tables Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        {/* Inventory Levels Chart */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-lg font-medium">Inventory Levels by Category</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] flex flex-col md:flex-row items-center justify-center">
              <div className="w-full h-full md:w-3/4">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      activeIndex={activeIndex}
                      activeShape={renderActiveShape}
                      data={data.inventoryLevelsByCategory}
                      cx="50%"
                      cy="50%"
                      innerRadius={70}
                      outerRadius={90}
                      fill="#8884d8"
                      dataKey="value"
                      onMouseEnter={onPieEnter}
                    >
                      {data.inventoryLevelsByCategory.map((_: any, index: number) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-4 md:mt-0 md:w-1/4">
                <h4 className="text-sm font-medium mb-2">Categories</h4>
                {renderCategoryColors()}
              </div>
            </div>
          </CardContent>
        </Card>
        
        {/* Order Trends Chart */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-lg font-medium">Order Trends</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart
                  data={data.orderTrends}
                  margin={{ top: 5, right: 30, left: 20, bottom: 25 }}
                >
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Legend wrapperStyle={{ bottom: 0 }} />
                  <Line type="monotone" dataKey="incoming" stroke="#3B82F6" name="Incoming" activeDot={{ r: 8 }} />
                  <Line type="monotone" dataKey="outgoing" stroke="#EF4444" name="Outgoing" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>
      
      {/* Recent Activities and Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        {/* Recent Activities */}
        <Card className="lg:col-span-2">
          <CardHeader className="pb-2 flex flex-row items-center justify-between">
            <CardTitle className="text-lg font-medium">Recent Activities</CardTitle>
            <Button variant="link" size="sm" asChild>
              <Link href="/reports/activities">View all</Link>
            </Button>
          </CardHeader>
          <CardContent>
            {activitiesLoading ? (
              <div className="flex justify-center py-8">
                <Loader2 className="h-8 w-8 animate-spin text-primary-500" />
              </div>
            ) : (
              <ul className="divide-y divide-gray-200 dark:divide-gray-700">
                {activities && activities.length > 0 ? (
                  activities.slice(0, 4).map((activity: any, index: number) => (
                    <li key={index} className="py-3">
                      <div className="flex items-start">
                        <div className="flex-shrink-0">
                          {getActivityTypeIcon(activity.referenceType)}
                        </div>
                        <div className="ml-3 flex-1">
                          <p className="text-sm font-medium text-gray-900 dark:text-white">
                            {activity.direction === 'IN' ? 'Product received' : 'Product shipped'}: {activity.quantity} units
                          </p>
                          <p className="text-sm text-gray-500 dark:text-gray-400">
                            {activity.referenceType} #{activity.referenceId} • {new Date(activity.createdAt).toLocaleString()}
                          </p>
                        </div>
                      </div>
                    </li>
                  ))
                ) : (
                  <p className="py-4 text-center text-muted-foreground">No recent activities to display</p>
                )}
              </ul>
            )}
          </CardContent>
        </Card>
        
        {/* Alerts & Notifications */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-lg font-medium">Alerts & Notifications</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="divide-y divide-gray-200 dark:divide-gray-700">
              <li className="py-3">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <span className="w-2 h-2 rounded-full bg-red-600"></span>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      Critical: {data.lowStockItemsCount} products out of stock
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      2 hours ago
                    </p>
                  </div>
                </div>
              </li>
              <li className="py-3">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <span className="w-2 h-2 rounded-full bg-yellow-500"></span>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      Warning: Shipment delay detected
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      5 hours ago
                    </p>
                  </div>
                </div>
              </li>
              <li className="py-3">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <span className="w-2 h-2 rounded-full bg-blue-500"></span>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      Info: System maintenance scheduled
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Tomorrow, 2:00 AM
                    </p>
                  </div>
                </div>
              </li>
              <li className="py-3">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <span className="w-2 h-2 rounded-full bg-green-500"></span>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      Success: Database backup completed
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Yesterday
                    </p>
                  </div>
                </div>
              </li>
            </ul>
          </CardContent>
        </Card>
      </div>
      
      {/* Recent Orders */}
      <Card className="mb-6">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-lg font-medium">Recent Orders</CardTitle>
          <Button variant="link" size="sm" asChild>
            <Link href="/orders">View all orders</Link>
          </Button>
        </CardHeader>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead className="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Order ID</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Customer</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Date</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Status</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Total</th>
                <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {data.recentOrders && data.recentOrders.length > 0 ? (
                data.recentOrders.map((order: any) => (
                  <tr key={order.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                      #{order.orderNumber}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {order.customerId || 'Walk-in Customer'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {new Date(order.orderDate).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <StatusBadge status={order.status.toLowerCase() as any} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {formatCurrency(order.totalAmount || 0)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <Link href={`/orders/${order.id}`}>
                        <a className="text-primary-600 dark:text-primary-400 hover:text-primary-900 dark:hover:text-primary-300 mr-3">
                          View
                        </a>
                      </Link>
                      <button className="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100">
                        <ChevronRight className="h-4 w-4" />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="px-6 py-4 text-center text-sm text-gray-500 dark:text-gray-400">
                    No recent orders found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </DashboardLayout>
  );
}
