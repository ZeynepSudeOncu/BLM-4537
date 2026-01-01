namespace Auth.Application.DTOs;

public class CreateTruckDto
{
    public string Plate { get; set; } = null!;
    public string Model { get; set; } = null!;
    public int Capacity { get; set; }
}
