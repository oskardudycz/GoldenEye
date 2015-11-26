using System.Web;
using System.Web.Http;
using System.Web.Http.ExceptionHandling;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Frontend.Web.App_Start;
using NLog;

namespace Frontend.Web
{
    public class MvcApplication : HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            AutoMapperConfig.RegisterMappings();
        }
        protected void Application_Error()
        {
            // missing reference?
            // Exception lastException = Server.GetLastError();
            // NLog.Logger logger = NLog.LogManager.GetCurrentClassLogger();
            // logger.Fatal(lastException);
        }
    }
}
