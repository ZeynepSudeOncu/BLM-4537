using Auth.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Auth.Infrastructure.Persistence.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> b)
    {
        b.HasKey(x => x.Id);
        b.HasIndex(x => x.Token).IsUnique();
        b.Property(x => x.Token).IsRequired().HasMaxLength(512);
        b.Property(x => x.ExpiresAt).IsRequired();
        b.Property(x => x.CreatedAt).HasDefaultValueSql("NOW()");
        b.HasOne<AppUser>()
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
        b.ToTable("refresh_tokens");
    }
}
