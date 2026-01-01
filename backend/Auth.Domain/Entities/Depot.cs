using Auth.Domain.Entities;

namespace Auth.Domain.Entities;

public class Depot
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public string Address { get; set; } = null!;

    public int Capacity { get; set; }

    public bool IsActive { get; set; } = true;
    public ICollection<DepotProduct> DepotProducts { get; set; } = new List<DepotProduct>();

}
