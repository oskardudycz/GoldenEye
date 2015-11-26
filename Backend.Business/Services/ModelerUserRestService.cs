using Shared.Business.DTOs;
using Backend.Business.Entities;
using Backend.Core.Service;
using Backend.Business.Repository;

namespace Backend.Business.Services
{
    public class ModelerUserRestService : ReadonlyRestServiceBase<UserDTO, ModelerUserEntity>, IModelerUserRestService
    {
        public ModelerUserRestService(IModelerUserRepository repository)
            : base(repository)
        {
        }
    }
}