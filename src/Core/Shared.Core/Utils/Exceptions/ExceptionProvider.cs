using System;
using System.Collections.Generic;
using System.Text;
using GoldenEye.Shared.Core.IOC;

namespace GoldenEye.Shared.Core.Utils.Exceptions
{
    public class ExceptionProvider: IExceptionProvider
    {
        private const int MaxRecursionLevel = 10;

        public string HandleException(Exception exception)
        {
            var sb = new StringBuilder();
            int recursionLevel = 1;

            while (exception != null && recursionLevel <= MaxRecursionLevel)
            {
                sb.Append(exception.Message);
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                foreach (var handler in ExceptionHandlers)
                {
                    if (handler.CanHandleException(exception))
                        sb.Append(handler.GetFormattedMessage(exception));
                }
                sb.Append(exception.StackTrace);
                sb.Append(Environment.NewLine);
                sb.Append(Environment.NewLine);
                exception = exception.InnerException;
                recursionLevel++;
            }
            return sb.ToString();
        }

        public IEnumerable<IExceptionHandler> ExceptionHandlers
        {
            get { return IOCContainer.Instance.GetAll<IExceptionHandler>(); }
        }
    }
}
