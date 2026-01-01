using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Auth.Application.Abstractions.Security;
using Auth.Application.Options;
using Microsoft.IdentityModel.Tokens;

namespace Auth.Infrastructure.Security.Jwt;

public class JwtTokenGenerator(JwtOptions options, IJwtClock clock) : IJwtTokenGenerator
{
    
    public string CreateToken(
    Guid userId,
    string email,
    string role,
    string? depotId = null,
    string? storeId = null,
    string? driverId = null
)
{
    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(options.Key));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

    var claims = new List<Claim>
    {
        new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
        new Claim(JwtRegisteredClaimNames.Email, email),
        new Claim(ClaimTypes.Name, email),
        new Claim(ClaimTypes.Role, role),
        new Claim(JwtRegisteredClaimNames.Iat, Epoch(clock.UtcNow), ClaimValueTypes.Integer64)
    };

    if (!string.IsNullOrEmpty(depotId))
        claims.Add(new Claim("DepotId", depotId));

    if (!string.IsNullOrEmpty(storeId))
        claims.Add(new Claim("StoreId", storeId));
        
    if (!string.IsNullOrEmpty(driverId))
            claims.Add(new Claim("DriverId", driverId));


    var token = new JwtSecurityToken(
        issuer: options.Issuer,
        audience: options.Audience,
        claims: claims,
        notBefore: clock.UtcNow,
        expires: clock.UtcNow.AddMinutes(options.ExpiresMinutes),
        signingCredentials: creds
    );

    return new JwtSecurityTokenHandler().WriteToken(token);
}


    private static string Epoch(DateTime dt) =>
        ((long)(dt - DateTime.UnixEpoch).TotalSeconds).ToString();
}
