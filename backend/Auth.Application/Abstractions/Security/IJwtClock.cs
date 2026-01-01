namespace Auth.Application.Abstractions.Security;

public interface IJwtClock
{
    DateTime UtcNow { get; }
}
