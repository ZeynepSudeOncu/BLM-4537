namespace Auth.Domain.Entities;

public class Truck
{
    public Guid Id { get; set; }

    public string Plate { get; set; } = null!;
    public string Model { get; set; } = null!;
    public int Capacity { get; set; }

    public bool IsActive { get; set; } = true;

}

