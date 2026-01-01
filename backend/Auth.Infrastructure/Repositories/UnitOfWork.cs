using Auth.Application.Abstractions.Repositories;
using Auth.Infrastructure.Persistence;

namespace Auth.Infrastructure.Repositories;

public class UnitOfWork(AuthDbContext db) : IUnitOfWork
{
    public Task<int> SaveChangesAsync(CancellationToken ct = default) => db.SaveChangesAsync(ct);
}
