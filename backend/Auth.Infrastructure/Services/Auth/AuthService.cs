using Auth.Application.Abstractions.Repositories;
using Auth.Application.Abstractions.Security;
using Auth.Application.Abstractions.Services;
using Auth.Domain.Entities;

namespace Auth.Infrastructure.Services.Auth;

public class AuthService(
    IUserRepository users,
    IDriverRepository drivers,
    IPasswordHasher hasher,
    IJwtTokenGenerator jwt,
    IUnitOfWork uow) : IAuthService
{
    // =====================================================
    // REGISTER
    // =====================================================
    public async Task<(bool ok, string? token, string? error)> RegisterAsync(
        string email,
        string password,
        string role,
        CancellationToken ct = default)
    {
        var existing = await users.GetByEmailAsync(email, ct);
        if (existing is not null)
            return (false, null, "Email already exists.");

        var user = new AppUser
        {
            Email = email,
            PasswordHash = hasher.Hash(password),
            Role = role
        };

        await users.AddAsync(user, ct);
        await uow.SaveChangesAsync(ct);

        // Register sırasında driverId yok (normal)
        var token = jwt.CreateToken(
            user.Id,
            user.Email,
            user.Role,
            user.DepotId,
            user.StoreId,
            null
        );

        return (true, token, null);
    }

    // =====================================================
    // LOGIN
    // =====================================================
    public async Task<(bool ok, string? token, string? error)> LoginAsync(
        string email,
        string password,
        CancellationToken ct = default)
    {
        var user = await users.GetByEmailAsync(email, ct);
        if (user is null)
            return (false, null, "Invalid credentials.");

        if (!hasher.Verify(password, user.PasswordHash))
            return (false, null, "Invalid credentials.");

        string? driverId = null;

        // 🔥 Driver ise DriverId'yi bul
        if (user.Role == "Driver")
        {
            var driver = await drivers.GetByUserIdAsync(user.Id, ct);
            driverId = driver?.Id.ToString();
        }

        var token = jwt.CreateToken(
            user.Id,
            user.Email,
            user.Role,
            user.DepotId,
            user.StoreId,
            driverId   // 🔥 KRİTİK SATIR
        );

        return (true, token, null);
    }
}
