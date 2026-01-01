namespace Auth.Application.DTOs
{
    public class DriverListResponse
    {
        public Guid Id { get; set; }
        public string FullName { get; set; } = null!;
        public string Phone { get; set; } = null!;
        public string License { get; set; } = null!;
        public string Status { get; set; } = null!;
        public Guid? TruckId { get; set; }
        public string? TruckPlate { get; set; }
    }
}
