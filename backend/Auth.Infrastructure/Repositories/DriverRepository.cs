using Auth.Application.Abstractions.Repositories;
using Auth.Domain.Entities;
using Auth.Infrastructure.Logistics.Context;
using Microsoft.EntityFrameworkCore;

namespace Auth.Infrastructure.Repositories;

public class DriverRepository : IDriverRepository
{
    private readonly LogisticsDbContext _context;

    public DriverRepository(LogisticsDbContext context)
    {
        _context = context;
    }

    public Task<Driver?> GetByUserIdAsync(Guid userId, CancellationToken ct)
    {
        return _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
    }
}
