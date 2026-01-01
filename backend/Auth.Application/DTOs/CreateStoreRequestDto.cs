using System;

namespace Auth.Application.DTOs;

public class CreateStoreRequestDto
{
    public Guid ProductId { get; set; }
    public int RequestedQuantity { get; set; }
}
