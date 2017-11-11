using GoldenEye.Frontend.Security.Web;
using GoldenEye.Shared.Core.IOC.Ninject.Modules;
using GoldenEye.Shared.Core.Modules.Attributes;
using Microsoft.Owin;

[assembly: ProjectAssembly]
[assembly: OwinStartup(typeof(OwinBoostrapper))]
namespace GoldenEye.Frontend.Web
{
    public class Module : ModuleBase
    {
        public override void Load()
        {
        }
    }
}