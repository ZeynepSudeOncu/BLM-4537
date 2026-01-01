using Auth.Infrastructure.Logistics.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/products")]
[Authorize] // Store/Depot/Admin hepsi görebilsin
public class ProductsController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public ProductsController(LogisticsDbContext context)
    {
        _context = context;
    }

    // GET: api/products
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var list = await _context.Products
            .AsNoTracking()
            .Select(p => new
            {
                id = p.Id,
                name = p.Name,
                code = p.Code
            })
            .OrderBy(x => x.code)
            .ToListAsync();

        return Ok(list);
    }
}
