using System;
using FluentAssertions;
using GoldenEye.Extensions.Functions;
using Xunit;

namespace GoldenEye.Tests.Extensions.Functions.Memoize;

public class RecursionWithLocalFunctionTests
{
    [Fact]
    public void LocalFunction_ShouldBeMemoized()
    {
        var numberOfCalls = 0;

        Func<int, int> fibonacci = null;

        fibonacci = n1 =>
        {
            numberOfCalls++;

            if (n1 <= 2)
                return 1;

            return fibonacci(n1 - 1) + fibonacci(n1 - 2);
        };

        fibonacci = fibonacci.Memoize();

        var result = fibonacci(3);

        result.Should().Be(2);
        numberOfCalls.Should().Be(3);


        var secondResult = fibonacci(3);

        secondResult.Should().Be(2);
        numberOfCalls.Should().Be(3);
    }
}