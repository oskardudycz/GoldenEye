using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Http;
using AutoMapper;
using GoldenEye.Frontend.Core.Web;
using GoldenEye.Frontend.Core.Web.IoC;
using GoldenEye.Shared.Core.Extensions;
using GoldenEye.Shared.Core.IOC;
using GoldenEye.Shared.Core.IOC.Attributes;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.Shared.Core.Modules;
using Microsoft.Web.Infrastructure.DynamicModuleHelper;
using Ninject;
using Ninject.Web.Common;
using Ninject.Extensions.Conventions;
using Ninject.Extensions.Conventions.Syntax;
using Ninject.Modules;
using WebActivatorEx;

[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(NinjectWebCommon), "Start")]
[assembly: ApplicationShutdownMethod(typeof(NinjectWebCommon), "Stop")]

namespace GoldenEye.Frontend.Core.Web
{
    public static class NinjectWebCommon
    {
        private static readonly Bootstrapper Bootstrapper = new Bootstrapper();

        /// <summary>
        /// Starts the application
        /// </summary>
        public static void Start()
        {
            DynamicModuleUtility.RegisterModule(typeof(OnePerRequestHttpModule));
            DynamicModuleUtility.RegisterModule(typeof(NinjectHttpModule));
            Bootstrapper.Initialize(CreateKernel);
        }

        /// <summary>
        /// Stops the application.
        /// </summary>
        public static void Stop()
        {
            Bootstrapper.ShutDown();
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

            Init(kernel);

            return kernel;
        }

        private static void Init(IKernel kernel)
        {
            LoadAssemblies(kernel);
            
            SetConventions(kernel);

            LoadModules(kernel);

            GlobalConfiguration.Configuration.DependencyResolver = new NinjectResolver(kernel);

            IOCContainer.Initialize(kernel);

            kernel.GetAll<IMappingDefinition>().Cast<Profile>().ForEach(Mapper.AddProfile);
        }

        private static void SetConventions(IKernel kernel)
        {
            Bind(x => x.WithoutAttribute<NotInjectedWithConventionsAttribute>()
                .WithoutAttribute<InjectInSingletonScopeAttribute>()
                .WithoutAttribute<InjectInRequestScopeAttribute>()
                .BindDefaultInterfaces(), kernel);

            Bind(x => x.WithoutAttribute<NotInjectedWithConventionsAttribute>()
                .WithAttribute<InjectInSingletonScopeAttribute>()
                .BindDefaultInterfaces()
                .Configure(el => el.InSingletonScope()), kernel);

            Bind(x => x.WithoutAttribute<NotInjectedWithConventionsAttribute>()
                .WithAttribute<InjectInRequestScopeAttribute>()
                .BindDefaultInterfaces()
                .Configure(el => el.InRequestScope()), kernel);
        }

        private static void Bind(Func<IJoinFilterWhereExcludeIncludeBindSyntax, IConfigureForSyntax> configure, IKernel kernel)
        {
            Func<IFromSyntax, IIncludingNonePublicTypesSelectSyntax> selectAllAssemblies = x => x.From(ReflectionExtensions.GetProjectAssemblies());

            kernel.Bind(x => configure(selectAllAssemblies(x).SelectAllClasses()));
        }

        private static void LoadAssemblies(IKernel kernel)
        {
            var baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
            LoadAssembliesFromPath(baseDirectory, kernel);

            var baseDirectoryAppStartLibs = AppDomain.CurrentDomain.BaseDirectory + "bin\\App_Start\\libs\\";
            LoadAssembliesFromPath(baseDirectoryAppStartLibs, kernel);

            var privateBinPath = AppDomain.CurrentDomain.SetupInformation.PrivateBinPath;
            if (Directory.Exists(privateBinPath))
                LoadAssembliesFromPath(privateBinPath, kernel);
        }
        private static void LoadAssembliesFromPath(string path, IKernel kernel)
        {
            if (!Directory.Exists(path))
                return;

            var currentAssemblies = AppDomain.CurrentDomain.GetAssemblies();

            var assemblyFiles = Directory.GetFiles(path)
                .Where(file => Path.GetExtension(file).Equals(".dll", StringComparison.OrdinalIgnoreCase)
                            && currentAssemblies.All(a => a.GetName().Name != Path.GetFileNameWithoutExtension(file)))
                .ToList();

            foreach (var assemblyFilePath in assemblyFiles)
            {
                var assembly = Assembly.LoadFrom(assemblyFilePath);
                kernel.Load(assembly);
            }
        }

        private static void LoadModules(IKernel kernel)
        {
            var modules = kernel.GetAll<IModule>().Cast<INinjectModule>().ToList();
            var currentlyLoadedModulesNames = kernel.GetModules().Select(el => el.Name).ToList();

            var notLoadedModules = modules.Where(el => !currentlyLoadedModulesNames.Contains(el.Name)).ToList();

            kernel.Load(notLoadedModules);
        }
    }
}