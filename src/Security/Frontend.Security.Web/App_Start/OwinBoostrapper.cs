using System;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Managers;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Security.Web.Extensions;
using GoldenEye.Frontend.Security.Web.Providers;
using GoldenEye.Shared.Core.Configuration;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OAuth;
using Owin;

namespace GoldenEye.Frontend.Security.Web
{
    public class OwinBoostrapper : OwinBoostrapperBase<User>
    {
    }

    public class OwinBoostrapperBase<TUser>
        where TUser : IdentityUser<int, UserLogin, UserRole, UserClaim>, Backend.Security.Model.IUser<int>, new()
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }

        // For more information on configuring authentication, please visit http://go.microsoft.com/fwlink/?LinkId=301864
        public virtual void ConfigureAuth(IAppBuilder app)
        {
            IniUserDataProviders(app);

            InitCookieSettings(app);

            // Configure the application for OAuth based flow
            OwinInfo.PublicClientId = "self";
            InitOAuthOptions();


            InitAuthentication(app);
        }

        protected virtual void InitCookieSettings(IAppBuilder app)
        {
            // Enable the application to use a cookie to store information for the signed in user
            // and to use a cookie to temporarily store information about a user logging in with a third party login provider
            app.UseCookieAuthentication(new CookieAuthenticationOptions
            {
                AuthenticationType = DefaultAuthenticationTypes.ApplicationCookie,
                LoginPath = new PathString("/Home/Login"),
                Provider = new CookieAuthenticationProvider
                {
                    OnApplyRedirect = ctx =>
                    {
                        if (!OwinRequestExtensions.IsAjaxRequest(ctx.Request))
                        {
                            ctx.Response.Redirect(ctx.RedirectUri);
                        }
                    },
                    OnValidateIdentity = SecurityStampValidator.OnValidateIdentity<Backend.Security.Managers.UserManager<TUser>, TUser, int>(
                        validateInterval: TimeSpan.FromMinutes(30),
                        regenerateIdentityCallback: (manager, user) =>
                            manager.GenerateUserIdentityAsync(user, DefaultAuthenticationTypes.ApplicationCookie),
                        getUserIdCallback: id => (id.GetUserId<int>()))
                }
            });
            app.UseExternalSignInCookie(DefaultAuthenticationTypes.ExternalCookie);
        }

        protected virtual void IniUserDataProviders(IAppBuilder app)
        {
            // Configure the db context and user manager to use a single instance per request
            app.CreatePerOwinContext(UserDataContextProvider.Create);
            app.CreatePerOwinContext(UserDataContextProvider.Create);
            app.CreatePerOwinContext<IUserManager<TUser>>(CreateUserManager);
        }

        protected virtual void InitAuthentication(IAppBuilder app)
        {
            // Enable the application to use bearer tokens to authenticate users

            app.UseOAuthBearerTokens(OwinInfo.OAuthOptions);

            // Uncomment the following lines to enable logging in with third party login providers
            //app.UseMicrosoftAccountAuthentication(
            //    clientId: "",
            //    clientSecret: "");

            //app.UseTwitterAuthentication(
            //    consumerKey: "",
            //    consumerSecret: "");

            //app.UseFacebookAuthentication(
            //    appId: "",
            //    appSecret: "");

            //app.UseGoogleAuthentication(new GoogleOAuth2AuthenticationOptions()
            //{
            //    ClientId = "",
            //    ClientSecret = ""
            //});
        }

        protected virtual void InitOAuthOptions()
        {
            OwinInfo.OAuthOptions = new OAuthAuthorizationServerOptions
            {
                TokenEndpointPath = new PathString("/Token"),
                Provider = new ApplicationOAuthProvider<TUser>(OwinInfo.PublicClientId),
                AuthorizeEndpointPath = new PathString("/api/Account/ExternalLogin"),
                AccessTokenExpireTimeSpan = TimeSpan.FromDays(14)
            };


            if (ConfigHelper.IsInTestMode)
                OwinInfo.OAuthOptions.AllowInsecureHttp = true;
        }

        protected virtual IUserManager<TUser> CreateUserManager(IdentityFactoryOptions<IUserManager<TUser>> options, IOwinContext context)
        {
            var manager = new Backend.Security.Managers.UserManager<TUser>(
                new Backend.Security.Stores.UserStore<TUser>(context.Get<IUserDataContext<TUser>>()));
            // Configure validation logic for usernames
            manager.UserValidator = new UserValidator<TUser, int>(manager)
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
                manager.UserTokenProvider = new DataProtectorTokenProvider<TUser, int>(dataProtectionProvider.Create("ASP.NET Identity"));
            }
            return manager;
        }
    }
}