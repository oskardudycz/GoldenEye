using System.Linq;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Repository;
using GoldenEye.Backend.Core.Service;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Backend.Business.Services
{
    public class ModelerUserRestService : ReadonlyRestServiceBase<UserDTO, ModelerUserEntity>, IModelerUserRestService
    {
        public ModelerUserRestService(IModelerUserRepository repository)
            : base(repository)
        {
        }

        public bool Authorize(string username, string password)
        {
            return ((IModelerUserRepository)Repository).Authorize(username, password);
        }

        public UserDTO Find(string username, string password)
        {
            var user = ((IModelerUserRepository)Repository).Find(username, password);

            return user != null ? Mapper.Map<UserDTO>(user) : null;
        }

        public IQueryable<UserDTO> GetActive()
        {
            return ((IModelerUserRepository) Repository).GetActive().ProjectTo<UserDTO>();
        }
    }
}