using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/admin/dashboard")]
[Authorize(Roles = "Admin")]
public class AdminDashboardController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public AdminDashboardController(LogisticsDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetDashboard()
    {
        // ---------- ÜRÜN & STOK ----------
        var totalProducts = await _context.Products.CountAsync();

        var totalDepotStock = await _context.DepotProducts.SumAsync(x => (int?)x.Quantity) ?? 0;
        var totalStoreStock = await _context.StoreProduct.SumAsync(x => (int?)x.Quantity) ?? 0;

        var totalStock = totalDepotStock + totalStoreStock;

        // ---------- TALEPLER ----------
        var pendingRequests = await _context.StoreRequests.CountAsync(x => x.Status == "Pending");
        var onTheWayRequests = await _context.StoreRequests.CountAsync(x =>
            x.Status == "OnTheWay" || x.Status == "InTransit");
        var deliveredRequests = await _context.StoreRequests.CountAsync(x => x.Status == "Delivered");

        // ---------- GÜNLÜK TALEP GRAFİĞİ (SON 7 GÜN) ----------
        var last7Days = DateTime.UtcNow.Date.AddDays(-6);

        var dailyRequests = await _context.StoreRequests
            .Where(x => x.CreatedAt >= last7Days)
            .GroupBy(x => x.CreatedAt.Date)
            .Select(g => new
            {
                date = g.Key,
                count = g.Count()
            })
            .OrderBy(x => x.date)
            .ToListAsync();

        return Ok(new
        {
            cards = new
            {
                totalProducts,
                totalStock,
                pendingRequests,
                onTheWayRequests,
                deliveredRequests
            },
            charts = new
            {
                dailyRequests,
                statusDistribution = new
                {
                    pending = pendingRequests,
                    onTheWay = onTheWayRequests,
                    delivered = deliveredRequests
                }
            }
        });
    }

    [HttpGet("critical-stocks")]
    public async Task<IActionResult> GetCriticalStocks([FromQuery] int threshold = 5)
    {
        var depotStocks =
            from dp in _context.DepotProducts
            group dp by dp.ProductId into g
            select new
            {
                ProductId = g.Key,
                Quantity = g.Sum(x => x.Quantity)
            };

        var storeStocks =
            from sp in _context.StoreProduct
            group sp by sp.ProductId into g
            select new
            {
                ProductId = g.Key,
                Quantity = g.Sum(x => x.Quantity)
            };

        var merged =
            from p in _context.Products
            join ds in depotStocks on p.Id equals ds.ProductId into dsg
            from ds in dsg.DefaultIfEmpty()
            join ss in storeStocks on p.Id equals ss.ProductId into ssg
            from ss in ssg.DefaultIfEmpty()
            let total =
                (ds != null ? ds.Quantity : 0) +
                (ss != null ? ss.Quantity : 0)
            where total < threshold
            select new
            {
                productId = p.Id,
                productName = p.Name,
                productCode = p.Code,
                totalQuantity = total
            };

        var list = await merged
            .OrderBy(x => x.totalQuantity)
            .ToListAsync();

        return Ok(new
        {
            count = list.Count,
            items = list
        });
    }

    [HttpGet("product-demand")]
    public async Task<IActionResult> GetProductDemand([FromQuery] int days = 7)
    {
        var fromDate = DateTime.UtcNow.Date.AddDays(-days);

        // En çok talep edilenler
        var topProducts = await _context.StoreRequests
            .Where(r => r.CreatedAt >= fromDate)
            .GroupBy(r => r.ProductId)
            .Select(g => new
            {
                ProductId = g.Key,
                RequestCount = g.Count()
            })
            .OrderByDescending(x => x.RequestCount)
            .Take(5)
            .Join(
                _context.Products,
                g => g.ProductId,
                p => p.Id,
                (g, p) => new
                {
                    productId = p.Id,
                    productName = p.Name,
                    productCode = p.Code,
                    requestCount = g.RequestCount
                }
            )
            .ToListAsync();

        // Hiç talep almayanlar
        var requestedProductIds = await _context.StoreRequests
            .Select(r => r.ProductId)
            .Distinct()
            .ToListAsync();

        var neverRequested = await _context.Products
            .Where(p => !requestedProductIds.Contains(p.Id))
            .Select(p => new
            {
                productId = p.Id,
                productName = p.Name,
                productCode = p.Code
            })
            .ToListAsync();

        return Ok(new
        {
            topProducts,
            neverRequested
        });
    }

[HttpGet("delivery-metrics")]
public async Task<IActionResult> GetDeliveryMetrics([FromQuery] int delayHours = 24)
{
    var delivered = await _context.StoreRequests
        .Where(r => r.DeliveredAt != null && r.PickedUpAt != null)
        .Select(r => new
        {
            r.Id,
            r.DepotId,
            PickedUpAt = r.PickedUpAt!.Value,
            DeliveredAt = r.DeliveredAt!.Value
        })
        .ToListAsync();

    if (delivered.Count == 0)
    {
        return Ok(new
        {
            averageDeliveryHours = 0,
            fastestDepot = (object?)null,
            slowestDepot = (object?)null,
            delayedCount = 0,
            delayed = Array.Empty<object>()
        });
    }

    // Ortalama teslim süresi
    var averageDeliveryHours = Math.Round(
        delivered.Average(r => (r.DeliveredAt - r.PickedUpAt).TotalHours),
        2
    );

    // Depo bazlı ortalama
    var depotAverages = delivered
        .GroupBy(r => r.DepotId)
        .Select(g => new
        {
            DepotId = g.Key,
            AvgHours = Math.Round(
                g.Average(r => (r.DeliveredAt - r.PickedUpAt).TotalHours),
                2
            )
        })
        .ToList();

    var depotNames = await _context.Depots
        .Where(d => depotAverages.Select(x => x.DepotId).Contains(d.Id))
        .ToDictionaryAsync(d => d.Id, d => d.Name);

    var depotResults = depotAverages
        .Select(x => new
        {
            depotId = x.DepotId,
            depotName = depotNames.GetValueOrDefault(x.DepotId),
            avgHours = x.AvgHours
        })
        .ToList();

    var fastestDepot = depotResults
        .OrderBy(x => x.avgHours)
        .FirstOrDefault();

    var slowestDepot = depotResults
        .OrderByDescending(x => x.avgHours)
        .FirstOrDefault();

    // Geciken teslimatlar
    var delayedDetailed = await _context.StoreRequests
    .Where(r =>
        r.DeliveredAt != null &&
        r.PickedUpAt != null &&
        (r.DeliveredAt.Value - r.PickedUpAt.Value).TotalHours > delayHours
    )
    .Join(
        _context.Stores,
        r => r.StoreId,
        s => s.Id,
        (r, s) => new { r, store = s }
    )
    .Join(
        _context.Depots,
        rs => rs.r.DepotId,
        d => d.Id,
        (rs, d) => new { rs.r, rs.store, depot = d }
    )
    .Join(
        _context.Products,
        rsd => rsd.r.ProductId,
        p => p.Id,
        (rsd, p) => new
        {
            requestId = rsd.r.Id,
            storeName = rsd.store.Name,
            depotName = rsd.depot.Name,
            productName = p.Name,
            requestedQuantity = rsd.r.RequestedQuantity,
            delayHours = Math.Round(
                (rsd.r.DeliveredAt!.Value - rsd.r.PickedUpAt!.Value).TotalHours,
                2
            )
        }
    )
    .ToListAsync();


    return Ok(new
{
    averageDeliveryHours,
    fastestDepot,
    slowestDepot,
    delayedCount = delayedDetailed.Count,
    delayed = delayedDetailed
});

}

}
