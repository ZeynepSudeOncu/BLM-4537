// using Auth.Domain.Entities;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.EntityFrameworkCore.Metadata.Builders;

// namespace Auth.Infrastructure.Logistics.Configurations;

// public class StoreRequestConfiguration : IEntityTypeConfiguration<Auth.Domain.Entities.StoreRequest>
// {
//     public void Configure(EntityTypeBuilder<Auth.Domain.Entities.StoreRequest> builder)
//     {
//         builder.ToTable("StoreRequest");
        
//         builder.HasKey(x => x.Id);
        
//         builder.Property(x => x.StoreId)
//             .IsRequired();
        
//         builder.Property(x => x.DepotId)
//             .IsRequired();
        
//         builder.Property(x => x.ProductId)
//             .IsRequired();
        
//         builder.Property(x => x.RequestedQuantity)
//             .IsRequired();
        
//         builder.Property(x => x.Status)
//             .IsRequired()
//             .HasMaxLength(20)
//             .HasDefaultValue("Pending");
        
//         builder.Property(x => x.CreatedAt)
//             .IsRequired();
        
//         builder.Property(x => x.ApprovedAt)
//             .IsRequired(false);
        
//         builder.Property(x => x.PickedUpAt)
//             .IsRequired(false);
        
//         builder.Property(x => x.DeliveredAt)
//             .IsRequired(false);
        
//         builder.Property(x => x.TruckId)
//             .IsRequired(false);
        
//         // StoreRequest -> Truck ilişkisi (Many-to-One)
//         builder
//             .HasOne(x => x.Truck)
//             .WithMany()
//             .HasForeignKey(x => x.TruckId)
//             .OnDelete(DeleteBehavior.SetNull);
        
//         // Index'ler
//         builder.HasIndex(x => x.StoreId);
//         builder.HasIndex(x => x.DepotId);
//         builder.HasIndex(x => x.ProductId);
//         builder.HasIndex(x => x.TruckId);
//         builder.HasIndex(x => x.Status);
//         builder.HasIndex(x => x.CreatedAt);
//     }
// }