using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Backend.Security.Stores;
using GoldenEye.Frontend.Security.Web.Base;
using GoldenEye.Shared.Core.DTOs;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;

namespace GoldenEye.Frontend.Security.Web
{
    // Configure the application user manager used in this application. UserManager is defined in ASP.NET Identity and is used by the application.

    public class UserManager : UserManagerBase<User>
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
