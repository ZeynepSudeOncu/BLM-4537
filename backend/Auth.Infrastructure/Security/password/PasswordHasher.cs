using System.Security.Cryptography;
using System.Text;
using Auth.Application.Abstractions.Security;

namespace Auth.Infrastructure.Security.Password;

public class PasswordHasher : IPasswordHasher
{
    // Format: {iterations}.{saltBase64}.{hashBase64}
    public string Hash(string password)
    {
        const int iterations = 100_000;
        Span<byte> salt = stackalloc byte[16];
        RandomNumberGenerator.Fill(salt);

        var hash = Rfc2898DeriveBytes.Pbkdf2(
            password,
            salt.ToArray(),
            iterations,
            HashAlgorithmName.SHA256,
            32);

        return $"{iterations}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    public bool Verify(string password, string hash)
    {
        var parts = hash.Split('.');
        if (parts.Length != 3) return false;

        var iterations = int.Parse(parts[0]);
        var salt = Convert.FromBase64String(parts[1]);
        var expected = Convert.FromBase64String(parts[2]);

        var actual = Rfc2898DeriveBytes.Pbkdf2(
            password,
            salt,
            iterations,
            HashAlgorithmName.SHA256,
            expected.Length);

        return CryptographicOperations.FixedTimeEquals(actual, expected);
    }
}
