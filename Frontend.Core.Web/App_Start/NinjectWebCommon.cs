using System;
using System.Web;
using System.Web.Http;
using GoldenEye.Frontend.Core.Web;
using GoldenEye.Frontend.Core.Web.IoC;
using Microsoft.Web.Infrastructure.DynamicModuleHelper;
using Ninject;
using Ninject.Web.Common;
using WebActivatorEx;

[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(NinjectWebCommon), "Start")]
[assembly: ApplicationShutdownMethod(typeof(NinjectWebCommon), "Stop")]

namespace GoldenEye.Frontend.Core.Web
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
            //kernel.Bind<ISampleContext>().To<SampleContext>();
            //kernel.Bind<IUserInfoProvider>().To<UserInfoProvider>();
            //kernel.Bind<IConnectionProvider>().To<ConnectionProvider>().InRequestScope();
        }
    }
}