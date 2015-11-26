using System.Linq;
using AutoMapper;
using Backend.Business.Context;
using Shared.Business.DTOs;
using Shared.Core.Utils;

namespace Backend.Business.Services
{
    public class ModelerAuthorizationService : IAuthorizationService
    {
        public bool Authorize(string username, string password)
        {
            var encodedPassword = StringEncoder.Encrypt(password);

            using (var db = new THBContext())
            {
                return db.ModelerUsers
                    .Any(
                        el =>
                            el.UserName == username
                            && el.Password == encodedPassword
                            && el.IsActive && !el.IsDeleted && el.IsValid);
            }
        }


        public UserDTO Find(string username, string password)
        {
            var encodedPassword = StringEncoder.Encrypt(password);

            using (var db = new THBContext())
            {
                var user = db.ModelerUsers.OrderByDescending(el => el.ModificationDate)
                    .FirstOrDefault(
                        el =>
                            el.UserName == username
                            && el.Password == encodedPassword
                            && el.IsActive && !el.IsDeleted && el.IsValid);

                return Mapper.Map<UserDTO>(user);
            }
        }
    }
}