using Auth.Application.Services;
using Auth.Domain.Entities;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.EntityFrameworkCore;

namespace Auth.Infrastructure.Services;

public class OrderService : IOrderService
{
    private readonly LogisticsDbContext _db;

    public OrderService(LogisticsDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<Order>> GetAllOrdersAsync()
    {
        return await _db.Orders.AsNoTracking().ToListAsync();
    }

    public async Task<Order> AddOrderAsync(Order order)
    {
        _db.Orders.Add(order);
        await _db.SaveChangesAsync();
        return order;
    }

    public async Task<Order?> ApproveOrderAsync(Guid id)
    {
        var order = await _db.Orders.FindAsync(id);
        if (order == null) return null;

        order.Status = "Onaylandı";
        await _db.SaveChangesAsync();
        return order;
    }

    public async Task<Order?> RejectOrderAsync(Guid id)
    {
        var order = await _db.Orders.FindAsync(id);
        if (order == null) return null;

        order.Status = "Reddedildi";
        await _db.SaveChangesAsync();
        return order;
    }
}
