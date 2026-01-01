using Auth.Application.DTOs;
using Auth.Domain.Entities;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/store-requests")]
[Authorize(Roles = "Store")]
public class StoreRequestsController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public StoreRequestsController(LogisticsDbContext context)
    {
        _context = context;
    }

    private Guid GetStoreId()
    {
        var storeIdStr =
            User.FindFirstValue("storeId") ??
            User.FindFirstValue("StoreId");

        if (string.IsNullOrWhiteSpace(storeIdStr))
            throw new UnauthorizedAccessException("StoreId claim yok");

        return Guid.Parse(storeIdStr);
    }

    // POST: api/store-requests
    [HttpPost]
    public async Task<IActionResult> CreateRequest([FromBody] CreateStoreRequestDto dto)
    {
        if (dto.ProductId == Guid.Empty)
            return BadRequest("ProductId boş olamaz.");

        if (dto.RequestedQuantity <= 0)
            return BadRequest("RequestedQuantity 0'dan büyük olmalı.");

        var storeId = GetStoreId();

        var store = await _context.Stores
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Id == storeId);

        if (store == null)
            return BadRequest("Store bulunamadı.");

        if (store.DepotId == Guid.Empty)
            return BadRequest("Store bir depoya bağlı değil.");

        var productExists = await _context.Products.AnyAsync(p => p.Id == dto.ProductId);
        if (!productExists)
            return BadRequest("Ürün bulunamadı.");

        var request = new StoreRequest
        {
            Id = Guid.NewGuid(),
            StoreId = storeId,
            DepotId = store.DepotId,
            ProductId = dto.ProductId,
            RequestedQuantity = dto.RequestedQuantity,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        _context.StoreRequests.Add(request);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Talep oluşturuldu.", id = request.Id });
    }

    // GET: api/store-requests/my
    [HttpGet("my")]
    public async Task<IActionResult> GetMyRequests()
    {
        var storeId = GetStoreId();

        var list = await _context.StoreRequests
            .AsNoTracking()
            .Where(r => r.StoreId == storeId)
            .Join(_context.Products,
                r => r.ProductId,
                p => p.Id,
                (r, p) => new
                {
                    id = r.Id,
                    status = r.Status,
                    requestedQuantity = r.RequestedQuantity,
                    createdAt = r.CreatedAt,
                    pickedUpAt = r.PickedUpAt,
                    deliveredAt = r.DeliveredAt,
                    productName = p.Name,
                    productCode = p.Code
                })
            .OrderByDescending(x => x.createdAt)
            .ToListAsync();

        return Ok(list);
    }
}
