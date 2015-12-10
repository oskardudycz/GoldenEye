using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Shared.Core.Services
{
    public interface IAuthorizationService
    {
        bool Authorize(string username, string password);
        UserDTO Find(string username, string password);
    }
}