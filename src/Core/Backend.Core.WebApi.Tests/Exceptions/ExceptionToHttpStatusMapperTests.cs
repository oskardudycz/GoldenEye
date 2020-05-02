using System;
using System.Net;
using FluentAssertions;
using FluentValidation;
using GoldenEye.Backend.Core.Exceptions;
using GoldenEye.Backend.Core.WebApi.Exceptions;
using Xunit;

namespace Backend.Core.WebApi.Tests.Exceptions
{
    public class ExceptionToHttpStatusMapperTests
    {
        [Fact]
        public void GivenArgumentExceptions_WhenMapped_ThenReturnsBadRequestHttpStatusWithProperMessage()
        {
            //Given
            var argumentException = new ArgumentException();
            var argumentNullException = new ArgumentNullException();
            var argumentOutOfRangeException = new ArgumentOutOfRangeException();

            var exceptions = new Exception[] { argumentException, argumentNullException, argumentOutOfRangeException };

            foreach (var argumentExc in exceptions)
            {
                //When
                var codeInfo = ExceptionToHttpStatusMapper.Map(argumentExc);

                //Then
                codeInfo.Code.Should().Be(HttpStatusCode.BadRequest);
            }
        }

        [Fact]
        public void GivenValidationExceptions_WhenMapped_ThenReturnsBadRequestHttpStatusWithProperMessage()
        {
            //Given
            const string message = "Message";
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
        public void GivenUnauthorizedAccessException_WhenMapped_ThenReturnsUnauthorizedHttpStatusWithProperMessage()
        {
            //Given
            const string message = "Message";
            var exception = new UnauthorizedAccessException(message);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.Unauthorized);
            codeInfo.Message.Should().Be(message);
        }

        [Fact]
        public void GivenInvalidOperationException_WhenMapped_ThenReturnsForbiddenHttpStatusWithProperMessage()
        {
            //Given
            const string message = "Message";
            var exception = new InvalidOperationException(message);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.Forbidden);
            codeInfo.Message.Should().Be(message);
        }

        [Fact]
        public void GivenNotFoundException_WhenMapped_ThenReturnsForbiddenHttpStatusWithProperMessage()
        {
            //Given
            var id = Guid.NewGuid();
            var exception = NotFoundException.For<TestEntity>(id);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.NotFound);
            codeInfo.Message.Should().Be($"{typeof(TestEntity).Name} with id: {id} was not found.");
        }

        [Fact]
        public void GivenOptimisticConcurrencyException_WhenMapped_ThenReturnsForbiddenHttpStatusWithProperMessage()
        {
            //Given
            var id = Guid.NewGuid();
            var version = Guid.NewGuid();
            var exception = OptimisticConcurrencyException.For<TestEntity>(id, version);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.Conflict);
            codeInfo.Message.Should().Be($"Cannot modify {typeof(TestEntity).Name} with id: {id}. Version `{version}` did not match.");
        }

        [Fact]
        public void GivenNotImplementedException_WhenMapped_ThenReturnsNotImplementedHttpStatusWithProperMessage()
        {
            //Given
            const string message = "Message";
            var exception = new NotImplementedException(message);

            //When
            var codeInfo = ExceptionToHttpStatusMapper.Map(exception);

            //Then
            codeInfo.Code.Should().Be(HttpStatusCode.NotImplemented);
            codeInfo.Message.Should().Be(message);
        }

        [Fact]
        public void GivenOtherTypeException_WhenMapped_ThenReturnsInternalServerErrorHttpStatusWithProperMessage()
        {
            //Given
            const string message = "Message";
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
            const string message = "Message";
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
            const string message = "Message";
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

    internal class TestEntity
    {
        public Guid Id { get; set; }
    }
}
