namespace Auth.Application.DTOs
{
    public class UpdateDriverRequest
    {
        public string FullName { get; set; } = default!;
        public string Phone { get; set; } = default!;
        public string License { get; set; } = default!;
        public string Status { get; set; } = default!;
    }
}
