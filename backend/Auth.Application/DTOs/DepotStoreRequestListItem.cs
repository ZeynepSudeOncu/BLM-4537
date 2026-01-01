namespace Auth.Application.DTOs;

public class DepotStoreRequestListItem
{
    public Guid Id { get; set; }

    public Guid StoreId { get; set; }
    public string StoreName { get; set; } = null!;

    public Guid ProductId { get; set; }
    public string ProductName { get; set; } = null!;
    public string ProductCode { get; set; } = null!;

    public int RequestedQuantity { get; set; }
    public string Status { get; set; } = null!;
    public DateTime CreatedAt { get; set; }

    // Depo onaylayınca dolacak
    public Guid? TruckId { get; set; }
}
