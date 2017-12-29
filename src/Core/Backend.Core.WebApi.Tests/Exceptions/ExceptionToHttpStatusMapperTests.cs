using System;
using System.Net;
using FluentAssertions;
using FluentValidation;
using GoldenEye.Backend.Core.WebApi.Exceptions;
using Xunit;

namespace Backend.Core.WebApi.Tests.Exceptions
{
    public class ExceptionToHttpStatusMapperTests
    {
        [Fact]
        public void GivenUnauthorizedAccessException_WhenMapped_ThenReturnsUnauthorizedHttpStatusWithProperMessage()
        {
            //Given
            var message = "Message";
            var exception = new UnauthorizedAccessException(message);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.Unauthorized);
            codeInfo.Message.Should().Be(message);
        }

        [Fact]
        public void GivenNotImplementedException_WhenMapped_ThenReturnsNotImplementedHttpStatusWithProperMessage()
        {
            //Given
            var message = "Message";
            var exception = new NotImplementedException(message);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.NotImplemented);
            codeInfo.Message.Should().Be(message);
        }

        [Fact]
        public void GivenValidationExceptions_WhenMapped_ThenReturnsBadRequestHttpStatusWithProperMessage()
        {
            //Given
            var message = "Message";
            var fluentValidationException = new ValidationException(message);
            var dataAnnotationsException = new System.ComponentModel.DataAnnotations.ValidationException(message);

            var exceptions = new Exception[] { fluentValidationException, dataAnnotationsException };

            foreach (var validationException in exceptions)
            {
                //When
                var codeInfo = ExceptionToHttpStatusMapper.Map(fluentValidationException);

                //Then
                codeInfo.Code.Should().Be(HttpStatusCode.BadRequest);
                codeInfo.Message.Should().Be(message);
            }
        }

        [Fact]
        public void GivenOtherTypeException_WhenMapped_ThenReturnsInternalServerErrorHttpStatusWithProperMessage()
        {
            //Given
            var message = "Message";
            var exception = new Exception(message);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.InternalServerError);
            codeInfo.Message.Should().Be(message);
        }

        [Fact]
        public void GivenOtherTypeExceptionWithCustomMap_WhenMapped_ThenReturnsHttpStatusWithProperMessageFromCustomMap()
        {
            //Given
            var message = "Message";
            var exception = new ArgumentNullException(message);

            ExceptionToHttpStatusMapper.RegisterCustomMap<ArgumentNullException>(
                exc => HttpStatusCodeInfo.Create(HttpStatusCode.BadRequest, "CustomMessage"));

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.BadRequest);
            codeInfo.Message.Should().Be("CustomMessage");
        }

        [Fact]
        public void GivenDefaultHandledExceptionWithCustomMap_WhenMapped_ThenReturnsHttpStatusWithProperMessageFromCustomMap()
        {
            //Given
            var message = "Message";
            var exception = new NotImplementedException(message);

            ExceptionToHttpStatusMapper.RegisterCustomMap<NotImplementedException>(
                exc => HttpStatusCodeInfo.Create(HttpStatusCode.BadRequest, "CustomMessage"));

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.BadRequest);
            codeInfo.Message.Should().Be("CustomMessage");
        }
    }
}