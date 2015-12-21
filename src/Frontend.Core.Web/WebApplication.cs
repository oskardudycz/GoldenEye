using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace GoldenEye.Frontend.Core.Web
{
    public abstract class WebApplication : HttpApplication
    {
        protected void Application_Start()
        {
            OnApplicationStart();
        }

        protected void Application_Error()
        {
            OnApplicationError();
        }

        protected virtual void OnApplicationStart()
        {
            OnAreaRegistration();
            OnWebApiConfig();
            OnFilterConfig();
            OnRouteConfig();
            OnBundleConfig();
        }

        private static void OnRouteConfig()
        {
            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }

        private static void OnWebApiConfig()
        {
            GlobalConfiguration.Configure(WebApiConfig.Register);
        }

        private static void OnFilterConfig()
        {
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
        }

        protected virtual void OnAreaRegistration()
        {
            AreaRegistration.RegisterAllAreas();
        }

        protected virtual void OnBundleConfig()
        {
        }

        protected virtual void OnApplicationError()
        {
            var lastException = Server.GetLastError();
            var logger = NLog.LogManager.GetCurrentClassLogger();
            logger.Fatal(lastException);
        }
    }
}
