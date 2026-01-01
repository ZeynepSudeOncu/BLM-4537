using Auth.Application.Services;
using Auth.Application.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TrucksController : ControllerBase
{
    private readonly ITruckService _truckService;

    public TrucksController(ITruckService truckService)
    {
        _truckService = truckService;
    }

    // ✅ Artık isAssigned bilgisi de gelir
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var trucks = await _truckService.GetAllTrucksAsync();
        return Ok(trucks);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateTruckDto dto)
    {
        var created = await _truckService.CreateTruckAsync(dto);
        return Ok(created);
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var result = await _truckService.DeactivateTruckAsync(id);

        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTruckDto dto)
    {
        var updated = await _truckService.UpdateTruckAsync(id, dto);

        if (!updated)
            return NotFound();

        return NoContent();
    }
}
