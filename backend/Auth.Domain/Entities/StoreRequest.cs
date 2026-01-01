using Auth.Domain.Entities;

public class StoreRequest
{
    public Guid Id { get; set; }

    public Guid StoreId { get; set; }
    public Guid DepotId { get; set; }
    public Guid ProductId { get; set; }

    public Guid? TruckId { get; set; }
    public Truck? Truck { get; set; }

    public int RequestedQuantity { get; set; }
    public string Status { get; set; } = "Pending";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? PickedUpAt { get; set; }
    public DateTime? DeliveredAt { get; set; }

    public Guid? ApprovedByDepotUserId { get; set; }
}
