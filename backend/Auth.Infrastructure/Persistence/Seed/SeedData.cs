using Auth.Domain.Entities;
using Auth.Infrastructure.Security.Password;
using Microsoft.EntityFrameworkCore;
using Auth.Application.Abstractions.Security;

namespace Auth.Infrastructure.Persistence.Seed;

public static class SeedData
{
    public static async Task EnsureSeedAsync(AuthDbContext db, IPasswordHasher hasher, CancellationToken ct = default)
    {
        await db.Database.MigrateAsync(ct);

        if (!await db.Users.AnyAsync(ct))
        {
            var admin = new AppUser
            {
                Email = "admin@local",
                PasswordHash = hasher.Hash("Admin123!"),
                Role = "Admin"
            };

            await db.Users.AddAsync(admin, ct);
            await db.SaveChangesAsync(ct);
        }
    }
}
