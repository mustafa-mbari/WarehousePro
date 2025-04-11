import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import {
  Loader2,
  Plus,
  Search,
  Box,
  Ruler,
  Weight,
  Edit,
  Trash2,
  Check,
  X,
  MoreHorizontal,
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { 
  insertUnitOfMeasureSchema,
  UnitOfMeasure
} from "@shared/schema";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export default function UnitsOfMeasurePage() {
  const { toast } = useToast();
  const [searchTerm, setSearchTerm] = useState("");
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [currentUom, setCurrentUom] = useState<UnitOfMeasure | null>(null);

  // Define form schema with zod
  const uomFormSchema = insertUnitOfMeasureSchema
    .extend({
      isActive: z.boolean().default(true),
    });

  // Fetch units of measure
  const { data: uomData, isLoading, error } = useQuery({
    queryKey: ["/api/units-of-measure"],
  });

  // Create form for new UOM
  const createForm = useForm<z.infer<typeof uomFormSchema>>({
    resolver: zodResolver(uomFormSchema),
    defaultValues: {
      name: "",
      symbol: "",
      isActive: true,
    },
  });

  // Create form for editing UOM
  const editForm = useForm<z.infer<typeof uomFormSchema>>({
    resolver: zodResolver(uomFormSchema),
    defaultValues: {
      name: "",
      symbol: "",
      isActive: true,
    },
  });

  // Create UOM mutation
  const createMutation = useMutation({
    mutationFn: async (data: z.infer<typeof uomFormSchema>) => {
      return await apiRequest("POST", "/api/units-of-measure", data);
    },
    onSuccess: () => {
      toast({
        title: "Unit of Measure Created",
        description: "Unit of measure has been created successfully",
      });
      setIsCreateDialogOpen(false);
      createForm.reset();
      queryClient.invalidateQueries({ queryKey: ["/api/units-of-measure"] });
    },
    onError: (error) => {
      toast({
        title: "Error",
        description: `Failed to create unit of measure: ${error.message}`,
        variant: "destructive",
      });
    },
  });

  // Update UOM mutation
  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: z.infer<typeof uomFormSchema> }) => {
      return await apiRequest("PUT", `/api/units-of-measure/${id}`, data);
    },
    onSuccess: () => {
      toast({
        title: "Unit of Measure Updated",
        description: "Unit of measure has been updated successfully",
      });
      setIsEditDialogOpen(false);
      queryClient.invalidateQueries({ queryKey: ["/api/units-of-measure"] });
    },
    onError: (error) => {
      toast({
        title: "Error",
        description: `Failed to update unit of measure: ${error.message}`,
        variant: "destructive",
      });
    },
  });

  // Delete UOM mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      return await apiRequest("DELETE", `/api/units-of-measure/${id}`);
    },
    onSuccess: () => {
      toast({
        title: "Unit of Measure Deleted",
        description: "Unit of measure has been deleted successfully",
      });
      setIsDeleteDialogOpen(false);
      setCurrentUom(null);
      queryClient.invalidateQueries({ queryKey: ["/api/units-of-measure"] });
    },
    onError: (error) => {
      toast({
        title: "Error",
        description: `Failed to delete unit of measure: ${error.message}`,
        variant: "destructive",
      });
    },
  });

  const onCreateSubmit = (data: z.infer<typeof uomFormSchema>) => {
    createMutation.mutate(data);
  };

  const onEditSubmit = (data: z.infer<typeof uomFormSchema>) => {
    if (!currentUom) return;
    updateMutation.mutate({ id: currentUom.id, data });
  };

  const handleEdit = (uom: UnitOfMeasure) => {
    setCurrentUom(uom);
    editForm.reset({
      name: uom.name,
      symbol: uom.symbol,
      description: uom.description || "",
      isBase: uom.isBase || false,
      baseUomId: uom.baseUomId || "",
      conversionFactor: uom.conversionFactor ? uom.conversionFactor.toString() : "",
      type: uom.type || "QUANTITY",
      isActive: uom.isActive,
    });
    setIsEditDialogOpen(true);
  };

  const handleDelete = (uom: UnitOfMeasure) => {
    setCurrentUom(uom);
    setIsDeleteDialogOpen(true);
  };

  const confirmDelete = () => {
    if (currentUom) {
      deleteMutation.mutate(currentUom.id);
    }
  };

  // Filter UOMs based on search term
  const filteredUoms = uomData ? [...uomData]
    .filter((uom: UnitOfMeasure) => {
      return !searchTerm || 
        uom.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        uom.symbol.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (uom.description && uom.description.toLowerCase().includes(searchTerm.toLowerCase()));
    })
    .sort((a: UnitOfMeasure, b: UnitOfMeasure) => a.name.localeCompare(b.name)) : [];

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
              <X className="h-5 w-5 text-red-500 mr-2" />
              <CardTitle>Error Loading Units of Measure</CardTitle>
            </div>
            <CardDescription>
              There was a problem loading units of measure data.
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

  return (
    <DashboardLayout>
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Units of Measure</h1>
          <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
            Manage measurement units for your products
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="mr-2 h-4 w-4" /> New Unit
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[500px]">
              <DialogHeader>
                <DialogTitle>Create New Unit of Measure</DialogTitle>
                <DialogDescription>
                  Fill in the details to create a new unit of measure.
                </DialogDescription>
              </DialogHeader>
              <Form {...createForm}>
                <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <FormField
                      control={createForm.control}
                      name="name"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Name*</FormLabel>
                          <FormControl>
                            <Input placeholder="e.g. Kilogram" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={createForm.control}
                      name="symbol"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Symbol*</FormLabel>
                          <FormControl>
                            <Input placeholder="e.g. kg" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>
                  
                  <FormField
                    control={createForm.control}
                    name="description"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Description</FormLabel>
                        <FormControl>
                          <Input placeholder="Brief description" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  
                  <FormField
                    control={createForm.control}
                    name="type"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Type</FormLabel>
                        <FormControl>
                          <select
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                            {...field}
                            defaultValue="QUANTITY"
                          >
                            <option value="QUANTITY">Quantity</option>
                            <option value="WEIGHT">Weight</option>
                            <option value="LENGTH">Length</option>
                            <option value="VOLUME">Volume</option>
                            <option value="TIME">Time</option>
                            <option value="OTHER">Other</option>
                          </select>
                        </FormControl>
                        <FormDescription>
                          The category this unit belongs to
                        </FormDescription>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  
                  <FormField
                    control={createForm.control}
                    name="isBase"
                    render={({ field }) => (
                      <FormItem className="flex flex-row items-center justify-between rounded-lg border p-3 shadow-sm">
                        <div className="space-y-0.5">
                          <FormLabel>Base Unit</FormLabel>
                          <FormDescription>
                            Is this a base unit of measurement?
                          </FormDescription>
                        </div>
                        <FormControl>
                          <Switch
                            checked={field.value}
                            onCheckedChange={field.onChange}
                          />
                        </FormControl>
                      </FormItem>
                    )}
                  />
                  
                  <FormField
                    control={createForm.control}
                    name="isActive"
                    render={({ field }) => (
                      <FormItem className="flex flex-row items-center justify-between rounded-lg border p-3 shadow-sm">
                        <div className="space-y-0.5">
                          <FormLabel>Active</FormLabel>
                          <FormDescription>
                            Unit is available for use in the system
                          </FormDescription>
                        </div>
                        <FormControl>
                          <Switch
                            checked={field.value}
                            onCheckedChange={field.onChange}
                          />
                        </FormControl>
                      </FormItem>
                    )}
                  />
                  
                  <DialogFooter>
                    <Button type="submit" disabled={createMutation.isPending}>
                      {createMutation.isPending ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Creating...
                        </>
                      ) : (
                        "Create Unit"
                      )}
                    </Button>
                  </DialogFooter>
                </form>
              </Form>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Units of Measure</CardTitle>
          <CardDescription>
            View and manage all measurement units in your system
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="mb-4 flex gap-2">
            <div className="relative w-full sm:w-1/3">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500 dark:text-gray-400" />
              <Input
                placeholder="Search units..."
                className="pl-8"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>

          <div className="border rounded-md">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Symbol</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Base Unit</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredUoms?.length > 0 ? (
                  filteredUoms.map((uom: UnitOfMeasure) => (
                    <TableRow key={uom.id}>
                      <TableCell className="font-medium">{uom.name}</TableCell>
                      <TableCell>
                        <Badge variant="outline" className="font-mono">
                          {uom.symbol}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge className="capitalize" variant="secondary">
                          {uom.type ? uom.type.toLowerCase() : "Quantity"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {uom.isBase ? (
                          <Badge className="bg-green-100 text-green-800 dark:bg-green-800 dark:text-green-100">
                            Base Unit
                          </Badge>
                        ) : (
                          <span className="text-muted-foreground">—</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {uom.isActive !== false ? (
                          <div className="flex items-center">
                            <Check className="mr-1 h-4 w-4 text-green-500" />
                            <span className="text-green-600">Active</span>
                          </div>
                        ) : (
                          <div className="flex items-center">
                            <X className="mr-1 h-4 w-4 text-red-500" />
                            <span className="text-red-600">Inactive</span>
                          </div>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <span className="sr-only">Open menu</span>
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Actions</DropdownMenuLabel>
                            <DropdownMenuItem onClick={() => handleEdit(uom)}>
                              <Edit className="mr-2 h-4 w-4" />
                              Edit
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              className="text-red-600"
                              onClick={() => handleDelete(uom)}
                            >
                              <Trash2 className="mr-2 h-4 w-4" />
                              Delete
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-6 text-muted-foreground">
                      No units of measure found
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Edit Unit of Measure</DialogTitle>
            <DialogDescription>
              Update the details of this unit of measure.
            </DialogDescription>
          </DialogHeader>
          <Form {...editForm}>
            <form onSubmit={editForm.handleSubmit(onEditSubmit)} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <FormField
                  control={editForm.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Name*</FormLabel>
                      <FormControl>
                        <Input placeholder="e.g. Kilogram" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={editForm.control}
                  name="symbol"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Symbol*</FormLabel>
                      <FormControl>
                        <Input placeholder="e.g. kg" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              
              <FormField
                control={editForm.control}
                name="description"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description</FormLabel>
                    <FormControl>
                      <Input placeholder="Brief description" {...field} value={field.value || ""} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              <FormField
                control={editForm.control}
                name="type"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Type</FormLabel>
                    <FormControl>
                      <select
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        {...field}
                        value={field.value || "QUANTITY"}
                      >
                        <option value="QUANTITY">Quantity</option>
                        <option value="WEIGHT">Weight</option>
                        <option value="LENGTH">Length</option>
                        <option value="VOLUME">Volume</option>
                        <option value="TIME">Time</option>
                        <option value="OTHER">Other</option>
                      </select>
                    </FormControl>
                    <FormDescription>
                      The category this unit belongs to
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              <FormField
                control={editForm.control}
                name="isBase"
                render={({ field }) => (
                  <FormItem className="flex flex-row items-center justify-between rounded-lg border p-3 shadow-sm">
                    <div className="space-y-0.5">
                      <FormLabel>Base Unit</FormLabel>
                      <FormDescription>
                        Is this a base unit of measurement?
                      </FormDescription>
                    </div>
                    <FormControl>
                      <Switch
                        checked={field.value || false}
                        onCheckedChange={field.onChange}
                      />
                    </FormControl>
                  </FormItem>
                )}
              />
              
              <FormField
                control={editForm.control}
                name="isActive"
                render={({ field }) => (
                  <FormItem className="flex flex-row items-center justify-between rounded-lg border p-3 shadow-sm">
                    <div className="space-y-0.5">
                      <FormLabel>Active</FormLabel>
                      <FormDescription>
                        Unit is available for use in the system
                      </FormDescription>
                    </div>
                    <FormControl>
                      <Switch
                        checked={field.value !== false}
                        onCheckedChange={field.onChange}
                      />
                    </FormControl>
                  </FormItem>
                )}
              />
              
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={updateMutation.isPending}>
                  {updateMutation.isPending ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Updating...
                    </>
                  ) : (
                    "Save Changes"
                  )}
                </Button>
              </DialogFooter>
            </form>
          </Form>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>Confirm Deletion</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this unit of measure? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <div className="py-4">
            <p className="text-sm font-medium">
              Unit: <span className="font-bold">{currentUom?.name} ({currentUom?.symbol})</span>
            </p>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
              Cancel
            </Button>
            <Button 
              variant="destructive" 
              onClick={confirmDelete} 
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Deleting...
                </>
              ) : (
                "Delete Unit"
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </DashboardLayout>
  );
}