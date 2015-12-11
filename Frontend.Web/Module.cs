using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Security.Web;
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