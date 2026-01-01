using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace Auth.Infrastructure.Persistence.DesignTime;

public class AuthDbContextFactory : IDesignTimeDbContextFactory<AuthDbContext>
{
    public AuthDbContext CreateDbContext(string[] args)
    {
        // Çalıştırıldığı dizinden appsettings’i bul
        var config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        var conn = config.GetConnectionString("Default")
                   ?? "Host=127.0.0.1;Port=5432;Database=authdb;Username=zeynepsudeoncu;Password=123";

        var options = new DbContextOptionsBuilder<AuthDbContext>()
            .UseNpgsql(conn)
            .Options;

        return new AuthDbContext(options);
    }
}
