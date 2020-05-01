using GoldenEye.Backend.Core.WebApi.Exceptions;
using Microsoft.AspNetCore.Builder;

namespace GoldenEye.Backend.Core.WebApi.Registration
{
    public static class Registration
    {
        public static IApplicationBuilder UseExceptionHandlingMiddleware(this IApplicationBuilder app)
        {
            app.UseMiddleware(typeof(ExceptionHandlingMiddleware));
            return app;
        }
    }
}
