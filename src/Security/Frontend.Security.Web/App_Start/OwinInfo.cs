using Microsoft.Owin.Security.OAuth;

namespace GoldenEye.Frontend.Security.Web
{
    public static class OwinInfo
    {
        public static string PublicClientId { get; set; }

        public static OAuthAuthorizationServerOptions OAuthOptions { get; set; }
    }
}