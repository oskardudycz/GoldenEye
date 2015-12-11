using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Repository;
using GoldenEye.Backend.Core.Service;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Backend.Business.Services
{
    public class UserRestService : ReadonlyRestServiceBase<UserDTO, UserEntity>, IUserRestService
    {
        public UserRestService(IUserRepository repository)
            : base(repository)
        {
        }
    }
}