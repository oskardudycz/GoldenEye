using System;

namespace GoldenEye.Shared.Core.Utils.Exceptions
{
    public interface IExceptionHandler
    {
        bool CanHandleException(Exception e);

        string GetFormattedMessage(Exception e);
    }
}
