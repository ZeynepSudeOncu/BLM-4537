using Auth.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Auth.Infrastructure.Logistics.Configurations;

public class DriverConfiguration : IEntityTypeConfiguration<Driver>
{
    public void Configure(EntityTypeBuilder<Driver> builder)
    {
        builder.ToTable("Drivers");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.FullName)
            .IsRequired();

        builder.Property(x => x.Phone)
            .IsRequired();

        builder.Property(x => x.License)
            .IsRequired();

        builder.Property(x => x.Status)
            .IsRequired();

        builder.Property(x => x.TruckId)
            .HasColumnType("uuid")
            .IsRequired(false);

        builder
            .HasOne(x => x.Truck)
            .WithMany()                 // 🔥 DEĞİŞEN SATIR
            .HasForeignKey(x => x.TruckId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(x => x.TruckId)
            .IsUnique(); // 1 kamyon = 1 sürücü
    }
}
