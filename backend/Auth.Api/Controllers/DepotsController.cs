using Microsoft.AspNetCore.Mvc;
using Auth.Infrastructure.Logistics.Context;
using Auth.Domain.Entities;
using Auth.Application.DTOs;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DepotsController : ControllerBase
{
    private readonly LogisticsDbContext _context;

    public DepotsController(LogisticsDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public IActionResult GetAll()
    {
        var depots = _context.Depots.ToList();
        return Ok(depots);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDepotRequest req)
    {
        var depot = new Depot
        {
            Id = Guid.NewGuid(),
            Name = req.Name,
            Address = req.Address,
            Capacity = req.Capacity,
            IsActive = req.IsActive
        };

        _context.Depots.Add(depot);
        await _context.SaveChangesAsync();

        return Ok(depot);
    }

    [HttpPut("{id}")]
public async Task<IActionResult> Update(Guid id, [FromBody] UpdateDepotRequest req)
{
    var depot = await _context.Depots.FindAsync(id);
    if (depot == null)
        return NotFound(new { error = "Depot not found" });

    depot.Name = req.Name;
    depot.Address = req.Address;
    depot.Capacity = req.Capacity;
    depot.IsActive = req.IsActive;

    await _context.SaveChangesAsync();
    return Ok(depot);
}


[HttpDelete("{id}")]
public async Task<IActionResult> Delete(Guid id)
{
    var depot = await _context.Depots.FindAsync(id);
    if (depot == null)
        return NotFound(new { message = "Depo bulunamadı." });

    _context.Depots.Remove(depot);
    await _context.SaveChangesAsync();
    return NoContent();
}




}
