using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Shared.Core.Services
{
    public interface IAuthorizationService
    {
        bool Authorize(string username, string password);
        UserDTO Find(string username, string password);
    }
}