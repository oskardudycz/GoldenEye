using System.Threading.Tasks;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Backend.Security.Stores;
using GoldenEye.Shared.Core.IOC;
using GoldenEye.Shared.Core.Services;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;

namespace GoldenEye.Frontend.Security.Web
{
    // Configure the application user manager used in this application. UserManager is defined in ASP.NET Identity and is used by the application.

    public class UserManager : UserManager<User, int>
    {
        public UserManager(IUserStore<User, int> store)
            : base(store)
        {
        }

        public static UserManager Create(IdentityFactoryOptions<UserManager> options, IOwinContext context)
        {
            var manager = new UserManager(new UserStore(context.Get<UserDataContext>()));
            // Configure validation logic for usernames
            manager.UserValidator = new UserValidator<User, int>(manager)
            {
                AllowOnlyAlphanumericUserNames = false,
                RequireUniqueEmail = true
            };
            // Configure validation logic for passwords
            manager.PasswordValidator = new PasswordValidator
            {
                RequiredLength = 6,
                //RequireNonLetterOrDigit = true,
                RequireDigit = true,
                RequireLowercase = true,
                RequireUppercase = true,
            };
            var dataProtectionProvider = options.DataProtectionProvider;
            if (dataProtectionProvider != null)
            {
                manager.UserTokenProvider = new DataProtectorTokenProvider<User, int>(dataProtectionProvider.Create("ASP.NET Identity"));
            }
            return manager;
        }

        /// <summary>
        /// Finds existing username with password, if not exists checks if external authorization service 
        /// allows to authorize. If yes, creates new user.
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        public override async Task<User> FindAsync(string userName, string password)
        {
            var user = await base.FindAsync(userName, password);

            if (user != null) return user;

            var externalAuthorizationService = IOCContainer.Get<IAuthorizationService>();

            if (externalAuthorizationService == null
                || !externalAuthorizationService.Authorize(userName, password))
                return null;

            var externalUser = externalAuthorizationService.Find(userName, password);

            user = new User
            {
                ExternalUserId = externalUser.Id,
                FirstName = externalUser.FirstName,
                LastName = externalUser.LastName,
                UserName = externalUser.UserName,
                Email = externalUser.Email
            };

            var result = await CreateAsync(user, password);

            if (!result.Succeeded)
                return null;

            return await base.FindAsync(userName, password);
        }
    }
}
