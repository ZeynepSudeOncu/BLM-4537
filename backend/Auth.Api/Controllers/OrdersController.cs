using Microsoft.AspNetCore.Mvc;
using Auth.Application.Services;
using Auth.Domain.Entities;

namespace Auth.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    public OrdersController(IOrderService orderService)
    {
        _orderService = orderService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var orders = await _orderService.GetAllOrdersAsync();
        return Ok(orders);
    }

    [HttpPost]
    public async Task<IActionResult> Add([FromBody] Order order)
    {
        var created = await _orderService.AddOrderAsync(order);
        return Ok(created);
    }

    [HttpPut("{id}/approve")]
    public async Task<IActionResult> Approve(Guid id)
    {
        var result = await _orderService.ApproveOrderAsync(id);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpPut("{id}/reject")]
    public async Task<IActionResult> Reject(Guid id)
    {
        var result = await _orderService.RejectOrderAsync(id);
        return result is null ? NotFound() : Ok(result);
    }
}
