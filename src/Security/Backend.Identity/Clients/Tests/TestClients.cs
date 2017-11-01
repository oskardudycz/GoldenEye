using System.Collections.Generic;
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
                        new Secret("P@ssw0rd".Sha256())},
                    AllowedScopes = new List<string> {"customAPI.read"}
                }
            };
        }
    }
}