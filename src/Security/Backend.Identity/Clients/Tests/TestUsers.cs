using System;
using System.Collections.Generic;
using System.Security.Claims;
using IdentityModel;
using IdentityServer4.Test;

namespace GoldenEye.Backend.Identity.Clients.Tests
{
    public class TestUsers
    {
        public static List<TestUser> Get()
        {
            return new List<TestUser> {
            new TestUser {
                SubjectId = "5BE86359-073C-434B-AD2D-A3932222DABE",
                Username = "admin",
                Password = "P@ssw0rd",
                Claims = new List<Claim> {
                    new Claim(JwtClaimTypes.Email, "admin@goldeneye.com"),
                    new Claim(JwtClaimTypes.Role, "admin")
                }
            }
        };
        }
    }
}