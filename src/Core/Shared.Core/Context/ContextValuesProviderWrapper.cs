using System;

namespace GoldenEye.Shared.Core.Context
{
    public static class ContextValuesProviderWrapper
    {
        public static IContextValuesProvider Provider { get; set; }

        public static IContextValuesProvider GetCurrentProvider()
        {
            return //ThreadContextValuesProvider.Instance ??
                Provider;
        }

        public static ContextValuesProviderToken InThreadContext()
        {
            return new ContextValuesProviderToken(Provider);
        }
    }

    public class ContextValuesProviderToken: IDisposable
    {
        public ContextValuesProviderToken(IContextValuesProvider provider)
        {
            //ThreadContextValuesProvider.Instance = new ThreadContextValuesProvider(provider);
        }

        public void Dispose()
        {
            //ThreadContextValuesProvider.Instance = null;
        }
    }
}
