using System.Security.Claims;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.DTOs;
using GoldenEye.Shared.Core.IOC;
using GoldenEye.Shared.Core.Services;
using Microsoft.AspNet.Identity;

namespace GoldenEye.Frontend.Security.Web.Base
{
    // Configure the application user manager used in this application. UserManager is defined in ASP.NET Identity and is used by the application.

    public abstract class UserManagerBase<T> : UserManager<T, int>, IUserManager<T> where T : class, IUser<int>, new()
    {
        protected UserManagerBase(IUserStore<T, int> store)
            : base(store)
        {
        }

        public async Task<ClaimsIdentity> GenerateUserIdentityAsync(T user, string authenticationType)
        {
            // Note the authenticationType must match the one defined in CookieAuthenticationOptions.AuthenticationType
            var userIdentity = await CreateIdentityAsync(user, authenticationType);
            // Add  user claims here
            return userIdentity;
        }

        /// <summary>
        /// Finds existing username with password, if not exists checks if external authorization service 
        /// allows to authorize. If yes, creates new user.
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        public override async Task<T> FindAsync(string userName, string password)
        {
            var user = await base.FindAsync(userName, password);

            if (user != null) return user;

            var externalAuthorizationService = IOCContainer.Get<IAuthorizationService>();

            if (externalAuthorizationService == null
                || !externalAuthorizationService.Authorize(userName, password))
                return null;

            var externalUser = externalAuthorizationService.Find(userName, password);

            user = CreateNewUserFromExternal(externalUser);

            var result = await CreateAsync(user, password);

            if (!result.Succeeded)
                return null;

            return await base.FindAsync(userName, password);
        }

        protected abstract T CreateNewUserFromExternal(UserDTO externalUser);
    }
}
