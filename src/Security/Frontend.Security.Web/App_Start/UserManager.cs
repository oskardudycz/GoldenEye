using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Security.Web.Base;
using GoldenEye.Shared.Core.DTOs;
using Microsoft.AspNet.Identity;

namespace GoldenEye.Frontend.Security.Web
{
    // Configure the application user manager used in this application. UserManager is defined in ASP.NET Identity and is used by the application.

    public class UserManager : UserManagerBase<User>
    {
        public UserManager(IUserStore<User, int> store)
            : base(store)
        {
        }

        protected override User CreateNewUserFromExternal(UserDTO externalUser)
        {
            return new User
            {
                ExternalUserId = externalUser.Id,
                FirstName = externalUser.FirstName,
                LastName = externalUser.LastName,
                UserName = externalUser.UserName,
                Email = externalUser.Email
            };
        }
    }
}
