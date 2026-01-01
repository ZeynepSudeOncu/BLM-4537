namespace Auth.Domain.Entities;

public class Driver
{
    public Guid Id { get; set; }

    // 🔑 Auth bağlantısı
    public Guid UserId { get; set; }        // 🔥 EKLENDİ
    public AppUser User { get; set; } = null!;

    public string FullName { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string License { get; set; } = null!;
    public string Status { get; set; } = null!;

    public Guid? TruckId { get; set; }
    public Truck? Truck { get; set; }
}

