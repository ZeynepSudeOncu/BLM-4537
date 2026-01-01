using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Auth.Domain.Entities;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/driver")]
[Authorize(Roles = "Driver")]
public class DriverProfileController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public DriverProfileController(LogisticsDbContext context)
    {
        _context = context;
    }

    // 🔐 JWT içinden UserId al
    private Guid GetUserId()
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier) ??
            User.FindFirstValue(JwtRegisteredClaimNames.Sub) ??
            User.FindFirstValue("sub");

        if (string.IsNullOrWhiteSpace(userIdStr))
            throw new UnauthorizedAccessException("UserId claim bulunamadı.");

        return Guid.Parse(userIdStr);
    }

    // 🚚 Driver + Truck bilgisi
    private async Task<Driver?> GetDriver()
    {
        var userId = GetUserId();

        return await _context.Drivers
            .Include(d => d.Truck)
            .AsNoTracking()
            .FirstOrDefaultAsync(d => d.UserId == userId);
    }

    // =====================================================
    // GET: api/driver/me
    // Driver dashboard için profil + istatistik
    // =====================================================
    [HttpGet("me")]
    public async Task<IActionResult> GetMe()
    {
        var driver = await GetDriver();

        if (driver == null)
            return NotFound("Driver bulunamadı.");

        int totalDeliveries = 0;
        int activeDeliveries = 0;
        int completedDeliveries = 0;

        if (driver.TruckId.HasValue)
        {
            var truckId = driver.TruckId.Value;

            totalDeliveries = await _context.StoreRequests
                .AsNoTracking()
                .CountAsync(r => r.TruckId == truckId);

            activeDeliveries = await _context.StoreRequests
                .AsNoTracking()
                .CountAsync(r =>
                    r.TruckId == truckId &&
                    (r.Status == "Approved" || r.Status == "InTransit"));

            completedDeliveries = await _context.StoreRequests
                .AsNoTracking()
                .CountAsync(r =>
                    r.TruckId == truckId &&
                    r.Status == "Delivered");
        }

        return Ok(new
        {
            driverName = driver.FullName,
            driverStatus = driver.Status,          // "Müsait" / "Yolda"
            truckPlate = driver.Truck?.Plate,

            totalDeliveries,       // bugüne kadar
            activeDeliveries,      // şu an aktif
            completedDeliveries    // teslim edilen
        });
    }
}
