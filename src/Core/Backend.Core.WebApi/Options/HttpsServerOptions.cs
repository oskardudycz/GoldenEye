using System;
using Microsoft.AspNetCore.Server.Kestrel.Core;

namespace GoldenEye.Backend.Core.WebApi.Options
{
    public class HttpsServerOptions
    {
        public CertificateOptions CertificateOptions { get; private set; }
        public int Port { get; private set; }
        public Action<KestrelServerOptions> Apply { get; private set; }

        private HttpsServerOptions()
        {
            Apply = options => { };
        }

        public static HttpsServerOptions Create(string path = "localhost.pfx", string password = "P@ssw0rd", int port = 443)
        {
            return new HttpsServerOptions()
                .UseCertificate(path, password)
                .UsePort(port);
        }

        public HttpsServerOptions UseCertificate(string path, string password)
        {
            CertificateOptions = new CertificateOptions(path, password);
            return this;
        }

        public HttpsServerOptions UsePort(int port)
        {
            Port = port;

            return this;
        }

        public HttpsServerOptions Use(Action<KestrelServerOptions> options)
        {
            Apply = options;

            return this;
        }
    }

    public class CertificateOptions
    {
        public string Path { get; }
        public string Password { get; }

        public CertificateOptions(string path, string password)
        {
            Path = path;
            Password = password;
        }
    }
}