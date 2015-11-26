using Shared.Business.DTOs;

namespace Backend.Business.Services
{
    public interface IAuthorizationService
    {
        bool Authorize(string username, string password);
        UserDTO Find(string username, string password);
    }
}