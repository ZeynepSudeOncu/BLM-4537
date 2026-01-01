using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Auth.Application.DTOs;
using Auth.Domain.Entities;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/driver/deliveries")]
[Authorize(Roles = "Driver")]
public class DriverDeliveriesController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public DriverDeliveriesController(LogisticsDbContext context)
    {
        _context = context;
    }

    private Guid GetUserId()
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier) ??
            User.FindFirstValue(JwtRegisteredClaimNames.Sub) ??
            User.FindFirstValue("sub");

        if (string.IsNullOrWhiteSpace(userIdStr))
            throw new UnauthorizedAccessException("UserId (sub) claim bulunamadı.");

        return Guid.Parse(userIdStr);
    }

    private async Task<Driver?> GetDriver()
    {
        var userId = GetUserId();
        return await _context.Drivers.Include(d => d.Truck).FirstOrDefaultAsync(d => d.UserId == userId);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyDeliveries([FromQuery] string? status = null)
    {
        var driver = await GetDriver();
        if (driver == null) return NotFound();
        if (driver.TruckId == null) return BadRequest("Kamyon atanmadı.");

        var query = _context.StoreRequests
            .AsNoTracking()
            .Include(r => r.Truck)
            .Where(r => r.TruckId == driver.TruckId);

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(r => r.Status == status);

        var list = await query
            .Join(_context.Stores, r => r.StoreId, s => s.Id, (r, s) => new { r, s })
            .Join(_context.Products, x => x.r.ProductId, p => p.Id, (x, p) =>
                new StoreRequestDetailDto
                {
                    Id = x.r.Id,
                    StoreName = x.s.Name,
                    ProductName = p.Name,
                    ProductCode = p.Code,
                    RequestedQuantity = x.r.RequestedQuantity,
                    Status = x.r.Status,
                    TruckPlateNumber = x.r.Truck!.Plate,
                    DriverName = driver.FullName,
                    CreatedAt = x.r.CreatedAt,
                    PickedUpAt = x.r.PickedUpAt,
                    DeliveredAt = x.r.DeliveredAt
                })
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return Ok(list);
    }

    [HttpPatch("{id:guid}/pickup")]
    public async Task<IActionResult> Pickup(Guid id)
    {
        var driver = await GetDriver();
        if (driver?.TruckId == null) return BadRequest();

        var req = await _context.StoreRequests
            .FirstOrDefaultAsync(r => r.Id == id && r.TruckId == driver.TruckId);

        if (req == null) return NotFound();
        if (req.Status != "Approved")
            return BadRequest("Sadece Approved teslimatlar alınabilir.");

        var depotProduct = await _context.DepotProducts
            .FirstOrDefaultAsync(x =>
                x.DepotId == req.DepotId &&
                x.ProductId == req.ProductId);

        if (depotProduct == null || depotProduct.Quantity < req.RequestedQuantity)
            return BadRequest("Depoda yeterli stok yok.");

        depotProduct.Quantity -= req.RequestedQuantity;

        req.Status = "InTransit";
        req.PickedUpAt = DateTime.UtcNow;
        driver.Status = "Yolda";

        await _context.SaveChangesAsync();
        return Ok(new { message = "Teslim alındı, depo stoğu düşürüldü." });
    }

    [HttpPatch("{id:guid}/deliver")]
public async Task<IActionResult> Deliver(Guid id)
{
    var driver = await GetDriver();
    if (driver?.TruckId == null) return BadRequest();

    var req = await _context.StoreRequests
        .FirstOrDefaultAsync(r => r.Id == id && r.TruckId == driver.TruckId);

    if (req == null) return NotFound();
    if (req.Status != "InTransit")
        return BadRequest("Sadece yoldaki teslimatlar teslim edilebilir.");

    var storeProduct = await _context.StoreProduct
        .FirstOrDefaultAsync(x =>
            x.StoreId == req.StoreId &&
            x.ProductId == req.ProductId);

    if (storeProduct == null)
    {
        storeProduct = new StoreProduct
        {
            Id = Guid.NewGuid(),
            StoreId = req.StoreId,
            ProductId = req.ProductId,
            Quantity = 0
        };
        _context.StoreProduct.Add(storeProduct);
    }

    storeProduct.Quantity += req.RequestedQuantity;

    req.Status = "Delivered";
    req.DeliveredAt = DateTime.UtcNow;
    driver.Status = "Müsait";

    await _context.SaveChangesAsync();
    return Ok(new { message = "Teslim edildi, store stoğu arttı." });
}


}
