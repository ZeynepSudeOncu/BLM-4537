namespace Auth.Domain.Entities;

public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public string Code { get; set; } = default!;

    public ICollection<DepotProduct> DepotProducts { get; set; } = new List<DepotProduct>();
    public ICollection<StoreProduct> StoreProduct { get; set; } = new List<StoreProduct>();
}


