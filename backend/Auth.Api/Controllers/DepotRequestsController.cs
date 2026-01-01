using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Auth.Domain.Entities;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/depot-requests")]
[Authorize(Roles = "Depot")]
public class DepotRequestsController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public DepotRequestsController(LogisticsDbContext context)
    {
        _context = context;
    }

    private Guid GetDepotId()
    {
        var depotIdStr =
            User.FindFirstValue("DepotId") ??
            User.FindFirstValue("depotId");

        if (string.IsNullOrWhiteSpace(depotIdStr))
            throw new UnauthorizedAccessException("DepotId claim bulunamadı.");

        return Guid.Parse(depotIdStr);
    }

    private Guid GetDepotUserId()
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier) ??
            User.FindFirstValue("sub");

        if (string.IsNullOrWhiteSpace(userIdStr))
            throw new UnauthorizedAccessException("UserId (sub) claim bulunamadı.");

        return Guid.Parse(userIdStr);
    }

    // GET: api/depot-requests/my?status=Pending
    [HttpGet("my")]
    public async Task<IActionResult> GetMyDepotRequests([FromQuery] string? status = "Pending")
    {
        var depotId = GetDepotId();

        var q = _context.StoreRequests.AsNoTracking().Where(r => r.DepotId == depotId);

        if (!string.IsNullOrWhiteSpace(status))
            q = q.Where(r => r.Status == status);

        var list = await q
            .Join(_context.Stores, r => r.StoreId, s => s.Id, (r, s) => new { r, s })
            .Join(_context.Products, x => x.r.ProductId, p => p.Id, (x, p) => new
            {
                id = x.r.Id,
                storeId = x.s.Id,
                storeName = x.s.Name,
                productId = p.Id,
                productName = p.Name,
                productCode = p.Code,
                requestedQuantity = x.r.RequestedQuantity,
                status = x.r.Status,
                createdAt = x.r.CreatedAt
            })
            .OrderByDescending(x => x.createdAt)
            .ToListAsync();

        return Ok(list);
    }

    public class ApproveDepotRequestDto
    {
        public Guid TruckId { get; set; }
    }

    // PATCH: api/depot-requests/{id}/approve
    [HttpPatch("{id:guid}/approve")]
    public async Task<IActionResult> Approve(Guid id, [FromBody] ApproveDepotRequestDto dto)
    {
        if (dto.TruckId == Guid.Empty)
            return BadRequest("TruckId zorunlu.");

        var depotId = GetDepotId();
        var depotUserId = GetDepotUserId();

        var req = await _context.StoreRequests.FirstOrDefaultAsync(r => r.Id == id && r.DepotId == depotId);
        if (req == null) return NotFound();

        if (req.Status != "Pending")
            return BadRequest("Sadece Pending talepler onaylanabilir.");

        var truckExists = await _context.Trucks.AnyAsync(t => t.Id == dto.TruckId);
        if (!truckExists) return BadRequest("Kamyon bulunamadı.");

        req.Status = "Approved";
        req.TruckId = dto.TruckId;
        req.ApprovedByDepotUserId = depotUserId;

        await _context.SaveChangesAsync();
        return Ok(new { message = "Onaylandı." });
    }

    // PATCH: api/depot-requests/{id}/reject
    [HttpPatch("{id:guid}/reject")]
    public async Task<IActionResult> Reject(Guid id)
    {
        var depotId = GetDepotId();

        var req = await _context.StoreRequests.FirstOrDefaultAsync(r => r.Id == id && r.DepotId == depotId);
        if (req == null) return NotFound();

        if (req.Status != "Pending")
            return BadRequest("Sadece Pending talepler reddedilebilir.");

        req.Status = "Rejected";
        await _context.SaveChangesAsync();

        return Ok(new { message = "Reddedildi." });
    }


    [HttpGet("store-requests")]
[Authorize(Roles = "Depot")]
public async Task<IActionResult> GetStoreRequestsForDepot()
{
    var depotId = Guid.Parse(
        User.FindFirstValue("DepotId") ??
        User.FindFirstValue("depotId")!
    );

    var list =
        from r in _context.StoreRequests
        join s in _context.Stores on r.StoreId equals s.Id
        join p in _context.Products on r.ProductId equals p.Id
        where r.DepotId == depotId
        orderby r.CreatedAt descending
        select new
        {
            r.Id,
            StoreName = s.Name,
            ProductName = p.Name,
            r.RequestedQuantity,
            r.Status,
            r.CreatedAt,
            r.PickedUpAt,
            r.DeliveredAt
        };

    return Ok(await list.ToListAsync());
}


}
