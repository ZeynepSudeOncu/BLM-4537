using Auth.Application.DTOs.StoreProduct;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/store-products")]
[Authorize(Roles = "Store")]
public class StoreProductController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public StoreProductController(LogisticsDbContext context)
    {
        _context = context;
    }

    // GET: api/store-products/my
    [HttpGet("my")]
    public async Task<IActionResult> GetMyStoreProduct()
    {
        var storeIdStr =
            // User.FindFirstValue("storeId") ??
            User.FindFirstValue("StoreId");

        if (string.IsNullOrEmpty(storeIdStr))
            return Unauthorized("StoreId claim bulunamadı.");

        var storeId = Guid.Parse(storeIdStr);

        var products = await _context.StoreProduct
            .Where(sp => sp.StoreId == storeId)
            .Include(sp => sp.Product)
            .Select(sp => new StoreProductResponse
            {
                Id = sp.Id,
                ProductId = sp.ProductId,
                Name = sp.Product.Name,
                Code = sp.Product.Code,
                Quantity = sp.Quantity
            })
            .OrderBy(p => p.Code)
            .ToListAsync();

        return Ok(products);
    }
}
