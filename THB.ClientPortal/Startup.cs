using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Frontend.Web.Startup))]
namespace Frontend.Web
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
