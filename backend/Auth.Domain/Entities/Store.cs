namespace Auth.Domain.Entities;

public class Store
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Address { get; set; }
    public string Phone { get; set; }
    public bool IsActive { get; set; }

    public Guid DepotId { get; set; }

    public ICollection<StoreProduct> StoreProduct { get; set; } = new List<StoreProduct>();

    
    
}
