namespace Auth.Application.DTOs
{
    public class CreateDriverRequest
    {
        public string FullName { get; set; } = default!;
        public string License { get; set; } = default!;
        public string Phone { get; set; } = default!;
        public string Status { get; set; } = default!;
        public Guid? TruckId { get; set; }
    }
}