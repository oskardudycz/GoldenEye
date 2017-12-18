using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;

namespace GoldenEye.Backend.Core.WebApi.Exceptions
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate next;

        public ExceptionHandlingMiddleware(RequestDelegate next)
        {
            this.next = next;
        }

        public async Task Invoke(HttpContext context /* other scoped dependencies */)
        {
            try
            {
                await next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            var result = JsonConvert.SerializeObject(new { error = codeInfo.Message });
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)codeInfo.Code;
            return context.Response.WriteAsync(result);
        }
    }
}