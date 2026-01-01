using Auth.Application.Abstractions.Security;

namespace Auth.Infrastructure.Security.Jwt;

public class JwtClock : IJwtClock
{
    public DateTime UtcNow => DateTime.UtcNow;
}
