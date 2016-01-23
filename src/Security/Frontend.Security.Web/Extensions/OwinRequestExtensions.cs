using Microsoft.Owin;

namespace GoldenEye.Frontend.Security.Web.Extensions
{
    public static class OwinRequestExtensions
    {
        public static bool IsAjaxRequest(IOwinRequest request)
        {
            var query = request.Query;
            if ((query != null) && (query["X-Requested-With"] == "XMLHttpRequest"))
            {
                return true;
            }
            var headers = request.Headers;
            return ((headers != null) && (headers["X-Requested-With"] == "XMLHttpRequest"));
        }
    }
}
