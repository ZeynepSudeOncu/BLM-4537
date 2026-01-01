using Auth.Application.Abstractions.Repositories;
using Auth.Domain.Entities;
using Auth.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Auth.Infrastructure.Repositories;

public class UserRepository(AuthDbContext db) : IUserRepository
{
    public Task<AppUser?> GetByEmailAsync(string email, CancellationToken ct = default) =>
        db.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Email == email, ct);

    public Task<AppUser?> GetByIdAsync(Guid id, CancellationToken ct = default) =>
        db.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);

    public async Task AddAsync(AppUser user, CancellationToken ct = default)
    {
        await db.Users.AddAsync(user, ct);
    }

    public void Update(AppUser user) => db.Users.Update(user);

    public void Remove(AppUser user) => db.Users.Remove(user);
}
