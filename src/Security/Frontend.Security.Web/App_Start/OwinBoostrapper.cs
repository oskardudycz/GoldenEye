using System;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Security.Web.Base;
using GoldenEye.Frontend.Security.Web.Providers;
using GoldenEye.Shared.Core.Configuration;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Owin;

namespace GoldenEye.Frontend.Security.Web
{
    public class OwinBoostrapper : OwinBoostrapperBase<User>
    {
    }
}