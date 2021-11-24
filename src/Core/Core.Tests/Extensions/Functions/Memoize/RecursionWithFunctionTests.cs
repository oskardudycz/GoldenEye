using System;
using FluentAssertions;
using GoldenEye.Extensions.Functions;
using Xunit;

namespace GoldenEye.Tests.Extensions.Functions.Memoize;

public class RecurrsionWithFunctionTests
{
    [Fact]
    public void RegularFunction_ShouldBeMemoized()
    {
        Func<int, int> fibonacci = null;

        fibonacci = Memoizer.Memoize((int n1)  => Fibonacci(n1, fibonacci));

        var result = fibonacci(3);

        result.Should().Be(2);
        numberOfCalls.Should().Be(3);

        var secondResult = fibonacci(3);

        secondResult.Should().Be(2);
        numberOfCalls.Should().Be(3);
    }

    private int numberOfCalls = 0;

    int Fibonacci(int n1)
    {
        return Fibonacci(n1, Fibonacci);
    }

    int Fibonacci(int n1, Func<int, int> fibonacci)
    {
        numberOfCalls++;

        if (n1 <= 2)
            return 1;

        return fibonacci(n1 -1) + fibonacci(n1 - 2);
    }
}