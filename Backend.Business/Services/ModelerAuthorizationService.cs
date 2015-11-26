using AutoMapper;
using Backend.Business.Repository;
using Shared.Business.DTOs;

namespace Backend.Business.Services
{
    public class ModelerAuthorizationService : IAuthorizationService
    {
        private readonly IModelerUserRepository _modelerUserRepository;

        public ModelerAuthorizationService(IModelerUserRepository modelerUserRepository)
        {
            _modelerUserRepository = modelerUserRepository;
        }

        public bool Authorize(string username, string password)
        {
            return _modelerUserRepository.Authorize(username, password);
        }


        public UserDTO Find(string username, string password)
        {
            var user = _modelerUserRepository.Find(username, password);

            return user != null ? Mapper.Map<UserDTO>(user) : null;
        }
    }
}