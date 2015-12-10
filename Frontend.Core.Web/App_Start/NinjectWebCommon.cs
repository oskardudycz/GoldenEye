using WebActivatorEx;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Http.WebHost;
using Microsoft.Web.Infrastructure.DynamicModuleHelper;
using Ninject.Injection;
using Ninject.Modules;
using Ninject.Web.Common;
using Ninject;
using Ninject.Syntax;
using Ninject.Activation;
using Ninject.Parameters;
using Backend.Business.Services;
using Frontend.Web.IoC;
using Backend.Core.Service;
using Shared.Business.DTOs;
using Frontend.Web.Core.Security;
using Shared.Core.Security;

[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(Frontend.Web.App_Start.NinjectWebCommon), "Start")]
[assembly: WebActivatorEx.ApplicationShutdownMethodAttribute(typeof(Frontend.Web.App_Start.NinjectWebCommon), "Stop")]

namespace Frontend.Web.App_Start
{
    public static class NinjectWebCommon
    {
        private static readonly Bootstrapper bootstrapper = new Bootstrapper();

        public static IKernel Kernel;

        /// <summary>
        /// Starts the application
        /// </summary>
        public static void Start()
        {
            DynamicModuleUtility.RegisterModule(typeof(OnePerRequestHttpModule));
            DynamicModuleUtility.RegisterModule(typeof(NinjectHttpModule));
            bootstrapper.Initialize(CreateKernel);
        }

        /// <summary>
        /// Stops the application.
        /// </summary>
        public static void Stop()
        {
            bootstrapper.ShutDown();
            Kernel = null;
        }

        /// <summary>
        /// Creates the kernel that will manage your application.
        /// </summary>
        /// <returns>The created kernel.</returns>
        private static IKernel CreateKernel()
        {
            var kernel = new StandardKernel();
            kernel.Bind<Func<IKernel>>().ToMethod(ctx => () => new Bootstrapper().Kernel);
            kernel.Bind<IHttpModule>().To<HttpApplicationInitializationHttpModule>();

            RegisterServices(kernel);

            GlobalConfiguration.Configuration.DependencyResolver = new NinjectResolver(kernel);
            Kernel = kernel;
            return kernel;
        }

        /// <summary>
        /// Load your modules or register your services here!
        /// </summary>
        /// <param name="kernel">The kernel.</param>
        private static void RegisterServices(IKernel kernel)
        {
            //kernel.Bind<ITaskRepository>().To<TaskRepository>();
            //kernel.Bind<ITaskRestService>().To<TaskRestService>();
            //kernel.Bind<ITaskTypeRepository>().To<TaskTypeRepository>();
            //kernel.Bind<ITaskTypeRestService>().To<TaskTypeRestService>();
            //kernel.Bind<ICustomerRepository>().To<CustomerRepository>();
            //kernel.Bind<IModelerUserRepository>().To<ModelerUserRepository>();
            //kernel.Bind<ICustomerRestService>().To<CustomerRestService>();
            //kernel.Bind<IModelerUserRestService>().To<ModelerUserRestService>();
            //kernel.Bind<IAuthorizationService>().To<ModelerUserRestService>();
            //kernel.Bind<ITHBContext>().To<THBContext>();
            //kernel.Bind<IUserInfoProvider>().To<UserInfoProvider>();
            //kernel.Bind<IConnectionProvider>().To<ConnectionProvider>().InRequestScope();
        }
    }
}