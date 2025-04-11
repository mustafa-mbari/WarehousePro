import { cn } from "@/lib/utils";

type StatusType = "completed" | "processing" | "shipped" | "pending" | "cancelled" | "draft";

interface StatusBadgeProps {
  status: StatusType;
  className?: string;
}

export function StatusBadge({ status, className }: StatusBadgeProps) {
  const getStatusStyles = (status: StatusType) => {
    switch (status) {
      case "completed":
        return "bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200";
      case "processing":
        return "bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200";
      case "shipped":
        return "bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200";
      case "pending":
        return "bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200";
      case "cancelled":
        return "bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200";
      case "draft":
        return "bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200";
      default:
        return "bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200";
    }
  };

  const getStatusText = (status: StatusType) => {
    return status.charAt(0).toUpperCase() + status.slice(1);
  };

  return (
    <span className={cn(
      "px-2 inline-flex text-xs leading-5 font-semibold rounded-full", 
      getStatusStyles(status),
      className
    )}>
      {getStatusText(status)}
    </span>
  );
}
