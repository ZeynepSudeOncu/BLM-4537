using Auth.Application.DTOs;

namespace Auth.Application.Services;

public interface ITruckService
{
    Task<List<TruckListResponse>> GetAllTrucksAsync();

    Task<CreateTruckDto> CreateTruckAsync(CreateTruckDto dto);
    Task<bool> UpdateTruckAsync(Guid id, UpdateTruckDto dto);
    Task<bool> DeactivateTruckAsync(Guid id);
}
