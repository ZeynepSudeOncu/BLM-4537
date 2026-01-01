using Auth.Application.DTOs.DepotProducts;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/depot-products")]
[Authorize(Roles = "Depot")]
public class DepotProductsController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public DepotProductsController(LogisticsDbContext context)
    {
        _context = context;
    }

    private Guid GetDepotId()
    {
        var depotIdStr =
            User.FindFirstValue("depotId") ??
            User.FindFirstValue("DepotId");

        if (string.IsNullOrEmpty(depotIdStr))
            throw new UnauthorizedAccessException("DepotId claim bulunamadı.");

        return Guid.Parse(depotIdStr);
    }

    // GET: api/depot-products/my
    [HttpGet("my")]
    public async Task<IActionResult> GetMyDepotProducts()
    {
        var depotId = GetDepotId();

        var products = await _context.DepotProducts
            .Where(dp => dp.DepotId == depotId)
            .Include(dp => dp.Product)
            .Select(dp => new DepotProductResponse
            {
                Id = dp.Id,
                ProductId = dp.ProductId,
                Name = dp.Product.Name,
                Code = dp.Product.Code,
                Quantity = dp.Quantity
            })
            .OrderBy(p => p.Code)
            .ToListAsync();

        return Ok(products);
    }

    // ✅ GET: api/depot-products/{productId}
    // Depodaki tek bir ürünün detayını döner (depot + product filtreli)
    [HttpGet("{productId:guid}")]
    public async Task<IActionResult> GetMyDepotProductDetail([FromRoute] Guid productId)
    {
        var depotId = GetDepotId();

        var dp = await _context.DepotProducts
            .Where(x => x.DepotId == depotId && x.ProductId == productId)
            .Include(x => x.Product)
            .Select(x => new
            {
                id = x.Id,              // DepotProducts.Id
                productId = x.ProductId, // Products.Id
                name = x.Product.Name,
                code = x.Product.Code,
                quantity = x.Quantity
            })
            .FirstOrDefaultAsync();

        if (dp == null)
            return NotFound("Ürün bulunamadı");

        return Ok(dp);
    }

    [HttpGet("{productId:guid}/movements")]
public async Task<IActionResult> GetMyDepotProductMovements([FromRoute] Guid productId)
{
    var depotId = GetDepotId();

    var list =
        await (from r in _context.StoreRequests
               join s in _context.Stores
                   on r.StoreId equals s.Id
               where r.DepotId == depotId && r.ProductId == productId
               orderby r.CreatedAt descending
               select new
               {
                   id = r.Id,
                   storeName = s.Name,              // ✅ ARTIK GELİR
                   requestedQuantity = r.RequestedQuantity,
                   status = r.Status,
                   createdAt = r.CreatedAt,
                   deliveredAt = r.DeliveredAt
               })
               .ToListAsync();

    return Ok(list);
}

}
