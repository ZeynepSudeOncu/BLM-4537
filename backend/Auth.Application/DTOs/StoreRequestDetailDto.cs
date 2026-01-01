namespace Auth.Application.DTOs;

public class StoreRequestDetailDto
{
    public Guid Id { get; set; }
    public string StoreName { get; set; } = null!;
    public string ProductName { get; set; } = null!;
    public string ProductCode { get; set; } = null!;
    public int RequestedQuantity { get; set; }
    public string Status { get; set; } = null!;
    public string? TruckPlateNumber { get; set; }
    public string? DriverName { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? PickedUpAt { get; set; }
    public DateTime? DeliveredAt { get; set; }
}