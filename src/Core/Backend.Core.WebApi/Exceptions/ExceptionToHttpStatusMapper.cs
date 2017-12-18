using System;
using System.Collections.Generic;
using System.Net;
using FluentValidation;

namespace GoldenEye.Backend.Core.WebApi.Exceptions
{
    public class HttpStatusCodeInfo
    {
        public HttpStatusCode Code { get; }
        public string Message { get; }

        public HttpStatusCodeInfo(HttpStatusCode code, string message)
        {
            Code = code;
            Message = message;
        }
    }

    public static class ExceptionToHttpStatusMapper
    {
        public static Dictionary<Type, Func<Exception, HttpStatusCodeInfo>> CustomMaps = new Dictionary<Type, Func<Exception, HttpStatusCodeInfo>>();

        public static HttpStatusCodeInfo Map(Exception exception)
        {
            if (CustomMaps.ContainsKey(exception.GetType()))
                return CustomMaps[exception.GetType()](exception);

            var code = HttpStatusCode.InternalServerError; // 500 if unexpected

            if (exception is UnauthorizedAccessException)
                code = HttpStatusCode.Unauthorized;
            else if (exception is NotImplementedException)
                code = HttpStatusCode.NotImplemented;
            if (exception is ValidationException || exception is System.ComponentModel.DataAnnotations.ValidationException)
                code = HttpStatusCode.BadRequest;

            return new HttpStatusCodeInfo(code, exception.Message);
        }

        public static void RegisterCustomMap<TException>(Func<Exception, HttpStatusCodeInfo> map) where TException : Exception
        {
            CustomMaps.Add(typeof(TException), map);
        }
    }
}