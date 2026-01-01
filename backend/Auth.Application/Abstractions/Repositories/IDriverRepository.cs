using Auth.Domain.Entities;
public interface IDriverRepository
{
    Task<Driver?> GetByUserIdAsync(Guid userId, CancellationToken ct);
}
