using System;
using System.Collections.Generic;
using System.Net;
using FluentValidation;
using GoldenEye.Core.Exceptions;
using GoldenEye.Core.Extensions.Collections;

namespace GoldenEye.WebApi.Exceptions
{
    public class HttpStatusCodeInfo
    {
        public HttpStatusCodeInfo(HttpStatusCode code, string message)
        {
            Code = code;
            Message = message;
        }

        public HttpStatusCode Code { get; }
        public string Message { get; }

        public static HttpStatusCodeInfo Create(HttpStatusCode code, string message)
        {
            return new HttpStatusCodeInfo(code, message);
        }
    }

    public static class ExceptionToHttpStatusMapper
    {
        private static readonly Dictionary<Type, Func<Exception, HttpStatusCodeInfo>> CustomMaps =
            new Dictionary<Type, Func<Exception, HttpStatusCodeInfo>>();

        public static HttpStatusCodeInfo Map(Exception exception)
        {
            if (CustomMaps.ContainsKey(exception.GetType()))
                return CustomMaps[exception.GetType()](exception);

            var code = exception switch
            {
                ValidationException _ => HttpStatusCode.BadRequest,
                System.ComponentModel.DataAnnotations.ValidationException _ => HttpStatusCode.BadRequest,
                ArgumentException _ => HttpStatusCode.BadRequest,
                UnauthorizedAccessException _ => HttpStatusCode.Unauthorized,
                InvalidOperationException _ => HttpStatusCode.Forbidden,
                NotFoundException _ => HttpStatusCode.NotFound,
                OptimisticConcurrencyException _ => HttpStatusCode.Conflict,
                NotImplementedException _ => HttpStatusCode.NotImplemented,
                _ => HttpStatusCode.InternalServerError
            };

            return new HttpStatusCodeInfo(code, exception.Message);
        }

        public static void RegisterCustomMap<TException>(Func<Exception, HttpStatusCodeInfo> map)
            where TException : Exception
        {
            CustomMaps.AddOrReplace(typeof(TException), map);
        }
    }
}
