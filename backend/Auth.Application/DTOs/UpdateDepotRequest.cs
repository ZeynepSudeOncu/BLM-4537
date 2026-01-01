namespace Auth.Application.DTOs
{
    public class UpdateDepotRequest
    {
        public string Name { get; set; } = default!;
        public string Address { get; set; } = default!;
        public int Capacity { get; set; }
        public bool IsActive { get; set; }
    }
}
