namespace Auth.Domain.Entities;

public class AppUser
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Email { get; set; } = default!;
    public string PasswordHash { get; set; } = default!;
    public string Role { get; set; } = "User";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // tanımlı oldukları mağaza ve depo ayarlayabilmekn için
    // Dikkat !! bence bu şekilde veri tabanı oluşturulmamalı. 
    public string? DepotId { get; set; } 
    public string? StoreId { get; set; }  



}
