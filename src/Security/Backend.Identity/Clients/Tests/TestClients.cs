using System.Collections.Generic;
using IdentityServer4;
using IdentityServer4.Models;

namespace GoldenEye.Backend.Identity.Clients.Tests
{
    public class TestClients
    {
        public static IEnumerable<Client> Get()
        {
            return new List<Client> {
                new Client {
                    ClientId = "oauthClient",
                    ClientName = "Test GoldenEye Client",
                    AllowedGrantTypes = GrantTypes.ClientCredentials,
                    ClientSecrets = new List<Secret> {
                        new Secret("secret".Sha256())},
                    AllowedScopes = new List<string> { "goldenEyeAPI.read" }
                },
                new Client
                {
                    ClientId = "openIdConnectClient",
                    ClientName = "Example Implicit Client Application",
                    AllowedGrantTypes = GrantTypes.Implicit,
                    AllowedScopes = new List<string>
                    {
                        IdentityServerConstants.StandardScopes.OpenId,
                        IdentityServerConstants.StandardScopes.Profile,
                        IdentityServerConstants.StandardScopes.Email,
                        "role",
                        "goldenEyeAPI.write"
                    },
                    RedirectUris = new List<string> {"https://localhost:4430/signin-oidc"},
                    PostLogoutRedirectUris = new List<string> {"https://localhost:4430"}
                }
            };
        }
    }
}