using System.Web.Mvc;
using GoldenEye.Shared.Core.Configuration;

namespace GoldenEye.Frontend.Core.Web
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            if(!ConfigHelper.IsInTestMode)
                filters.Add(new RequireHttpsAttribute());
        }
    }
}
