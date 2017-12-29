using System;
using System.Collections.Generic;
using System.Net;
using FluentValidation;
using GoldenEye.Shared.Core.Extensions.Collections;

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

        public static HttpStatusCodeInfo Create(HttpStatusCode code, string message)
        {
            return new HttpStatusCodeInfo(code, message);
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
            else if (exception is ValidationException || exception is System.ComponentModel.DataAnnotations.ValidationException)
                code = HttpStatusCode.BadRequest;

            return new HttpStatusCodeInfo(code, exception.Message);
        }

        public static void RegisterCustomMap<TException>(Func<Exception, HttpStatusCodeInfo> map) where TException : Exception
        {
            CustomMaps.AddOrReplace(typeof(TException), map);
        }
    }
}