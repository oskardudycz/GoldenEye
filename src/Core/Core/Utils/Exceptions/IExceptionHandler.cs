using System;

namespace GoldenEye.Utils.Exceptions;

public interface IExceptionHandler
{
    bool CanHandleException(Exception e);

    string GetFormattedMessage(Exception e);
}