namespace Auth.Infrastructure.Common;

public static class ResultExtensions
{
    public static (bool ok, string? token, string? error) Fail(string error) => (false, null, error);
    public static (bool ok, string? token, string? error) Ok(string token) => (true, token, null);
}
