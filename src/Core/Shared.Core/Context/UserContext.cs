using System.Collections.Generic;
using GoldenEye.Shared.Core.Extensions.Basic;
using GoldenEye.Shared.Core.Extensions.Collections;

namespace GoldenEye.Shared.Core.Context
{
    public static class UserContext
    {
        private const string ValuesClientIP = "ClientIP";
        private const string ValuesClientDNS = "ClientDNS";
        private const string ValuesClientBrowser = "ClientBrowser";

        /// <summary>
        /// Gets collection to store context specific data.
        /// </summary>
        public static IDictionary<string, object> Values
        {
            get { return ContextValuesProviderWrapper.GetCurrentProvider().Values; }
        }

        public static string ClientIP
        {
            get { return Get<string>(ValuesClientIP); }
            set { Set(ValuesClientIP, value); }
        }

        public static string ClientDNS
        {
            get { return Get<string>(ValuesClientDNS); }
            set { Set(ValuesClientDNS, value); }
        }

        public static string ClientBrowser
        {
            get { return Get<string>(ValuesClientBrowser); }
            set { Set(ValuesClientBrowser, value); }
        }

        public static T Get<T>(string name)
        {
            return !Values.ContainsKey(name) ? ObjectExtensions.GetEmpty<T>() : Values[name].CastTo<T>();
        }

        public static void Set<T>(string name, T value)
        {
            Values.AddOrReplace(name, value);
        }
    }
}