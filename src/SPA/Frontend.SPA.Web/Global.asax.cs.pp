using System.Web.Optimization;
using GoldenEye.Frontend.Core.Web;

namespace $rootnamespace$
{
    public class MvcApplication : WebApplication
    {
        protected override void OnBundleConfig()
        {
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            base.OnBundleConfig();
        }

        protected override void OnUnandledExceptionCaught(Exception exception)
        {
            base.OnUnandledExceptionCaught(exception);
        }
    }
}
