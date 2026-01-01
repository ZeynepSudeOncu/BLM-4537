namespace Auth.Application.DTOs.DepotProducts;

public class DepotProductResponse
{
    public Guid Id { get; set; }          // DepotProducts.Id
    public Guid ProductId { get; set; }   // Products.Id
    public string Name { get; set; } = default!;
    public string Code { get; set; } = default!;
    public int Quantity { get; set; }
}
