using System.Web.Optimization;

namespace GoldenEye.Frontend.Web
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/libs")
                .Include("~/Scripts/sammy-0.7.5.js")
                .Include("~/Scripts/moment.js")
                .Include("~/Scripts/toastr.js")
                .Include("~/Scripts/pl-PL.js"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/site.css",
                      "~/Content/toastr.css",
                      "~/Content/misc.css"));

            bundles.Add(new ScriptBundle("~/bundles/knockout")
                .Include("~/Scripts/knockout-{version}.js")
                .Include("~/Scripts/knockout.mapping-latest.js")
                .Include("~/Scripts/knockout.validation.js")
                .Include("~/Scripts/knockstrap.js"));

            bundles.Add(new ScriptBundle("~/bundles/app")
                .IncludeDirectory("~/app/Services/", "*.js", false)
                .Include("~/app/Components/ComponentsConfig.js")
                .Include("~/Scripts/GoldenEye/GoldenEye.js")
                .Include("~/app/RoutesConfig.js"));
        }
    }
}
