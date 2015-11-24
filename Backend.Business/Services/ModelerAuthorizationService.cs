using System.Linq;
using Backend.Business.Context;
using Shared.Core.Utils;

namespace Backend.Business.Services
{
    public class ModelerAuthorizationService
    {
        public bool Authorize(string email, string password)
        {
            var encodedPassword = StringEncoder.Encrypt(password);

            using (var db = new THBContext())
            {
                return db.ModelerUsers
                    .Any(el => el.Email == email && el.Password == encodedPassword && el.IsActive && !el.IsDeleted && el.IsValid);
            }
        }
    }
}