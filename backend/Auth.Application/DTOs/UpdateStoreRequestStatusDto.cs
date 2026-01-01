namespace Auth.Application.DTOs.StoreRequest;

public class UpdateStoreRequestStatusDto
{
    public string Status { get; set; } = default!; // Approved / Rejected
}
