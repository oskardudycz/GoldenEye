using System;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Frontend.Security.Web.Providers;
using GoldenEye.Shared.Core.Configuration;
using Microsoft.AspNet.Identity;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OAuth;
using Owin;

namespace GoldenEye.Frontend.Security.Web.Base
{
    public class OwinBoostrapperBase<TUser> 
        where TUser : class, IUser<int>, new()
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

        private static void InitCookieSettings(IAppBuilder app)
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
                        if (!IsAjaxRequest(ctx.Request))
                        {
                            ctx.Response.Redirect(ctx.RedirectUri);
                        }
                    },
                    //OnValidateIdentity = SecurityStampValidator.OnValidateIdentity <TUserManager, TUser, int>(
                    //    validateInterval: TimeSpan.FromMinutes(30),
                    //    regenerateIdentityCallback: (manager, user) =>
                    //        user.GenerateUserIdentityAsync(manager, DefaultAuthenticationTypes.ApplicationCookie),
                    //    getUserIdCallback: (id) => (id.GetUserId<int>()))
                }
            });
            app.UseExternalSignInCookie(DefaultAuthenticationTypes.ExternalCookie);
        }

        private static void IniUserDataProviders(IAppBuilder app)
        {
            // Configure the db context and user manager to use a single instance per request
            app.CreatePerOwinContext(UserDataContextProvider.Create);
            app.CreatePerOwinContext<IUserManager<TUser>>(UserManagerProvider.Create);
        }

        private static void InitAuthentication(IAppBuilder app)
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
                Provider = new ApplicationOAuthProvider(OwinInfo.PublicClientId),
                AuthorizeEndpointPath = new PathString("/api/Account/ExternalLogin"),
                AccessTokenExpireTimeSpan = TimeSpan.FromDays(14)
            };


            if (ConfigHelper.IsInTestMode)
                OwinInfo.OAuthOptions.AllowInsecureHttp = true;
        }

        protected static bool IsAjaxRequest(IOwinRequest request)
        {
            var query = request.Query;
            if ((query != null) && (query["X-Requested-With"] == "XMLHttpRequest"))
            {
                return true;
            }
            var headers = request.Headers;
            return ((headers != null) && (headers["X-Requested-With"] == "XMLHttpRequest"));
        }
    }
}