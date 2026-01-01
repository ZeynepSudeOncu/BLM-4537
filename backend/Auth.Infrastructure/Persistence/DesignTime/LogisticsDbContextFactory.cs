using Auth.Infrastructure.Logistics.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Auth.Infrastructure.Persistence.DesignTime;

public class LogisticsDbContextFactory 
    : IDesignTimeDbContextFactory<LogisticsDbContext>
{
    public LogisticsDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<LogisticsDbContext>();

        optionsBuilder.UseNpgsql(
            "Host=127.0.0.1;Port=5432;Database=logisticsdb;Username=zeynepsudeoncu;Password=123"
        );

        return new LogisticsDbContext(optionsBuilder.Options);
    }
}
