using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.ExceptionHandling;
using System.Web.Http.Tracing;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace GoldenEye.Frontend.Core.Web
{
    public abstract class WebApplication : HttpApplication, IExceptionLogger
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
            GlobalConfiguration.Configure(OnWebApiConfig);
            OnFilterConfig();
            OnRouteConfig();
            OnBundleConfig();
        }

        protected virtual void OnRouteConfig()
        {
            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }

        protected virtual void OnWebApiConfig(HttpConfiguration config)
        {
            WebApiConfig.Register(config);
            config.Services.Add(typeof(IExceptionLogger), this);
        }

        protected static void OnFilterConfig()
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
            OnUnandledExceptionCaught(lastException);
        }

        protected virtual void OnUnandledExceptionCaught(Exception exception)
        {
            var logger = NLog.LogManager.GetCurrentClassLogger();
            logger.Fatal(exception);
        }

        public Task LogAsync(ExceptionLoggerContext context, CancellationToken cancellationToken)
        {
            return Task.Run(()=>OnUnandledExceptionCaught(context.Exception), cancellationToken);
        }
    }
}
