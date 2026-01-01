using Auth.Domain.Entities;

namespace Auth.Application.Abstractions.Repositories;

public interface IUserRepository
{
    Task<AppUser?> GetByEmailAsync(string email, CancellationToken ct = default);
    Task<AppUser?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task AddAsync(AppUser user, CancellationToken ct = default);
    void Update(AppUser user);
    void Remove(AppUser user);
}
