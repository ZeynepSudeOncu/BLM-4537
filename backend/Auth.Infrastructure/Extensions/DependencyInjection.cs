using Auth.Infrastructure.Persistence;
using Auth.Infrastructure.Repositories;
using Auth.Infrastructure.Security.Jwt;
using Auth.Infrastructure.Security.Password;
using Auth.Infrastructure.Services.Auth;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Auth.Application.Abstractions.Repositories;
using Auth.Application.Abstractions.Security;
using Auth.Application.Abstractions.Services;
using Auth.Application.Options;

namespace Auth.Infrastructure.Extensions;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration config)
    {
        services.AddDbContext<AuthDbContext>(opt =>
            opt.UseNpgsql(config.GetConnectionString("Default")));

        // Options (Jwt)
        var jwt = new JwtOptions();
        config.GetSection("Jwt").Bind(jwt);
        services.AddSingleton(jwt);

        // Repositories & UoW
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Security
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
        services.AddSingleton<IJwtClock, JwtClock>();

        // Services
        services.AddScoped<IAuthService, AuthService>();

        return services;
    }
}
