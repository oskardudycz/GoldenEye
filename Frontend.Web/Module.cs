using GoldenEye.Security.Core;
using GoldenEye.Security.Core.DataContext;
using GoldenEye.Security.Core.Model;
using GoldenEye.Shared.Core.Modules;
using GoldenEye.Shared.Core.Modules.Attributes;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.Owin;

[assembly: ProjectAssembly]
[assembly: OwinStartup(typeof(OwinBoostrapper))]
namespace GoldenEye.Frontend.Web
{
    public class Module : ModuleBase
    {
        public override void Load()
        {
            Kernel.Bind<IdentityDbContext<User>>().To<UserDataContext>();
        }
    }
}