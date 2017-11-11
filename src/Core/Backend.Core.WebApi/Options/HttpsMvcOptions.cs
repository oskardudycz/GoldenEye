using System;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.Backend.Core.WebApi.Options
{
    public class HttpsMvcOptions
    {
        public int Port { get; private set; }
        public Action<MvcOptions> Apply { get; private set; }

        private HttpsMvcOptions()
        {
            Apply = options => { };
        }

        public static HttpsMvcOptions Create(int port = 443)
        {
            return new HttpsMvcOptions()
                .UsePort(port);
        }

        public HttpsMvcOptions UsePort(int port)
        {
            Port = port;

            return this;
        }

        public HttpsMvcOptions Use(Action<MvcOptions> options)
        {
            Apply = options;

            return this;
        }
    }
}