using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using GoldenEye.Extensions.Collections;
using GoldenEye.Extensions.Reflection;

namespace GoldenEye.Extensions.Lambda;

public static class ExpressionExtensions
{
    public static string GetPath<T>(Expression<Func<T, object>> expr)
    {
        var stack = new Stack<string>();

        MemberExpression me;
        switch (expr.Body.NodeType)
        {
            case ExpressionType.Convert:
            case ExpressionType.ConvertChecked:
                var ue = expr.Body as UnaryExpression;
                me = ((ue != null) ? ue.Operand : null) as MemberExpression;
                break;

            default:
                me = expr.Body as MemberExpression;
                break;
        }

        while (me != null)
        {
            stack.Push(me.Member.Name);
            me = me.Expression as MemberExpression;
        }

        return string.Join(".", stack.ToArray());
    }

    public static string GetPath<T, TP>(Expression<Func<T, TP>> expr)
    {
        var stack = new Stack<string>();

        MemberExpression me;
        switch (expr.Body.NodeType)
        {
            case ExpressionType.Convert:
            case ExpressionType.ConvertChecked:
                var ue = expr.Body as UnaryExpression;
                me = ((ue != null) ? ue.Operand : null) as MemberExpression;
                break;

            default:
                me = expr.Body as MemberExpression;
                break;
        }

        while (me != null)
        {
            stack.Push(me.Member.Name);
            me = me.Expression as MemberExpression;
        }

        return string.Join(".", stack.ToArray());
    }

    public static Expression<T> Compose<T>(this Expression<T> first, Expression<T> second,
        Func<Expression, Expression, Expression> merge)
    {
        // build parameter map (from parameters of second to parameters of first)
        var map = first.Parameters.Select((f, i) => new {f, s = second.Parameters[i]})
            .ToDictionary(p => p.s, p => p.f);

        // replace parameters in the second lambda expression with parameters from the first
        var secondBody = ParameterRebinder.ReplaceParameters(map, second.Body);

        // apply composition of lambda expression bodies to parameters from the first
        return Expression.Lambda<T>(merge(first.Body, secondBody), first.Parameters);
    }

    /// <summary>
    ///     Combines two predicates with AND operator
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="first"></param>
    /// <param name="second"></param>
    /// <returns></returns>
    public static Expression<Func<T, bool>> And<T>(this Expression<Func<T, bool>> first,
        Expression<Func<T, bool>> second)
    {
        return first.Compose(second, Expression.And);
    }

    /// <summary>
    ///     Combines two predicates with OR operator
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="first"></param>
    /// <param name="second"></param>
    /// <returns></returns>
    public static Expression<Func<T, bool>> Or<T>(this Expression<Func<T, bool>> first,
        Expression<Func<T, bool>> second)
    {
        return first.Compose(second, Expression.Or);
    }

    public static Action<T, TProperty> Setter<T, TProperty>(this Expression<Func<T, TProperty>> expression)
    {
        var newValue = Expression.Parameter(expression.Body.Type);
        var assign = Expression.Lambda<Action<T, TProperty>>(
            Expression.Assign(expression.Body, newValue),
            expression.Parameters[0], newValue);

        return assign.Compile();
    }

    public static Func<T, TProperty> Getter<T, TProperty>(this Expression<Func<T, TProperty>> expression)
    {
        return expression.Compile();
    }

    /// <summary>
    ///     Returns the underlying type of value selected by expression.
    /// </summary>
    public static Type GetValueType<T>(this Expression<Func<T, object>> expression)
    {
        if (expression.Body.NodeType == ExpressionType.Convert ||
            expression.Body.NodeType == ExpressionType.ConvertChecked)
        {
            var unary = expression.Body as UnaryExpression;

            if (unary != null)
                return unary.Operand.Type;
        }

        return expression.Body.Type;
    }

    /// <summary>
    ///     Checks, whther selector returns instance of a class.
    ///     String is not a class in this method.
    /// </summary>
    public static bool IsClassSelector<T>(this Expression<Func<T, object>> selector)
    {
        var selectorType = selector.GetValueType();
        var isClass = selectorType.GetTypeInfo().IsClass || selectorType.Implements<IEnumerable>();

        return isClass && selectorType != typeof(string); // selector is for class, but not string
    }

    /// <summary>
    ///     Checks, whether underlying type of value returned by selector matches the underlying type of value.
    /// </summary>
    /// <param name="value"></param>
    public static bool MatchesTypeOf<T>(this Expression<Func<T, object>> selector, object value,
        bool matchEnumAndInt = true)
    {
        var selectorType = selector.GetValueType();
        var selectorUnderlyingType = Nullable.GetUnderlyingType(selectorType);

        var isClass = selectorType.GetTypeInfo().IsClass || selectorType.Implements<IEnumerable>();

        var enumMatch = (matchEnumAndInt // match Enum to int selector,
                         && value != null // value is not null
                         && value is Enum) // and is Enum
                        && ( // and
                            selectorType == typeof(int) // selector is for int
                            || selectorUnderlyingType == typeof(int) // or selector is for int?
                        );

        return (isClass && value == null) // selector is for class and value is null
               || (selectorUnderlyingType != null &&
                   (value == null || selectorUnderlyingType == value.GetType())
               ) // selector is for Nullable<> and value is null or matches the underlying type
               || selectorType == value.GetType() // selector is for value type and types have to match
               || enumMatch; // selector is for int or int? and value is Enum
    }
}