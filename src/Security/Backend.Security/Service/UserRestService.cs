using GoldenEye.Backend.Core.Service;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Backend.Security.Repositories;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Backend.Security.Service
{
    public class UserRestService : ReadonlyRestServiceBase<UserDTO, User>, IUserRestService
    {
        public UserRestService(IUserRepository repository)
            : base(repository)
        {
        }
    }
}