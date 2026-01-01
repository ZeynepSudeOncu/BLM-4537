namespace Auth.Application.DTOs.StoreProduct;

public class StoreProductResponse
{
    public Guid Id { get; set; }          // StoreProduct.Id
    public Guid ProductId { get; set; }   // Products.Id
    public string Name { get; set; } = default!;
    public string Code { get; set; } = default!;
    public int Quantity { get; set; }
}
