using Auth.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Auth.Infrastructure.Persistence.Configurations;

public class AppUserConfiguration : IEntityTypeConfiguration<AppUser>
{
    public void Configure(EntityTypeBuilder<AppUser> b)
    {
        b.HasKey(x => x.Id);
        b.HasIndex(x => x.Email).IsUnique();
        b.Property(x => x.Email).IsRequired().HasMaxLength(255);
        b.Property(x => x.PasswordHash).IsRequired().HasMaxLength(255);
        b.Property(x => x.Role).IsRequired().HasMaxLength(64);
        b.Property(x => x.CreatedAt).HasDefaultValueSql("NOW()");
        b.ToTable("users");
    }
}
