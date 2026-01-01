namespace Auth.Domain.Entities;

public class Order
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string StoreId { get; set; }
    public string DepotId { get; set; }
    public string TruckId { get; set; }
    public string DriverId { get; set; }
    public string Status { get; set; } = "Beklemede";
    public DateTime Date { get; set; } = DateTime.UtcNow;
}
