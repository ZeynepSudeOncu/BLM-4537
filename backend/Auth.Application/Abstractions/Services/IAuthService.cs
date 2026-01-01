namespace Auth.Application.Abstractions.Services;

public interface IAuthService
{
    Task<(bool ok, string? token, string? error)> RegisterAsync(string email, string password, string role, CancellationToken ct = default);
    Task<(bool ok, string? token, string? error)> LoginAsync(string email, string password, CancellationToken ct = default);
}
