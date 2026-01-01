namespace Auth.Application.Abstractions.Security;

public interface IJwtTokenGenerator
{
    string CreateToken(Guid userId, string email, string role, string? depotId = null, string? storeId = null, string? driverId = null);
}
