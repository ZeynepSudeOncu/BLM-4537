namespace Auth.Domain.Entities;
public class DepotProduct
{
    public Guid Id { get; set; }

    public Guid DepotId { get; set; }
    public Depot Depot { get; set; } = default!;

    public Guid ProductId { get; set; }
    public Product Product { get; set; } = default!;

    public int Quantity { get; set; }
}
