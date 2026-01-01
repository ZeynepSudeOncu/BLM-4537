using Auth.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Auth.Application.Services;

public interface IOrderService
{
    Task<IReadOnlyList<Order>> GetAllOrdersAsync();
    Task<Order> AddOrderAsync(Order order);
    Task<Order?> ApproveOrderAsync(Guid id);
    Task<Order?> RejectOrderAsync(Guid id);
}
