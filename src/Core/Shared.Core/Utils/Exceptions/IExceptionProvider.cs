using System;
using System.Collections.Generic;

namespace GoldenEye.Shared.Core.Utils.Exceptions
{
    public interface IExceptionProvider
    {
        string HandleException(Exception e);

        IEnumerable<IExceptionHandler> ExceptionHandlers { get; }
    }
}