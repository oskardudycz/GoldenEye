using System.Web;
using System.Web.Mvc;
using Shared.Core.Configuration;

namespace Frontend.Web
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
